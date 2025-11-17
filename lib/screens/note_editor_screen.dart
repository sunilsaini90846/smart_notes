import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';
import 'sub_accounts_screen.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final String? initialType;

  const NoteEditorScreen({super.key, this.note, this.initialType});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteRepository _repository = NoteRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _passwordController;

  String _selectedType = NoteType.plain;
  bool _isEncrypted = false;
  bool _showPassword = false;

  bool _isSaving = false;
  bool _isUnlocked = false;

  // Account note specific fields
  final TextEditingController _accountNameController = TextEditingController();
  List<Map<String, dynamic>> _accountIdentifiers = []; // username, email, number
  final TextEditingController _accountPasswordController = TextEditingController();
  bool _showAccountPassword = false;
  bool _hasSubscription = false;
  final TextEditingController _planNameController = TextEditingController();
  DateTime? _subscriptionStartDate;
  DateTime? _subscriptionEndDate;
  List<Map<String, dynamic>> _subAccounts = []; // Sub-accounts linked to this main account

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _selectedType = widget.note!.type;
      _isEncrypted = widget.note!.isEncrypted;

      // Load account-specific data if it's an account note
      if (_selectedType == NoteType.account && widget.note!.meta != null) {
        _loadAccountData(widget.note!.meta!);
      }

      // For editing, we need to decrypt first if encrypted
      if (widget.note!.isEncrypted) {
        _contentController = TextEditingController();
        _passwordController = TextEditingController();
        _isUnlocked = false;
        // Show unlock dialog after init
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUnlockDialog();
        });
      } else {
        _contentController = TextEditingController(text: widget.note!.content);
        _passwordController = TextEditingController();
        _isUnlocked = true;
      }
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _passwordController = TextEditingController();
      _isUnlocked = true;
      
      // Set initial type if provided (from filter selection)
      if (widget.initialType != null) {
        _selectedType = widget.initialType!;
      }
    }
  }

  void _loadAccountData(Map<String, dynamic> meta) {
    _accountNameController.text = meta['accountName']?.toString() ?? '';
    _accountPasswordController.text = meta['accountPassword']?.toString() ?? '';
    _hasSubscription = meta['hasSubscription'] == true;
    _planNameController.text = meta['planName']?.toString() ?? '';
    
    if (meta['identifiers'] != null) {
      _accountIdentifiers = (meta['identifiers'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    
    if (meta['subscriptionStartDate'] != null) {
      _subscriptionStartDate = DateTime.parse(meta['subscriptionStartDate'].toString());
    }
    
    if (meta['subscriptionEndDate'] != null) {
      _subscriptionEndDate = DateTime.parse(meta['subscriptionEndDate'].toString());
    }
    
    if (meta['subAccounts'] != null) {
      _subAccounts = (meta['subAccounts'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  Future<void> _showUnlockDialog() async {
    if (widget.note == null || !widget.note!.isEncrypted) return;

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
                    'Unlock Note for Editing',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter password to unlock and edit this note',
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
        // Show dialog again
        await Future.delayed(const Duration(milliseconds: 300));
        _showUnlockDialog();
        return;
      }

      try {
        final decrypted = _repository.decryptNoteContent(widget.note!, password);
        setState(() {
          _contentController.text = decrypted;
          _isUnlocked = true;
        });
        _showSuccessSnackBar('Note unlocked for editing!');
      } catch (e) {
        _showErrorSnackBar('Invalid password');
        // Show dialog again
        await Future.delayed(const Duration(milliseconds: 300));
        _showUnlockDialog();
      }
    } else {
      // User cancelled, go back
      if (mounted) {
        Navigator.pop(context);
      }
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

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    // For encrypted notes, we need a password
    if (_isEncrypted && _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter a password for encryption');
      return;
    }

    // For editing encrypted notes, if user is changing to unencrypted,
    // we need to make sure they have permission (they already unlocked it)
    if (widget.note != null && widget.note!.isEncrypted && !_isEncrypted) {
      // User is decrypting the note, this is allowed since they unlocked it
    }

    setState(() => _isSaving = true);

    try {
      // Prepare content and meta based on note type
      String content = _contentController.text;
      Map<String, dynamic>? meta;

      if (_selectedType == NoteType.account) {
        // For account notes, store structured data in meta
        meta = _buildAccountMeta();
        content = _buildAccountSummary(); // Create a readable summary for content
      }

      if (widget.note == null) {
        // Create new note
        await _repository.createNote(
          title: _titleController.text,
          type: _selectedType,
          content: content,
          isEncrypted: _isEncrypted,
          password: _isEncrypted ? _passwordController.text : null,
          meta: meta,
        );
      } else {
        // Update existing note
        await _repository.updateNote(
          widget.note!.id,
          title: _titleController.text,
          type: _selectedType,
          content: content,
          isEncrypted: _isEncrypted,
          password: _isEncrypted ? _passwordController.text : null,
          meta: meta,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(widget.note == null ? 'Note created!' : 'Note updated!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Map<String, dynamic> _buildAccountMeta() {
    return {
      'accountName': _accountNameController.text,
      'accountPassword': _accountPasswordController.text,
      'identifiers': _accountIdentifiers,
      'hasSubscription': _hasSubscription,
      'planName': _planNameController.text,
      'subscriptionStartDate': _subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': _subscriptionEndDate?.toIso8601String(),
      'subAccounts': _subAccounts,
    };
  }

  String _buildAccountSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Account: ${_accountNameController.text}');
    
    for (var identifier in _accountIdentifiers) {
      buffer.writeln('${identifier['type']}: ${identifier['value']}');
    }
    
    if (_hasSubscription) {
      buffer.writeln('Subscription: Yes');
      if (_planNameController.text.isNotEmpty) {
        buffer.writeln('Plan: ${_planNameController.text}');
      }
      if (_subscriptionStartDate != null) {
        buffer.writeln('Start: ${_subscriptionStartDate!.toString().split(' ')[0]}');
      }
      if (_subscriptionEndDate != null) {
        buffer.writeln('End: ${_subscriptionEndDate!.toString().split(' ')[0]}');
      }
    }
    
    if (_subAccounts.isNotEmpty) {
      buffer.writeln('\nSub-Accounts: ${_subAccounts.length}');
      for (var subAccount in _subAccounts) {
        buffer.writeln('  - ${subAccount['name']}');
      }
    }
    
    return buffer.toString();
  }


  @override
  Widget build(BuildContext context) {
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeSelector(),
                        const SizedBox(height: 20),
                        _buildTitleField(),
                        const SizedBox(height: 20),
                        _buildContentField(),
                        const SizedBox(height: 20),
                        _buildEncryptionToggle(),
                        if (_isEncrypted && _isUnlocked) ...[
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                        ],
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                      ],
                    ),
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.note == null ? 'New Note' : 'Edit Note',
              style: AppTheme.headingMedium,
            ).animate().fadeIn().slideX(begin: -0.2, duration: 300.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note Type',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: NoteType.all.map((type) {
              final isSelected = _selectedType == type;
              final color = AppTheme.getColorByType(type);
              
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NoteType.getIcon(type),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        NoteType.getDisplayName(type),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2);
  }

  Widget _buildTitleField() {
    return GlassCard(
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          icon: const Icon(Icons.title, color: Colors.white70),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildContentField() {
    // If editing encrypted note and not unlocked yet, show locked state
    if (widget.note != null && widget.note!.isEncrypted && !_isUnlocked) {
      return GlassCard(
        child: Column(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Note is locked',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock the note to edit its content',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showUnlockDialog,
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
    }

    // Show account form for account type
    if (_selectedType == NoteType.account) {
      return _buildAccountForm();
    }

    // Default content field for other types
    return GlassCard(
      child: TextFormField(
        controller: _contentController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        maxLines: 10,
        decoration:  InputDecoration(
          labelText: 'Content',
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          alignLabelWithHint: true,
          icon: const Icon(Icons.notes, color: Colors.white70),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
          }
          return null;
        },
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildAccountForm() {
    return Column(
      children: [
        // Account Name
        GlassCard(
          child: TextFormField(
            controller: _accountNameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              labelText: 'Account Name',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'e.g., Google, Netflix, GitHub',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              icon: Icon(Icons.business, color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account name';
              }
              return null;
            },
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 16),
        
        // Dynamic Identifiers Section
        _buildIdentifiersSection(),
        
        const SizedBox(height: 16),
        
        // Password Security Warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade300,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Security Note: Passwords are stored in plain text. For maximum security, use the encryption toggle below the form to encrypt this entire note.',
                  style: TextStyle(
                    color: Colors.orange.shade100,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 380.ms),
        
        const SizedBox(height: 16),
        
        // Account Password (Optional)
        GlassCard(
          child: TextFormField(
            controller: _accountPasswordController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            obscureText: !_showAccountPassword,
            decoration: InputDecoration(
              labelText: 'Password (Optional)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Leave empty if not needed',
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              icon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showAccountPassword = !_showAccountPassword),
                icon: Icon(
                  _showAccountPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
              ),
            ),
            // No validator - field is optional
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 16),
        
        // Subscription Section
        _buildSubscriptionSection(),
        
        const SizedBox(height: 16),
        
        // Sub-Accounts Section
        _buildSubAccountsSection(),
      ],
    );
  }

  Widget _buildIdentifiersSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Username / Email / Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _addIdentifier,
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                tooltip: 'Add identifier',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_accountIdentifiers.isEmpty)
            Center(
              child: TextButton.icon(
                onPressed: _addIdentifier,
                icon: const Icon(Icons.add, color: Colors.white70),
                label: const Text(
                  'Add username, email or number',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ..._accountIdentifiers.asMap().entries.map((entry) {
              final index = entry.key;
              final identifier = entry.value;
              return _buildIdentifierField(index, identifier);
            }).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: -0.2);
  }

  Widget _buildIdentifierField(int index, Map<String, dynamic> identifier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: identifier['type'] ?? 'Username',
                    dropdownColor: AppTheme.surfaceColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.only(left: 12, right: 12,),
                    ),
                    items: ['Username', 'Email', 'Phone Number', 'Other']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _accountIdentifiers[index]['type'] = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _removeIdentifier(index),
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: identifier['value'] ?? '',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                hintText: 'Enter value',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.only(left: 12, right: 12,),
              ),
              onChanged: (value) {
                _accountIdentifiers[index]['value'] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.subscriptions, color: Colors.white70),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Has Subscription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: _hasSubscription,
                onChanged: (value) => setState(() => _hasSubscription = value),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (_hasSubscription) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Plan Name
            TextFormField(
              controller: _planNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Plan Name (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'e.g., Premium, Pro, Business',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                icon: Icon(Icons.card_membership, color: Colors.white70),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Start Date
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.calendar_today, color: Colors.white70),
                ),
                child: Text(
                  _subscriptionStartDate != null
                      ? _subscriptionStartDate!.toString().split(' ')[0]
                      : 'Select start date',
                  style: TextStyle(
                    color: _subscriptionStartDate != null
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // End Date
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.event, color: Colors.white70),
                ),
                child: Text(
                  _subscriptionEndDate != null
                      ? _subscriptionEndDate!.toString().split(' ')[0]
                      : 'Select end date',
                  style: TextStyle(
                    color: _subscriptionEndDate != null
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: -0.2);
  }

  void _addIdentifier() {
    setState(() {
      _accountIdentifiers.add({
        'type': 'Username',
        'value': '',
      });
    });
  }

  void _removeIdentifier(int index) {
    setState(() {
      _accountIdentifiers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_subscriptionStartDate ?? DateTime.now())
        : (_subscriptionEndDate ?? DateTime.now());
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _subscriptionStartDate = pickedDate;
        } else {
          _subscriptionEndDate = pickedDate;
        }
      });
    }
  }

  Widget _buildSubAccountsSection() {
    return GlassCard(
      gradient: [
        Colors.deepPurple.withOpacity(0.2),
        Colors.deepPurple.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_tree, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sub-Accounts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Add sub-account button
                  IconButton(
                    onPressed: _openSubAccountsScreen,
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                    tooltip: 'Add sub-account',
                  ),
                  // View all sub-accounts button
                  if (_subAccounts.isNotEmpty)
                    IconButton(
                      onPressed: _openSubAccountsScreen,
                      icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                      tooltip: 'View all sub-accounts',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Accounts linked to this main account (${_subAccounts.length})',
            style: AppTheme.caption,
          ),
          const SizedBox(height: 12),
          if (_subAccounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextButton.icon(
                  onPressed: _openSubAccountsScreen,
                  icon: const Icon(Icons.add, color: Colors.white70),
                  label: const Text(
                    'Add sub-account (e.g., Facebook, Netflix)',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                // Show first 2 sub-accounts as preview
                ..._subAccounts.take(2).toList().map((subAccount) {
                  return _buildSubAccountPreviewCard(subAccount);
                }).toList(),
                if (_subAccounts.length > 2) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _openSubAccountsScreen,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      'View all ${_subAccounts.length} sub-accounts',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildSubAccountPreviewCard(Map<String, dynamic> subAccount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                subAccount['accountName']?.toString() ?? 'Sub-Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ),
      ),
    );
  }

  void _openSubAccountsScreen() async {
    final accountName = _accountNameController.text.isEmpty 
        ? 'Main Account' 
        : _accountNameController.text;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountsScreen(
          subAccounts: _subAccounts,
          mainAccountName: accountName,
          onSubAccountsChanged: (updatedSubAccounts) {
            setState(() {
              _subAccounts = updatedSubAccounts;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubAccountCard(int index, Map<String, dynamic> subAccount) {
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
                        subAccount['name'] ?? 'Sub-Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subAccount['username'] != null && 
                          subAccount['username'].toString().isNotEmpty)
                        Text(
                          subAccount['username'],
                          style: AppTheme.caption,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editSubAccount(index),
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _removeSubAccount(index),
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                  tooltip: 'Remove',
                ),
              ],
            ),
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
                    child: Text(
                      '••••••••',
                      style: AppTheme.bodyMedium.copyWith(letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ],
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
                    child: Text(
                      subAccount['notes'],
                      style: AppTheme.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Future<void> _showAddSubAccountDialog() async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final notesController = TextEditingController();
    bool showPassword = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Add Sub-Account',
                            style: AppTheme.headingMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add accounts linked to your main account',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    // Account Name
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Account Name *',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'e.g., Facebook, Instagram, Netflix',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.business, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Username/Email
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Username / Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Optional',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Optional',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
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
                        fillColor: Colors.white10,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Additional information (optional)',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.notes, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
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
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
            ),
          );
        },
      ),
    );

    if (result == true && mounted) {
      if (nameController.text.isEmpty) {
        _showErrorSnackBar('Account name is required');
        return;
      }

      setState(() {
        _subAccounts.add({
          'name': nameController.text,
          'username': usernameController.text,
          'password': passwordController.text,
          'notes': notesController.text,
        });
      });
      _showSuccessSnackBar('Sub-account added');
    }
  }

  Future<void> _editSubAccount(int index) async {
    final subAccount = _subAccounts[index];
    final nameController = TextEditingController(text: subAccount['name']);
    final usernameController = TextEditingController(text: subAccount['username']);
    final passwordController = TextEditingController(text: subAccount['password']);
    final notesController = TextEditingController(text: subAccount['notes']);
    bool showPassword = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Edit Sub-Account',
                            style: AppTheme.headingMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Account Name
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Account Name *',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.business, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Username/Email
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Username / Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
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
                        fillColor: Colors.white10,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.notes, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
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
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
            ),
          );
        },
      ),
    );

    if (result == true && mounted) {
      if (nameController.text.isEmpty) {
        _showErrorSnackBar('Account name is required');
        return;
      }

      setState(() {
        _subAccounts[index] = {
          'name': nameController.text,
          'username': usernameController.text,
          'password': passwordController.text,
          'notes': notesController.text,
        };
      });
      _showSuccessSnackBar('Sub-account updated');
    }
  }

  void _removeSubAccount(int index) {
    setState(() {
      _subAccounts.removeAt(index);
    });
    _showSuccessSnackBar('Sub-account removed');
  }

  Widget _buildEncryptionToggle() {
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encrypt this note',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Protect with password',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: _isEncrypted,
            onChanged: (value) => setState(() => _isEncrypted = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildPasswordField() {
    return GlassCard(
      child: TextFormField(
        controller: _passwordController,
        style: const TextStyle(color: Colors.white),
        obscureText: !_showPassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          icon: const Icon(Icons.key, color: Colors.white70),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showPassword = !_showPassword),
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
          ),
        ),
        validator: (value) {
          if (_isEncrypted && (value == null || value.isEmpty)) {
            return 'Password is required for encryption';
          }
          if (_isEncrypted && value!.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }


  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save),
                  const SizedBox(width: 8),
                  Text(
                    widget.note == null ? 'Create Note' : 'Update Note',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(duration: 300.ms);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _passwordController.dispose();
    _accountNameController.dispose();
    _accountPasswordController.dispose();
    _planNameController.dispose();
    super.dispose();
  }
}

