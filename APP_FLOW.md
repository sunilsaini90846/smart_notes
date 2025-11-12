# App Flow & User Journey 🗺️

## 📱 Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        HOME SCREEN                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  My Notes                            [Search] [•••]  │   │
│  │  12 notes                                            │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  [All] [Plain] [Account] [Password] [Bank] [Sub]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │                                                       │   │
│  │     📝 Personal Notes                   [Left Wing]  │   │
│  │     Lorem ipsum dolor...                             │   │
│  │                                                       │   │
│  │                    🔐 Passwords    [Right Wing]      │   │
│  │                    🔒 Locked                         │   │
│  │                                                       │   │
│  │     💳 Bank Cards                   [Left Wing]      │   │
│  │     Chase •••• 1234                                  │   │
│  │                                                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                          [+ New Note]                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Tap Card
                              ▼
                    ┌─────────────────┐
                    │   Encrypted?    │
                    └─────────────────┘
                        │           │
                  Yes   │           │ No
                        ▼           ▼
            ┌──────────────┐   ┌──────────────┐
            │ UNLOCK MODAL │   │ NOTE DETAIL  │
            │              │   │              │
            │  🔒 Enter    │   │ [Copy] [Edit]│
            │  Password    │   │ [Delete]     │
            │              │   │              │
            │ [Cancel][OK] │   │ Content...   │
            └──────────────┘   │ Tags: #work  │
                    │           │ Created: ... │
             Valid  │           └──────────────┘
                    │                   │
                    ▼                   │
            ┌──────────────┐           │
            │ NOTE DETAIL  │           │
            │  (Unlocked)  │           │
            └──────────────┘           │
                    │                   │
                    └────────┬──────────┘
                            │
                      [Edit]│
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      NOTE EDITOR                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [←] Edit Note                                       │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Note Type:                                          │   │
│  │  [📝Plain] [👤Account] [🔐Password] [💳Bank] [📅Sub]│   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Title: _______________________________________      │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Content:                                            │   │
│  │  _____________________________________________       │   │
│  │  _____________________________________________       │   │
│  │  _____________________________________________       │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  🔒 Encrypt this note           [  Toggle  ]        │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Password (if encrypted):  _______________  👁       │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Tags: #work #personal #important                    │   │
│  │  Add tag: ___________ [+]                            │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │              [💾 Create/Update Note]                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                      [Save]  │
                              ▼
                    ┌─────────────────┐
                    │  Save to Hive   │
                    │   (Encrypted    │
                    │   if enabled)   │
                    └─────────────────┘
                              │
                              ▼
                        Back to Home
```

---

## 🎬 User Journeys

### Journey 1: Create a Simple Note

```
1. User opens app
   → Sees Home Screen with bird-wing layout
   
2. User taps "New Note" button
   → Navigate to Note Editor
   
3. User selects "Plain Note" type
   → Type chip highlighted
   
4. User enters title and content
   → Text fields filled
   
5. User adds tags (optional)
   → Tags displayed as chips
   
6. User taps "Create Note"
   → Saving animation shown
   → Note saved to Hive
   → Success message displayed
   → Return to Home
   
7. User sees new note on Home Screen
   → Note appears with slide animation
   → Positioned in bird-wing layout
```

### Journey 2: Create an Encrypted Note

```
1. User opens app and taps "New Note"
   
2. User selects "Password Note" type
   → Pink color theme applied
   
3. User enters title: "My Passwords"
   
4. User toggles "Encrypt this note" ON
   → Password field appears
   
5. User enters password: "SecurePass123"
   → Password hidden with dots
   → Toggle visibility available
   
6. User enters sensitive content
   
7. User taps "Create Note"
   → Content encrypted using AES-GCM
   → Encrypted note saved to Hive
   → Success message shown
   
8. User returns to Home Screen
   → Note displays with 🔒 lock icon
   → Content not visible
```

### Journey 3: View and Unlock Encrypted Note

```
1. User sees encrypted note on Home
   → Note shows "🔒 Tap to unlock"
   
2. User taps the encrypted note
   → Unlock modal appears
   → Glassmorphic dialog with blur
   
3. User enters password
   → Password field with visibility toggle
   
4a. Correct password:
   → Modal closes
   → Content decrypted
   → Note Detail screen shown
   → Content is selectable
   
4b. Incorrect password:
   → Error message shown
   → Modal stays open
   → User can retry
   
5. User can now:
   → Read decrypted content
   → Copy to clipboard
   → Edit the note
   → Delete the note
```

### Journey 4: Search and Filter Notes

```
1. User on Home Screen
   
2. User taps Search icon
   → Search bar slides in
   → Keyboard appears
   
3. User types "password"
   → Results filter in real-time
   → Only matching notes shown
   → Count updates
   
4. User taps "Password" filter chip
   → Further filters to password type
   → Combined with search query
   
