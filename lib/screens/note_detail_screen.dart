import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';
import 'note_editor_screen.dart';
import 'sub_accounts_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteRepository _repository = NoteRepository();
  late NoteModel _note;
  String? _decryptedContent;
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _isLocked = _note.isEncrypted;
    
    if (!_note.isEncrypted) {
      _decryptedContent = _note.content;
    }
  }

  Future<void> _showUnlockDialog() async {
    final passwordController = TextEditingController();
    bool showPassword = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Unlock Note',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter password to view content',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: passwordController,
                    autofocus: true,
                    obscureText: !showPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.key, color: Colors.white70),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) {
                      Navigator.pop(context, true);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Unlock'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          );
        },
      ),
    );

    if (result == true && mounted) {
      final password = passwordController.text;
      
      if (password.isEmpty) {
        _showErrorSnackBar('Password cannot be empty');
        return;
      }

      try {
        final decrypted = _repository.decryptNoteContent(_note, password);
        setState(() {
          _decryptedContent = decrypted;
          _isLocked = false;
        });
        _showSuccessSnackBar('Note unlocked!');
      } catch (e) {
        _showErrorSnackBar('Invalid password');
        // Show dialog again
        await Future.delayed(const Duration(milliseconds: 300));
        _showUnlockDialog();
      }
    }
  }

  Future<void> _deleteNote() async {
    // If note is encrypted, require password verification first
    if (_note.isEncrypted && _isLocked) {
      _showErrorSnackBar('Please unlock the note before deleting');
      return;
    }

    if (_note.isEncrypted && !_isLocked) {
      // Ask for password confirmation
      final passwordVerified = await _showPasswordVerificationDialog();
      if (!passwordVerified) {
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Note?',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );

    if (confirmed == true && mounted) {
      await _repository.deleteNote(_note.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showPasswordVerificationDialog() async {
    final passwordController = TextEditingController();
    bool showPassword = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Verify Password',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter password to confirm deletion',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: passwordController,
                    autofocus: true,
                    obscureText: !showPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.key, color: Colors.white70),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) {
                      Navigator.pop(context, true);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Verify & Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          );
        },
      ),
    );

    if (result == true && mounted) {
      final password = passwordController.text;
      
      if (password.isEmpty) {
        _showErrorSnackBar('Password cannot be empty');
        return false;
      }

      try {
        // Verify password by attempting to decrypt
        _repository.decryptNoteContent(_note, password);
        return true;
      } catch (e) {
        _showErrorSnackBar('Invalid password');
        return false;
      }
    }

    return false;
  }

  void _editNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: _note),
      ),
    );

    if (result == true && mounted) {
      // Reload note
      final updatedNote = _repository.getNoteById(_note.id);
      if (updatedNote != null) {
        setState(() {
          _note = updatedNote;
          if (!_note.isEncrypted) {
            _decryptedContent = _note.content;
          } else {
            _isLocked = true;
            _decryptedContent = null;
          }
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_decryptedContent != null) {
      Clipboard.setData(ClipboardData(text: _decryptedContent!));
      _showSuccessSnackBar('Copied to clipboard');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getColorByType(_note.type);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(color),
                      const SizedBox(height: 20),
                      _buildContent(),
                      const SizedBox(height: 20),
                      _buildMetadata(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(duration: 300.ms),
          const Spacer(),
          IconButton(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(delay: 100.ms, duration: 300.ms),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _editNote,
            icon: const Icon(Icons.edit),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(delay: 150.ms, duration: 300.ms),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _deleteNote,
            icon: const Icon(Icons.delete),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.3),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return GlassCard(
      gradient: [
        color.withOpacity(0.3),
        color.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NoteType.getIcon(_note.type),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      NoteType.getDisplayName(_note.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_note.isEncrypted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isLocked
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _note.title,
            style: AppTheme.headingLarge.copyWith(fontSize: 28),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, duration: 400.ms);
  }

  Widget _buildContent() {
    if (_isLocked && _note.isEncrypted) {
      return GlassCard(
        child: Column(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'This note is encrypted',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap below to unlock and view content',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showUnlockDialog,
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).scale(duration: 400.ms);
    }

    // Display account notes with structured data
    if (_note.type == NoteType.account && _note.meta != null) {
      return _buildAccountDetails();
    }

    // Display bank/card notes with structured data
    if (_note.type == NoteType.bank && _note.meta != null) {
      return _buildBankCardDetails();
    }

    // Default content display for other note types
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            _decryptedContent ?? _note.content,
            style: AppTheme.bodyLarge.copyWith(height: 1.6),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms);
  }

  Widget _buildAccountDetails() {
    final meta = _note.meta!;
    
    return Column(
      children: [
        // Account Name
        if (meta['accountName'] != null && meta['accountName'].toString().isNotEmpty)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Name',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        meta['accountName'],
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meta['accountName']));
                    _showSuccessSnackBar('Account name copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 12),
        
        // Identifiers (Username/Email/Phone)
        if (meta['identifiers'] != null && (meta['identifiers'] as List).isNotEmpty)
          ...((meta['identifiers'] as List).asMap().entries.map((entry) {
            final identifier = Map<String, dynamic>.from(entry.value as Map);
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Icon(
                      _getIdentifierIcon(identifier['type']?.toString()),
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            identifier['type']?.toString() ?? 'Identifier',
                            style: AppTheme.caption,
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            identifier['value']?.toString() ?? '',
                            style: AppTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: identifier['value']?.toString() ?? ''));
                        _showSuccessSnackBar('${identifier['type']?.toString() ?? 'Value'} copied');
                      },
                      icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (250 + index * 50).ms).slideY(begin: 0.2),
            );
          }).toList()),
        
        // Password
        if (meta['accountPassword'] != null && meta['accountPassword'].toString().isNotEmpty)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        meta['accountPassword'],
                        style: AppTheme.bodyLarge.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meta['accountPassword']));
                    _showSuccessSnackBar('Password copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
        
        // Subscription Section
        if (meta['hasSubscription'] == true) ...[
          const SizedBox(height: 12),
          GlassCard(
            gradient: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.subscriptions, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Subscription Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Plan Name
                if (meta['planName'] != null && meta['planName'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.card_membership, color: Colors.white60, size: 18),
                      const SizedBox(width: 8),
                      const Text('Plan: ', style: AppTheme.caption),
                      SelectableText(
                        meta['planName'],
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Start Date
                if (meta['subscriptionStartDate'] != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white60, size: 18),
                      const SizedBox(width: 8),
                      const Text('Start: ', style: AppTheme.caption),
                      Text(
                        DateFormat('MMM d, y').format(
                          DateTime.parse(meta['subscriptionStartDate']),
                        ),
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // End Date
                if (meta['subscriptionEndDate'] != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.white60, size: 18),
                      const SizedBox(width: 8),
                      const Text('End: ', style: AppTheme.caption),
                      Text(
                        DateFormat('MMM d, y').format(
                          DateTime.parse(meta['subscriptionEndDate']),
                        ),
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
        
        // Sub-Accounts Section
        if (meta['subAccounts'] != null && (meta['subAccounts'] as List).isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassCard(
            gradient: [
              Colors.deepPurple.withOpacity(0.2),
              Colors.deepPurple.withOpacity(0.05),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_tree, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sub-Accounts (${(meta['subAccounts'] as List).length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _viewAllSubAccounts(meta),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accounts linked to this main account',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 16),
                // Show first 3 sub-accounts
                ...((meta['subAccounts'] as List).take(3).toList().asMap().entries.map((entry) {
                  final subAccount = Map<String, dynamic>.from(entry.value as Map);
                  final index = entry.key;
                  return _buildSubAccountCard(subAccount, index);
                }).toList()),
                if ((meta['subAccounts'] as List).length > 3) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _viewAllSubAccounts(meta),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(
                        '+${(meta['subAccounts'] as List).length - 3} more sub-accounts',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
        ],
      ],
    );
  }

  Widget _buildSubAccountCard(Map<String, dynamic> subAccount, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subAccount['name']?.toString() ?? 'Sub-Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subAccount['username'] != null && 
                          subAccount['username'].toString().isNotEmpty)
                        Text(
                          subAccount['username'].toString(),
                          style: AppTheme.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Username/Email section
            if (subAccount['username'] != null && 
                subAccount['username'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      subAccount['username'].toString(),
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: subAccount['username'].toString()));
                      _showSuccessSnackBar('Username copied');
                    },
                    icon: const Icon(Icons.copy, color: Colors.white60, size: 16),
                  ),
                ],
              ),
            ],
            
            // Password section
            if (subAccount['password'] != null && 
                subAccount['password'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.lock, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      subAccount['password'].toString(),
                      style: AppTheme.bodyMedium.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: subAccount['password'].toString()));
                      _showSuccessSnackBar('Password copied');
                    },
                    icon: const Icon(Icons.copy, color: Colors.white60, size: 16),
                  ),
                ],
              ),
            ],
            
            // Notes section
            if (subAccount['notes'] != null && 
                subAccount['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      subAccount['notes'].toString(),
                      style: AppTheme.caption.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankCardDetails() {
    final meta = _note.meta!;
    
    return Column(
      children: [
        // Card Name
        if (meta['cardName'] != null && meta['cardName'].toString().isNotEmpty)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Name',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        meta['cardName'],
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meta['cardName']));
                    _showSuccessSnackBar('Card name copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 12),
        
        // Card Number
        if (meta['cardNumber'] != null && meta['cardNumber'].toString().isNotEmpty)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.numbers, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Number',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        meta['cardNumber'],
                        style: AppTheme.bodyLarge.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meta['cardNumber']));
                    _showSuccessSnackBar('Card number copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 12),
        
        // CVV
        if (meta['cardCvv'] != null && meta['cardCvv'].toString().isNotEmpty)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CVV',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        meta['cardCvv'],
                        style: AppTheme.bodyLarge.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meta['cardCvv']));
                    _showSuccessSnackBar('CVV copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 12),
        
        // Expiration Date
        if (meta['cardExpirationDate'] != null)
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expiration Date',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final expDate = DateTime.parse(meta['cardExpirationDate']);
                          final now = DateTime.now();
                          final isExpired = expDate.isBefore(now);
                          final isExpiringSoon = expDate.isAfter(now) && 
                                                expDate.difference(now).inDays <= 30;
                          
                          return Row(
                            children: [
                              Text(
                                '${expDate.month.toString().padLeft(2, '0')}/${expDate.year}',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isExpired 
                                      ? Colors.red 
                                      : isExpiringSoon 
                                          ? Colors.orange 
                                          : Colors.white,
                                  fontWeight: isExpired || isExpiringSoon 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isExpired) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.warning, color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Expired',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else if (isExpiringSoon) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Expiring Soon',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
        
        // Subscription/Bills Section
        if (meta['hasCardSubscription'] == true && 
            meta['cardSubscription'] != null && 
            meta['cardSubscription'].toString().isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassCard(
            gradient: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.subscriptions, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Subscription / Bills Auto-pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SelectableText(
                  meta['cardSubscription'],
                  style: AppTheme.bodyLarge.copyWith(height: 1.6),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ],
    );
  }

  IconData _getIdentifierIcon(String? type) {
    switch (type) {
      case 'Email':
        return Icons.email;
      case 'Phone Number':
        return Icons.phone;
      case 'Username':
        return Icons.person;
      default:
        return Icons.info;
    }
  }

  void _viewAllSubAccounts(Map<String, dynamic> meta) {
    final subAccounts = (meta['subAccounts'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountsScreen(
          subAccounts: subAccounts,
          mainAccountName: meta['accountName']?.toString() ?? 'Main Account',
          onSubAccountsChanged: (updatedSubAccounts) {
            // Sub-accounts can't be edited from detail screen - read-only
            // User needs to edit the note to modify sub-accounts
          },
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Column(
      children: [
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created',
                      style: AppTheme.caption,
                    ),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(_note.createdAt),
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.update, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Updated',
                      style: AppTheme.caption,
                    ),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(_note.updatedAt),
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.2),
      ],
    );
  }
}

