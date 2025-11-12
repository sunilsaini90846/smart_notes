# Quick Start Guide 🚀

## Running the App

### Web (Recommended for Testing)
```bash
flutter run -d chrome
```

### Android
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## First Time Setup

After cloning the project:

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d chrome
```

## Key Features to Try

### 1. Create Your First Note
- Tap the **"New Note"** floating action button
- Choose a note type (Plain, Account, Password, Bank, or Subscription)
- Enter a title and content
- Tap **"Create Note"**

### 2. Add an Encrypted Note
- Create a new note
- Toggle **"Encrypt this note"** switch
- Enter a password (minimum 6 characters)
- Save the note
- Note will display with a 🔒 lock icon

### 3. Search and Filter
- Tap the **search icon** in the top right
- Type to search by title, content, or tags
- Use filter chips to filter by note type
- Tap **X** to close search

### 4. View Note Details
- Tap any note card to view details
- For encrypted notes: enter password to unlock
- Use action buttons to:
  - **Copy** content to clipboard
  - **Edit** the note
  - **Delete** the note

### 5. Organize with Tags
- When creating/editing a note
- Scroll to the **Tags** section
- Type a tag name and press Enter or tap **+**
- Tags appear on note cards and are searchable

## App Structure

```
Home Screen → Note Editor → Save
     ↓
Note Card → Note Detail → Edit/Delete
     ↓
Encrypted? → Unlock Modal → View Content
```

## Tips & Tricks

### Security
- **Use strong passwords** for encrypted notes
- Passwords are not recoverable if forgotten
- Each encrypted note needs its own password

### Organization
- Use **tags** to categorize notes
- Different note types have different colors
- Filter by type for quick access

### Bird-Wing Animation
- Notes are displayed in alternating left-right layout
- Creates a beautiful wing-like effect on home screen
- Animates smoothly on scroll and load

### Gestures
- **Tap** to view note details
- **Long press** on cards for subtle animation
- **Swipe** to dismiss search

## Common Actions

### Copy Note Content
1. Open note detail
2. Tap copy icon (top right)
3. Content copied to clipboard

### Delete Multiple Notes
Currently, delete notes individually:
1. Open note detail
2. Tap delete icon
3. Confirm deletion

### Change Note Type
1. Open note in editor
2. Select different type from type selector
3. Save changes

### Unlock Encrypted Note
1. Tap encrypted note (has 🔒 icon)
2. Enter password in modal
3. Tap "Unlock"
4. Wrong password? Try again

## Keyboard Shortcuts (Web)

- `Tab` - Navigate between fields
- `Enter` - Submit forms (in password fields)
- `Esc` - Close modals/dialogs

## Performance Tips

- App stores all data locally (no network needed)
- Unlimited notes (within device storage)
- Instant search (no lag)
- Smooth animations (60 FPS)

## Troubleshooting

### App won't build?
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive error?
Delete app data and restart:
```bash
flutter clean
```

### Notes not showing?
Check if notes box is initialized in main.dart

### Encryption error?
- Verify password is correct
- Password is case-sensitive
- Cannot recover if password is lost

## Data Location

### Web
- Browser localStorage
- IndexedDB
- Clear browser data to reset

### Android
- `/data/data/com.example.notes_manager/`
- App data directory
- Uninstall to reset

## Next Steps

1. ✅ Create different types of notes
2. ✅ Test encryption feature
3. ✅ Try search and filtering
4. ✅ Add tags to organize notes
5. ✅ Experience smooth animations

## Need Help?

- Check README.md for detailed documentation
- Review code comments in source files
- Open an issue on GitHub

---

**Happy Note Taking! 📝**

