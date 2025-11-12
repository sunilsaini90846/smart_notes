import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';
import 'note_editor_screen.dart';

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
        if (_note.tags != null && _note.tags!.isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _note.tags!.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ],
    );
  }
}

