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

  /// Initialize the Hive box
  Future<void> initialize() async {
    _box = await Hive.openBox<NoteModel>(_boxName);
  }

  /// Check if repository is initialized
  bool get isInitialized => Hive.isBoxOpen(_boxName);

  /// Get all notes
  List<NoteModel> getAllNotes() {
    return _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get a single note by ID
  NoteModel? getNoteById(String id) {
    return _box.values.firstWhere(
      (note) => note.id == id,
      orElse: () => throw NoteNotFoundException('Note with id $id not found'),
    );
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

    await _box.put(id, note);
    return note;
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
    final existingNote = getNoteById(id);
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

    await _box.put(id, updatedNote);
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  /// Delete multiple notes
  Future<void> deleteNotes(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  /// Delete all notes (use with caution)
  Future<void> deleteAllNotes() async {
    await _box.clear();
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
    for (final json in notesJson) {
      final note = NoteModel.fromJson(json);
      await _box.put(note.id, note);
    }
  }

  /// Close the box (call when app is closing)
  Future<void> close() async {
    await _box.close();
  }

  /// Compact the box (optimize storage)
  Future<void> compact() async {
    await _box.compact();
  }
}

class NoteNotFoundException implements Exception {
  final String message;
  NoteNotFoundException(this.message);

  @override
  String toString() => 'NoteNotFoundException: $message';
}

