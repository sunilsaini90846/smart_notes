import 'package:account_note_book/models/note_model.dart';
import 'package:account_note_book/services/note_repository.dart';

/// Mock implementation of NoteRepository for testing
class MockNoteRepository implements NoteRepository {
  List<NoteModel> _notes = [];
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  /// Set mock notes for testing
  void setMockNotes(List<NoteModel> notes) {
    _notes = notes;
  }

  @override
  List<NoteModel> getAllNotes() {
    return List.from(_notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  NoteModel? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<NoteModel> getNotesByType(String type) {
    return _notes.where((note) => note.type == type).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();

    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowercaseQuery);
      if (note.isEncrypted) return titleMatch;

      final contentMatch = note.content.toLowerCase().contains(lowercaseQuery);
      final tagMatch =
          note.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ??
              false;

      return titleMatch || contentMatch || tagMatch;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
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
    final note = NoteModel.create(
      id: 'mock-id-${_notes.length}',
      title: title,
      type: type,
      content: content,
      meta: meta,
      isEncrypted: isEncrypted,
      tags: tags,
      color: color,
    );
    _notes.add(note);
    return note;
  }

  @override
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
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) {
      throw NoteNotFoundException('Note not found: $id');
    }

    final existingNote = _notes[index];
    _notes[index] = existingNote.copyWith(
      title: title,
      type: type,
      content: content,
      meta: meta,
      isEncrypted: isEncrypted,
      updatedAt: DateTime.now(),
      tags: tags,
      color: color,
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<void> deleteAllNotes() async {
    _notes.clear();
  }

  @override
  Future<void> close() async {
    _isInitialized = false;
  }

  // Implement other required methods with default/mock behavior
  @override
  Future<void> compact() async {}

  @override
  String decryptNoteContent(NoteModel note, String password) {
    return note.content;
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    _notes.removeWhere((note) => ids.contains(note.id));
  }

  @override
  List<Map<String, dynamic>> exportNotes() {
    return _notes.map((note) => note.toJson()).toList();
  }

  @override
  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _notes) {
      if (note.tags != null) {
        tags.addAll(note.tags!);
      }
    }
    return tags.toList()..sort();
  }

  @override
  Map<String, int> getNotesCountByType() {
    final counts = <String, int>{};
    for (final type in NoteType.all) {
      counts[type] = getNotesByType(type).length;
    }
    return counts;
  }

  @override
  int getTotalNotesCount() {
    return _notes.length;
  }

  @override
  Future<void> importNotes(List<Map<String, dynamic>> notesJson) async {
    for (final json in notesJson) {
      _notes.add(NoteModel.fromJson(json));
    }
  }

  @override
  bool verifyNotePassword(NoteModel note, String password) {
    return true;
  }

  @override
  List<NoteModel> getNotesByTag(String tag) {
    return _notes.where((note) {
      return note.tags != null && note.tags!.contains(tag);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}

