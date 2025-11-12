# Notes Manager 📝

A beautiful, modern, offline-first Notes App built with Flutter featuring glassmorphic design, bird-wing animations, and client-side encryption.

## ✨ Features

### 🎨 Beautiful UI
- **Glassmorphic Design**: Frosted glass effects with blur and soft shadows
- **Neumorphic Elements**: Soft, modern UI components
- **Bird-Wing Layout**: Unique home screen layout with animated note cards
- **Smooth Animations**: Fade, slide, and scale animations using flutter_animate
- **Dark Theme**: Eye-friendly dark theme with gradient backgrounds

### 📱 Note Types
1. **Plain Note** 📝 - Simple text notes
2. **Account Note** 👤 - Store account information (email, username, services)
3. **Password Note** 🔐 - Encrypted password storage
4. **Bank/Card Note** 💳 - Credit card and bank account details
5. **Subscription Note** 📅 - Track subscriptions and billing dates

### 🔒 Security
- **AES-GCM Encryption**: Military-grade encryption for secure notes
- **PBKDF2 Key Derivation**: Password-based encryption with 10,000 iterations
- **Client-Side Only**: All data encrypted locally, no server involvement
- **Password Protected**: Individual notes can be password-protected
- **Unlock Modal**: Beautiful UI to unlock encrypted notes

### 💾 Local Storage
- **Hive Database**: Fast, lightweight NoSQL database
- **Offline First**: Works completely offline
- **No Authentication**: No sign-up required
- **Local Persistence**: All data stored on device

### 🔍 Search & Filter
- **Real-Time Search**: Search notes by title, content, or tags
- **Type Filtering**: Filter notes by type
- **Tag System**: Organize notes with custom tags
- **Smart Results**: Instant search results as you type

### 📋 Note Management
- **CRUD Operations**: Create, Read, Update, Delete notes
- **Rich Metadata**: Track creation and update times
- **Tags**: Add multiple tags to organize notes
- **Copy to Clipboard**: Quick copy functionality
- **Batch Operations**: Delete multiple notes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.5.4 or higher)
- Dart SDK (3.5.4 or higher)
- Android Studio / VS Code with Flutter extensions
- For Android: Android SDK
- For Web: Chrome browser

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd notes_manager
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**

For Web:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d <device-id>
```

## 📦 Dependencies

```yaml
# Storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# Encryption
encrypt: ^5.0.3
crypto: ^3.0.3

# UI & Animations
flutter_animate: ^4.5.0
glassmorphism: ^3.0.0
blur: ^4.0.0

# Utilities
uuid: ^4.3.3
intl: ^0.19.0
```

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── note_model.dart      # Note data model with Hive adapter
├── services/
│   ├── encryption_service.dart  # AES-GCM encryption
│   └── note_repository.dart     # Hive CRUD operations
├── screens/
│   ├── home_screen.dart         # Bird-wing home layout
│   ├── note_editor_screen.dart  # Create/Edit notes
│   └── note_detail_screen.dart  # View note details
├── widgets/
│   └── glass_card.dart          # Reusable glass components
└── utils/
    └── app_theme.dart           # Theme and colors
```

## 🔐 Encryption Details

### Algorithm
- **Cipher**: AES-256 in GCM mode
- **Key Derivation**: PBKDF2 with SHA-256
- **Iterations**: 10,000
- **Salt**: 128-bit random salt per note
- **IV**: 128-bit random initialization vector

### Storage Format
Encrypted notes are stored as base64-encoded strings in the format:
```
base64(salt + iv + encrypted_data)
```

### Security Notes
- Passwords are never stored
- Each note has a unique salt and IV
- Decryption requires the correct password
- Wrong password cannot decrypt the content

## 🎨 UI Showcase

### Home Screen
- Bird-wing animated layout
- Glassmorphic note cards
- Search and filter functionality
- Floating action button for new notes

### Note Editor
- Type selector with visual icons
- Rich text input
- Encryption toggle
- Tag management
- Password protection

### Note Detail
- Beautiful card design
- Unlock modal for encrypted notes
- Copy to clipboard
- Edit and delete actions
- Metadata display

## 🌐 Platform Support

- ✅ **Android**: Full support
- ✅ **Web**: Full support (runs as static web app)
- ⚠️ **iOS**: Compatible but not tested
- ⚠️ **Desktop**: Compatible but not optimized

## 📝 Usage Examples

### Creating a Plain Note
1. Tap the "New Note" button
2. Select "Plain Note" type
3. Enter title and content
4. Optionally add tags
5. Tap "Create Note"

### Creating an Encrypted Note
1. Tap the "New Note" button
2. Select note type
3. Toggle "Encrypt this note"
4. Enter a strong password
5. Add content and save

### Unlocking an Encrypted Note
1. Tap on an encrypted note (🔒 icon)
2. Enter the password in the unlock modal
3. View and edit the decrypted content

## 🔧 Configuration

### Changing Theme Colors
Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6B4EFF);
static const Color secondaryColor = Color(0xFFFF6B9D);
```

### Adjusting Encryption
Edit `lib/services/encryption_service.dart`:
```dart
static const int _iterations = 10000; // Increase for more security
static const int _keyLength = 32;     // 256-bit key
```

## 🐛 Known Issues

- Test file needs Hive initialization for full testing
- Some const constructor suggestions in linter

## 🚧 Future Enhancements

- [ ] Biometric authentication
- [ ] Note sharing (encrypted)
- [ ] Cloud sync (optional)
- [ ] Rich text editor
- [ ] Image attachments
- [ ] Voice notes
- [ ] Note templates
- [ ] Dark/Light theme toggle
- [ ] Export/Import notes
- [ ] Note archiving

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Web:**
```bash
flutter build web --release
```

### Code Generation
After modifying models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
