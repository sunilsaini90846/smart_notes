import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

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
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  bool _isSaving = false;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _selectedType = widget.note!.type;
      _isEncrypted = widget.note!.isEncrypted;
      _tags = List.from(widget.note!.tags ?? []);

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
      if (widget.note == null) {
        // Create new note
        await _repository.createNote(
          title: _titleController.text,
          type: _selectedType,
          content: _contentController.text,
          isEncrypted: _isEncrypted,
          password: _isEncrypted ? _passwordController.text : null,
          tags: _tags.isEmpty ? null : _tags,
        );
      } else {
        // Update existing note
        await _repository.updateNote(
          widget.note!.id,
          title: _titleController.text,
          type: _selectedType,
          content: _contentController.text,
          isEncrypted: _isEncrypted,
          password: _isEncrypted ? _passwordController.text : null,
          tags: _tags.isEmpty ? null : _tags,
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

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        if (!_tags.contains(_tagController.text)) {
          _tags.add(_tagController.text);
        }
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
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
                        const SizedBox(height: 20),
                        _buildTagsSection(),
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
        decoration: const InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.title, color: Colors.white70),
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

    return GlassCard(
      child: TextFormField(
        controller: _contentController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        maxLines: 10,
        decoration: const InputDecoration(
          labelText: 'Content',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          alignLabelWithHint: true,
          icon: Icon(Icons.notes, color: Colors.white70),
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
          border: InputBorder.none,
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

  Widget _buildTagsSection() {
    return GlassCard(
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a tag',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              IconButton(
                onPressed: _addTag,
                icon: const Icon(Icons.add, color: Colors.white70),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.2);
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
    _tagController.dispose();
    super.dispose();
  }
}

