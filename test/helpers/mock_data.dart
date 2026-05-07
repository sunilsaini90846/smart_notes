import 'package:account_note_book/models/note_model.dart';

/// Mock notes for testing
class MockNoteData {
  /// Create a plain note
  static NoteModel createPlainNote({
    String? id,
    String? title,
    String? content,
  }) {
    return NoteModel.create(
      id: id ?? 'test-plain-note-1',
      title: title ?? 'Test Plain Note',
      type: NoteType.plain,
      content: content ?? 'This is a test plain note content',
    );
  }

  /// Create an account note
  static NoteModel createAccountNote({
    String? id,
    String? title,
    bool withSubAccounts = false,
  }) {
    final meta = <String, dynamic>{
      'accountName': title ?? 'Test Account',
      'username': 'testuser@example.com',
      'password': 'testpass123',
    };

    if (withSubAccounts) {
      meta['subAccounts'] = <Map<String, dynamic>>[
        {
          'name': 'Sub Account 1',
          'username': 'sub1@example.com',
          'password': 'sub1pass',
          'notes': 'Test sub account 1',
        },
        {
          'name': 'Sub Account 2',
          'username': 'sub2@example.com',
          'password': 'sub2pass',
          'notes': 'Test sub account 2',
        },
      ];
    }

    return NoteModel.create(
      id: id ?? 'test-account-note-1',
      title: title ?? 'Test Account',
      type: NoteType.account,
      content: 'Account details',
      meta: meta,
    );
  }

  /// Create a bank note
  static NoteModel createBankNote({
    String? id,
    String? title,
    bool withLinkedCards = false,
  }) {
    final meta = <String, dynamic>{
      'cardName': title ?? 'Test Bank Card',
      'cardNumber': '1234 5678 9012 3456',
      'cvv': '123',
      'expiryMonth': '12',
      'expiryYear': '2025',
    };

    if (withLinkedCards) {
      meta['subAccounts'] = <Map<String, dynamic>>[
        {
          'name': 'Virtual Card 1',
          'cardNumber': '9876 5432 1098 7654',
          'cvv': '456',
        },
      ];
    }

    return NoteModel.create(
      id: id ?? 'test-bank-note-1',
      title: title ?? 'Test Bank Card',
      type: NoteType.bank,
      content: 'Bank card details',
      meta: meta,
    );
  }

  /// Create an encrypted note
  static NoteModel createEncryptedNote({
    String? id,
    String? title,
  }) {
    return NoteModel.create(
      id: id ?? 'test-encrypted-note-1',
      title: title ?? 'Test Encrypted Note',
      type: NoteType.plain,
      content: 'encrypted_content_hash',
      isEncrypted: true,
    );
  }

  /// Create a subscription note
  static NoteModel createSubscriptionNote({
    String? id,
    String? title,
  }) {
    return NoteModel.create(
      id: id ?? 'test-subscription-note-1',
      title: title ?? 'Test Subscription',
      type: NoteType.subscription,
      content: 'Subscription details',
      meta: {
        'serviceName': 'Netflix',
        'plan': 'Premium',
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      },
    );
  }

  /// Create a list of mixed notes
  static List<NoteModel> createMixedNotes() {
    return [
      createPlainNote(id: 'plain-1', title: 'Note 1'),
      createAccountNote(id: 'account-1', title: 'Gmail Account'),
      createBankNote(id: 'bank-1', title: 'Chase Card'),
      createEncryptedNote(id: 'encrypted-1', title: 'Secret Note'),
      createSubscriptionNote(id: 'subscription-1', title: 'Netflix'),
    ];
  }

  /// Create notes with specific content for search testing
  static List<NoteModel> createNotesForSearch() {
    return [
      createPlainNote(
        id: 'search-1',
        title: 'Shopping List',
        content: 'Buy groceries and household items',
      ),
      createPlainNote(
        id: 'search-2',
        title: 'Meeting Notes',
        content: 'Discuss project timeline and budget',
      ),
      createAccountNote(
        id: 'search-3',
        title: 'Gmail Account',
      ),
    ];
  }
}