5. User clears search
   → All notes reappear
   → Filter remains active
   
6. User taps "All" chip
   → All notes shown
   → Filter cleared
```

### Journey 5: Edit Existing Note

```
1. User taps a note card
   → Note Detail screen opens
   
2. User taps Edit icon
   → Note Editor opens
   → Fields pre-filled with data
   
3. User modifies content
   → Changes reflected in text fields
   
4. User adds new tags
   → Tags added to list
   
5. User taps "Update Note"
   → Note updated in Hive
   → Updated timestamp changed
   → Return to Detail screen
   
6. Changes visible immediately
```

### Journey 6: Delete Note

```
1. User opens Note Detail
   
2. User taps Delete icon
   → Confirmation modal appears
   → Warning message shown
   
3. User taps "Cancel"
   → Modal closes
   → Note remains
   
   OR
   
   User taps "Delete"
   → Note removed from Hive
   → Success message shown
   → Return to Home Screen
   → Note no longer visible
```

---

## 🎨 Animation Timeline

### Home Screen Load
```
Time    Animation
0ms     Background gradient fades in
200ms   Header "My Notes" slides in from left
300ms   Search icon scales in
400ms   Filter chips fade in
500ms   First note card slides from left
600ms   Second note card slides from right
700ms   Third note card slides from left
800ms   FAB button scales in
```

### Note Card Interaction
```
User taps card
├─ 0ms: Scale down to 0.95
├─ 100ms: Scale back to 1.0
├─ 150ms: Navigate to detail
└─ 200ms: Detail screen fades in
```

### Unlock Modal
```
Modal appears
├─ 0ms: Backdrop blur increases
├─ 100ms: Dialog scales from 0.8 to 1.0
├─ 200ms: Content fades in
└─ 300ms: Lock icon bounces
```

### Editor Screen
```
Screen opens
├─ 0ms: Background fades in
├─ 100ms: App bar scales in
├─ 200ms: Type selector slides down
├─ 300ms: Title field slides up
├─ 400ms: Content field slides up
├─ 500ms: Options slide in
└─ 600ms: Save button scales in
```

---

## 🔄 Data Flow

### Create Note Flow
```
User Input
    ↓
Form Validation
    ↓
Encryption (if enabled)
    ↓
Generate UUID
    ↓
Create NoteModel
    ↓
Save to Hive Box
    ↓
Update UI
    ↓
Show Success Message
```

### Encryption Flow
```
Password + Content
    ↓
Generate Salt (16 bytes)
    ↓
PBKDF2 Key Derivation (10,000 iterations)
    ↓
Generate IV (16 bytes)
    ↓
AES-GCM Encryption
    ↓
Combine: Salt + IV + Encrypted Data
    ↓
Base64 Encode
    ↓
Store in Hive
```

### Decryption Flow
```
Encrypted String from Hive
    ↓
Base64 Decode
    ↓
Extract Salt (first 16 bytes)
    ↓
Extract IV (next 16 bytes)
    ↓
Extract Encrypted Data (remaining)
    ↓
PBKDF2 with Password + Salt
    ↓
AES-GCM Decryption with Key + IV
    ↓
Return Plain Text
```

### Search Flow
```
User Types Query
    ↓
Convert to Lowercase
    ↓
Search in Title (all notes)
    ↓
Search in Content (non-encrypted)
    ↓
Search in Tags (all notes)
    ↓
Combine Results
    ↓
Apply Type Filter (if selected)
    ↓
Sort by Updated Date
    ↓
Display Results
```

---

## 📊 State Management

### Home Screen States
```
- Loading (initial)
- Empty (no notes)
- Loaded (with notes)
- Searching (search active)
- Filtered (filter applied)
- Error (if any)
```

### Editor States
```
- Creating (new note)
- Editing (existing note)
- Saving (in progress)
- Validating (checking input)
- Success (saved)
- Error (save failed)
```

### Note Detail States
```
- Locked (encrypted, not unlocked)
- Unlocking (password entry)
- Unlocked (decrypted content visible)
- Editing (in editor)
- Deleting (confirmation shown)
```

---

## 🎯 User Actions Summary

| Screen | Actions Available |
|--------|------------------|
| Home | View, Search, Filter, Create, Navigate |
| Editor | Input, Select Type, Toggle Encryption, Add Tags, Save |
| Detail | View, Copy, Edit, Delete, Unlock |
| Unlock Modal | Enter Password, Toggle Visibility, Submit, Cancel |

---

## 🔑 Key Interactions

1. **Tap** - Primary action (open, select, submit)
2. **Long Press** - Card animation feedback
3. **Swipe** - Dismiss modals/search
4. **Type** - Search, input content
5. **Toggle** - Switch encryption, password visibility
6. **Scroll** - Browse notes list

---

**Complete App Flow Documented! ✅**

