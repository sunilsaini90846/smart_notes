import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/models/note_model.dart';

void main() {
  group('NoteModel', () {
    test('should create a note with all required fields', () {
      final note = NoteModel.create(
        id: 'test-id',
        title: 'Test Note',
        type: NoteType.plain,
        content: 'Test content',
      );

      expect(note.id, equals('test-id'));
      expect(note.title, equals('Test Note'));
      expect(note.type, equals(NoteType.plain));
      expect(note.content, equals('Test content'));
      expect(note.isEncrypted, isFalse);
      expect(note.createdAt, isNotNull);
      expect(note.updatedAt, isNotNull);
    });

    test('should create encrypted note', () {
      final note = NoteModel.create(
        id: 'encrypted-id',
        title: 'Secret Note',
        type: NoteType.plain,
        content: 'encrypted-content',
        isEncrypted: true,
      );

      expect(note.isEncrypted, isTrue);
    });

    test('should create note with metadata', () {
      final meta = {
        'accountName': 'Test Account',
        'username': 'test@example.com',
      };

      final note = NoteModel.create(
        id: 'meta-id',
        title: 'Account Note',
        type: NoteType.account,
        content: 'Account details',
        meta: meta,
      );

      expect(note.meta, isNotNull);
      expect(note.meta!['accountName'], equals('Test Account'));
      expect(note.meta!['username'], equals('test@example.com'));
    });

    test('should create note with tags', () {
      final tags = ['important', 'work', 'project'];

      final note = NoteModel.create(
        id: 'tags-id',
        title: 'Tagged Note',
        type: NoteType.plain,
        content: 'Content with tags',
        tags: tags,
      );

      expect(note.tags, isNotNull);
      expect(note.tags!.length, equals(3));
      expect(note.tags, containsAll(['important', 'work', 'project']));
    });

    test('copyWith should create modified copy', () {
      final original = NoteModel.create(
        id: 'original-id',
        title: 'Original Title',
        type: NoteType.plain,
        content: 'Original content',
      );

      final modified = original.copyWith(
        title: 'Modified Title',
        content: 'Modified content',
      );

      expect(modified.id, equals(original.id));
      expect(modified.title, equals('Modified Title'));
      expect(modified.content, equals('Modified content'));
      expect(modified.type, equals(original.type));
      expect(modified.createdAt, equals(original.createdAt));
    });

    test('copyWith should keep original values if not specified', () {
      final original = NoteModel.create(
        id: 'original-id',
        title: 'Original Title',
        type: NoteType.plain,
        content: 'Original content',
      );

      final modified = original.copyWith(title: 'New Title');

      expect(modified.content, equals('Original content'));
      expect(modified.type, equals(NoteType.plain));
    });

    test('toJson should serialize note correctly', () {
      final note = NoteModel.create(
        id: 'json-id',
        title: 'JSON Note',
        type: NoteType.account,
        content: 'JSON content',
        tags: ['tag1', 'tag2'],
      );

      final json = note.toJson();

      expect(json['id'], equals('json-id'));
      expect(json['title'], equals('JSON Note'));
      expect(json['type'], equals(NoteType.account));
      expect(json['content'], equals('JSON content'));
      expect(json['tags'], isA<List>());
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('fromJson should deserialize note correctly', () {
      final json = {
        'id': 'from-json-id',
        'title': 'From JSON',
        'type': NoteType.bank,
        'content': 'JSON deserialized content',
        'isEncrypted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'tags': ['test'],
      };

      final note = NoteModel.fromJson(json);

      expect(note.id, equals('from-json-id'));
      expect(note.title, equals('From JSON'));
      expect(note.type, equals(NoteType.bank));
      expect(note.content, equals('JSON deserialized content'));
      expect(note.tags, equals(['test']));
    });

    test('should handle null optional fields', () {
      final note = NoteModel.create(
        id: 'null-fields-id',
        title: 'Note',
        type: NoteType.plain,
        content: 'Content',
      );

      expect(note.meta, isNull);
      expect(note.tags, isNull);
      expect(note.color, isNull);
    });
  });

  group('NoteType', () {
    test('should have all note types defined', () {
      expect(NoteType.plain, equals('plain'));
      expect(NoteType.account, equals('account'));
      expect(NoteType.bank, equals('bank'));
      expect(NoteType.subscription, equals('subscription'));
    });

    test('should return all types', () {
      final allTypes = NoteType.all;

      expect(allTypes.length, equals(4));
      expect(allTypes, contains(NoteType.plain));
      expect(allTypes, contains(NoteType.account));
      expect(allTypes, contains(NoteType.bank));
      expect(allTypes, contains(NoteType.subscription));
    });

    test('should get correct display name for each type', () {
      expect(NoteType.getDisplayName(NoteType.plain), equals('Plain Note'));
      expect(NoteType.getDisplayName(NoteType.account), equals('Account'));
      expect(NoteType.getDisplayName(NoteType.bank), equals('Bank / Card'));
      expect(
        NoteType.getDisplayName(NoteType.subscription),
        equals('Subscription'),
      );
    });

    test('should get default display name for unknown type', () {
      expect(NoteType.getDisplayName('unknown'), equals('Note'));
    });

    test('should get correct icon for each type', () {
      expect(NoteType.getIcon(NoteType.plain), equals('📝'));
      expect(NoteType.getIcon(NoteType.account), equals('👤'));
      expect(NoteType.getIcon(NoteType.bank), equals('💳'));
      expect(NoteType.getIcon(NoteType.subscription), equals('📅'));
    });

    test('should get default icon for unknown type', () {
      expect(NoteType.getIcon('unknown'), equals('📄'));
    });
  });

  group('NoteModel - Edge Cases', () {
    test('should handle empty strings', () {
      final note = NoteModel.create(
        id: 'empty-id',
        title: '',
        type: NoteType.plain,
        content: '',
      );

      expect(note.title, equals(''));
      expect(note.content, equals(''));
    });

    test('should handle very long content', () {
      final longContent = 'a' * 10000;
      final note = NoteModel.create(
        id: 'long-id',
        title: 'Long Note',
        type: NoteType.plain,
        content: longContent,
      );

      expect(note.content.length, equals(10000));
    });

    test('should handle special characters in content', () {
      final specialContent = '!@#\$%^&*()_+-={}[]|\\:";\'<>?,./\n\t';
      final note = NoteModel.create(
        id: 'special-id',
        title: 'Special',
        type: NoteType.plain,
        content: specialContent,
      );

      expect(note.content, equals(specialContent));
    });

    test('should handle unicode characters', () {
      final unicodeContent = '你好世界 🌍 مرحبا العالم';
      final note = NoteModel.create(
        id: 'unicode-id',
        title: 'Unicode',
        type: NoteType.plain,
        content: unicodeContent,
      );

      expect(note.content, equals(unicodeContent));
    });

    test('should handle complex nested metadata', () {
      final complexMeta = {
        'level1': {
          'level2': {
            'level3': ['item1', 'item2', 'item3'],
          },
        },
        'array': [1, 2, 3, 4, 5],
        'boolean': true,
        'null': null,
      };

      final note = NoteModel.create(
        id: 'complex-id',
        title: 'Complex',
        type: NoteType.plain,
        content: 'Content',
        meta: complexMeta,
      );

      expect(note.meta, isNotNull);
      expect(note.meta!['level1'], isA<Map>());
      expect(note.meta!['array'], isA<List>());
      expect(note.meta!['boolean'], isTrue);
    });
  });

  group('NoteModel - Serialization Round Trip', () {
    test('should maintain data integrity through serialization', () {
      final original = NoteModel.create(
        id: 'round-trip-id',
        title: 'Round Trip Test',
        type: NoteType.account,
        content: 'Test content',
        tags: ['tag1', 'tag2'],
        isEncrypted: true,
        meta: {'key': 'value'},
      );

      final json = original.toJson();
      final deserialized = NoteModel.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.title, equals(original.title));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.content, equals(original.content));
      expect(deserialized.isEncrypted, equals(original.isEncrypted));
      expect(deserialized.tags, equals(original.tags));
    });
  });
}

