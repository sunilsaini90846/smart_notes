import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String type; // plain, account, password, bank, subscription

  @HiveField(3)
  String content; // encrypted if isEncrypted is true

  @HiveField(4)
  Map<String, dynamic>? meta;

  @HiveField(5)
  bool isEncrypted;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  List<String>? tags;

  @HiveField(9)
  String? color;

  NoteModel({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.meta,
    this.isEncrypted = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
    this.color,
  });

  // Factory constructor for creating a new note
  factory NoteModel.create({
    required String id,
    required String title,
    required String type,
    required String content,
    Map<String, dynamic>? meta,
    bool isEncrypted = false,
    List<String>? tags,
    String? color,
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: id,
      title: title,
      type: type,
      content: content,
      meta: meta,
      isEncrypted: isEncrypted,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      color: color,
    );
  }

  // Create a copy with updated fields
  NoteModel copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
    Map<String, dynamic>? meta,
    bool? isEncrypted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      meta: meta ?? this.meta,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'meta': meta,
      'isEncrypted': isEncrypted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'color': color,
    };
  }

  // Create from JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      content: json['content'],
      meta: json['meta'],
      isEncrypted: json['isEncrypted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      color: json['color'],
    );
  }
}

// Note type constants
class NoteType {
  static const String plain = 'plain';
  static const String account = 'account';
  static const String password = 'password';
  static const String bank = 'bank';
  static const String subscription = 'subscription';

  static List<String> get all => [plain, account, bank, subscription];

  static String getDisplayName(String type) {
    switch (type) {
      case plain:
        return 'Plain Note';
      case account:
        return 'Account';
      case password:
        return 'Password';
      case bank:
        return 'Bank / Card';
      case subscription:
        return 'Subscription';
      default:
        return 'Note';
    }
  }

  static String getIcon(String type) {
    switch (type) {
      case plain:
        return '📝';
      case account:
        return '👤';
      case password:
        return '🔐';
      case bank:
        return '💳';
      case subscription:
        return '📅';
      default:
        return '📄';
    }
  }
}

