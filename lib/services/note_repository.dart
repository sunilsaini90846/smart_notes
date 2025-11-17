import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import 'encryption_service.dart';

class NoteRepository {
  static const String _boxName = 'notesBox';
  late Box<NoteModel> _box;
  final EncryptionService _encryptionService = EncryptionService();
  final Uuid _uuid = const Uuid();

  // Singleton pattern
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  static bool _isInitialized = false;
  static Future<void>? _initializationFuture;

  /// Initialize the Hive box
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    _initializationFuture = _initializeBox();
    await _initializationFuture;
  }

  Future<void> _initializeBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<NoteModel>(_boxName);
      } else {
        _box = await Hive.openBox<NoteModel>(_boxName);
      }
      _isInitialized = true;
    } catch (e) {
      // If there's an error, reset the initialization state
      _isInitialized = false;
      _initializationFuture = null;
      rethrow;
    }
  }

  /// Ensure box is open before operations
  Future<void> _ensureBoxOpen() async {
    if (!_isInitialized || !_box.isOpen) {
      _isInitialized = false;
      _initializationFuture = null;
      await initialize();
    }
  }

  /// Check if repository is initialized
  bool get isInitialized => _isInitialized && _box.isOpen;

  /// Get all notes
  List<NoteModel> getAllNotes() {
    return _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get a single note by ID
  NoteModel? getNoteById(String id) {
    // Use box.get() for direct key access - more efficient and consistent
    return _box.get(id);
  }

  /// Get notes by type
  List<NoteModel> getNotesByType(String type) {
    return _box.values.where((note) => note.type == type).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get notes by tag
  List<NoteModel> getNotesByTag(String tag) {
    return _box.values.where((note) {
      return note.tags != null && note.tags!.contains(tag);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Search notes by title or content
  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();

    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowercaseQuery);
      
      // For encrypted notes, we can only search by title
      if (note.isEncrypted) return titleMatch;
      
      // For non-encrypted notes, search in content too
      final contentMatch = note.content.toLowerCase().contains(lowercaseQuery);
      
      // Also search in tags
      final tagMatch = note.tags?.any(
        (tag) => tag.toLowerCase().contains(lowercaseQuery),
      ) ?? false;
      
      return titleMatch || contentMatch || tagMatch;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Create a new note
  Future<NoteModel> createNote({
    required String title,
    required String type,
    required String content,
    Map<String, dynamic>? meta,
    bool isEncrypted = false,
    String? password,
    List<String>? tags,
    String? color,
  }) async {
    await _ensureBoxOpen();
    
    final id = _uuid.v4();
    
    // Encrypt content if needed
    String finalContent = content;
    if (isEncrypted && password != null && password.isNotEmpty) {
      finalContent = _encryptionService.encryptContent(content, password);
    }

    final note = NoteModel.create(
      id: id,
      title: title,
      type: type,
      content: finalContent,
      meta: meta,
      isEncrypted: isEncrypted,
      tags: tags,
      color: color,
    );

    try {
      await _box.put(id, note);
      // Force flush to disk to prevent data loss
      await _box.flush();
      return note;
    } catch (e) {
      throw NoteRepositoryException('Failed to save note: $e');
    }
  }

  /// Update an existing note
  Future<void> updateNote(
    String id, {
    String? title,
    String? type,
    String? content,
    Map<String, dynamic>? meta,
    bool? isEncrypted,
    String? password,
    List<String>? tags,
    String? color,
  }) async {
    await _ensureBoxOpen();
    
    final existingNote = _box.get(id);
    if (existingNote == null) {
      throw NoteNotFoundException('Cannot update note: Note with id $id not found');
    }

    // Handle content encryption if needed
    String? finalContent = content;
    if (content != null && isEncrypted == true && password != null && password.isNotEmpty) {
      finalContent = _encryptionService.encryptContent(content, password);
    } else if (content != null && isEncrypted == false) {
      // If decrypting, content should already be decrypted
      finalContent = content;
    }

    final updatedNote = existingNote.copyWith(
      title: title,
      type: type,
      content: finalContent,
      meta: meta,
      isEncrypted: isEncrypted,
      updatedAt: DateTime.now(),
      tags: tags,
      color: color,
    );

    try {
      await _box.put(id, updatedNote);
      // Force flush to disk to prevent data loss
      await _box.flush();
    } catch (e) {
      throw NoteRepositoryException('Failed to update note: $e');
    }
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _ensureBoxOpen();
    
    try {
      await _box.delete(id);
      // Force flush to disk to prevent data loss
      await _box.flush();
    } catch (e) {
      throw NoteRepositoryException('Failed to delete note: $e');
    }
  }

  /// Delete multiple notes
  Future<void> deleteNotes(List<String> ids) async {
    await _ensureBoxOpen();
    
    try {
      await _box.deleteAll(ids);
      // Force flush to disk to prevent data loss
      await _box.flush();
    } catch (e) {
      throw NoteRepositoryException('Failed to delete notes: $e');
    }
  }

  /// Delete all notes (use with caution)
  Future<void> deleteAllNotes() async {
    await _ensureBoxOpen();
    
    try {
      await _box.clear();
      // Force flush to disk to prevent data loss
      await _box.flush();
    } catch (e) {
      throw NoteRepositoryException('Failed to clear all notes: $e');
    }
  }

  /// Decrypt note content
  String decryptNoteContent(NoteModel note, String password) {
    if (!note.isEncrypted) {
      return note.content;
    }
    return _encryptionService.decryptContent(note.content, password);
  }

  /// Verify password for encrypted note
  bool verifyNotePassword(NoteModel note, String password) {
    if (!note.isEncrypted) return true;
    return _encryptionService.verifyPassword(note.content, password);
  }

  /// Get all unique tags
  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _box.values) {
      if (note.tags != null) {
        tags.addAll(note.tags!);
      }
    }
    return tags.toList()..sort();
  }

  /// Get notes count by type
  Map<String, int> getNotesCountByType() {
    final counts = <String, int>{};
    for (final type in NoteType.all) {
      counts[type] = getNotesByType(type).length;
    }
    return counts;
  }

  /// Get total notes count
  int getTotalNotesCount() {
    return _box.length;
  }

  /// Export all notes to JSON
  List<Map<String, dynamic>> exportNotes() {
    return _box.values.map((note) => note.toJson()).toList();
  }

  /// Import notes from JSON
  Future<void> importNotes(List<Map<String, dynamic>> notesJson) async {
    await _ensureBoxOpen();
    
    try {
      for (final json in notesJson) {
        final note = NoteModel.fromJson(json);
        await _box.put(note.id, note);
      }
      // Force flush to disk after batch import
      await _box.flush();
    } catch (e) {
      throw NoteRepositoryException('Failed to import notes: $e');
    }
  }

  /// Close the box (call when app is closing)
  /// Note: Usually not needed as Hive manages lifecycle automatically
  Future<void> close() async {
    if (_box.isOpen) {
      await _box.close();
      _isInitialized = false;
    }
  }

  /// Compact the box (optimize storage)
  Future<void> compact() async {
    await _ensureBoxOpen();
    await _box.compact();
  }
}

class NoteNotFoundException implements Exception {
  final String message;
  NoteNotFoundException(this.message);

  @override
  String toString() => 'NoteNotFoundException: $message';
}

class NoteRepositoryException implements Exception {
  final String message;
  NoteRepositoryException(this.message);

  @override
  String toString() => 'NoteRepositoryException: $message';
}

