import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';
import 'note_editor_screen.dart';
import 'note_detail_screen.dart';
import 'sub_accounts_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final NoteRepository _repository = NoteRepository();
  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  String _searchQuery = '';
  String? _selectedType;
  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAndLoadNotes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Flush data to disk when app goes to background or is paused
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Close the Hive box properly to prevent data loss
      _repository.close();
    }
  }

  Future<void> _initializeAndLoadNotes() async {
    // Ensure repository is initialized
    await _repository.initialize();

    if (mounted) {
      setState(() {
        _notes = _repository.getAllNotes();
        _filterNotes();
        _isLoading = false;
      });
    }
  }

  void _loadNotes() {
    setState(() {
      _notes = _repository.getAllNotes();
      _filterNotes();
    });
  }

  void _filterNotes() {
    setState(() {
      _filteredNotes = _notes;

      if (_searchQuery.isNotEmpty) {
        _filteredNotes = _repository.searchNotes(_searchQuery);
      }

      if (_selectedType != null) {
        _filteredNotes = _filteredNotes
            .where((note) => note.type == _selectedType)
            .toList();
      }
    });
  }

  void _navigateToEditor({NoteModel? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          initialType: note == null ? _selectedType : null,
        ),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  void _navigateToDetail(NoteModel note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  void _navigateToSubAccounts(NoteModel note) async {
    if (note.meta == null || note.meta!['subAccounts'] == null) return;
    
    // Make a copy of sub-accounts
    final subAccounts = (note.meta!['subAccounts'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    
    // Get the appropriate name based on note type
    final mainAccountName = note.type == NoteType.bank
        ? (note.meta!['cardName']?.toString() ?? note.title)
        : (note.meta!['accountName']?.toString() ?? note.title);
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountsScreen(
          subAccounts: subAccounts,
          mainAccountName: mainAccountName,
          onSubAccountsChanged: (updatedSubAccounts) {
            // Update the note with new sub-accounts
            _updateNoteSubAccounts(note, updatedSubAccounts);
          },
        ),
      ),
    );

    // Reload notes after returning from sub-accounts screen
    _loadNotes();
  }

  void _addSubAccount(NoteModel note) async {
    // Get the appropriate name based on note type
    final mainAccountName = note.type == NoteType.bank
        ? (note.meta?['cardName']?.toString() ?? note.title)
        : (note.meta?['accountName']?.toString() ?? note.title);
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountEditorScreen(
          mainAccountName: mainAccountName,
        ),
      ),
    );

    if (result != null && mounted) {
      // Add the new sub-account to the note
      final meta = note.meta ?? {};
      final subAccounts = List<Map<String, dynamic>>.from(
        meta['subAccounts'] as List? ?? [],
      );
      subAccounts.add(result);
      
      _updateNoteSubAccounts(note, subAccounts);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sub-account added'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _updateNoteSubAccounts(NoteModel note, List<Map<String, dynamic>> subAccounts) async {
    // Deep copy the meta to avoid reference issues
    final meta = _deepCopyMap(note.meta ?? {});
    // Deep copy sub-accounts as well
    meta['subAccounts'] = subAccounts.map((sa) => Map<String, dynamic>.from(sa)).toList();
    
    await _repository.updateNote(
      note.id,
      meta: meta,
    );
    
    _loadNotes();
  }

  /// Deep copy a map to avoid reference issues
  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> original) {
    final copy = <String, dynamic>{};
    original.forEach((key, value) {
      if (value is Map) {
        copy[key] = _deepCopyMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        copy[key] = List.from(value.map((e) => 
          e is Map ? _deepCopyMap(Map<String, dynamic>.from(e)) : e
        ));
      } else {
        copy[key] = value;
      }
    });
    return copy;
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
              _buildHeader(),
              if (_isSearching) _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _filteredNotes.isEmpty
                        ? _buildEmptyState()
                        : _buildBirdWingLayout(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ).animate().scale(delay: 800.ms, duration: 300.ms),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Notes',
                  style: AppTheme.headingLarge,
                ).animate().fadeIn().slideX(begin: -0.2, duration: 400.ms),
                Text(
                  '${_filteredNotes.length} ${_filteredNotes.length == 1 ? 'note' : 'notes'}',
                  style: AppTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _filterNotes();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white54),
          ),
          onChanged: (value) {
            _searchQuery = value;
            _filterNotes();
          },
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.5, duration: 300.ms);
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('All', null),
          ...NoteType.all.map((type) => _buildFilterChip(
                NoteType.getDisplayName(type),
                type,
              )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null) Text('${NoteType.getIcon(type)} '),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
            _filterNotes();
          });
        },
        backgroundColor: AppTheme.surfaceColor.withOpacity(0.3),
        selectedColor: AppTheme.primaryColor.withOpacity(0.5),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildBirdWingLayout() {
    // Split notes into two wings (left and right)
    final halfCount = (_filteredNotes.length / 2).ceil();
    final leftWing = _filteredNotes.take(halfCount).toList();
    final rightWing = _filteredNotes.skip(halfCount).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Interleave left and right wing notes for the bird-wing effect
        for (int i = 0; i < math.max(leftWing.length, rightWing.length); i++)
          Column(
            children: [
              if (i < leftWing.length)
                _buildNoteCard(leftWing[i], isLeft: true, index: i),
              if (i < rightWing.length)
                _buildNoteCard(rightWing[i], isLeft: false, index: i),
            ],
          ),
      ],
    );
  }

  Widget _buildNoteCard(NoteModel note, {required bool isLeft, required int index}) {
    final color = AppTheme.getColorByType(note.type);
    final delay = (index * 100).ms;
    final isAccountNote = note.type == NoteType.account;
    final isBankNote = note.type == NoteType.bank;
    final subAccountsCount = (isAccountNote || isBankNote) && note.meta != null && note.meta!['subAccounts'] != null
        ? (note.meta!['subAccounts'] as List).length
        : 0;

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 20,
            left: isLeft ? 0 : 30,
            right: isLeft ? 30 : 0,
          ),
          child: Stack(
            children: [
              AnimatedGlassCard(
                onTap: () => _navigateToDetail(note),
                gradient: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                NoteType.getIcon(note.type),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                NoteType.getDisplayName(note.type),
                                style: AppTheme.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (note.isEncrypted)
                          const Icon(
                            Icons.lock,
                            size: 16,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      note.title,
                      style: AppTheme.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (!note.isEncrypted)
                      Text(
                        note.content,
                        style: AppTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to unlock',
                            style: AppTheme.caption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(note.updatedAt),
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: delay, duration: 400.ms)
                  .slideX(
                    begin: isLeft ? -0.3 : 0.3,
                    delay: delay,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
              // Action buttons for Account and Bank notes
              if (isAccountNote || isBankNote)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View all sub-accounts/sub-cards button
                      if (subAccountsCount > 0) ...[
                        InkWell(
                          onTap: () => _navigateToSubAccounts(note),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  isBankNote ? Icons.credit_card : Icons.account_tree,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.surfaceColor,
                                        width: 1,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Center(
                                      child: Text(
                                        subAccountsCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().scale(delay: delay + 100.ms),
                        const SizedBox(width: 6),
                      ],
                      // Add sub-account/sub-card button
                      InkWell(
                        onTap: () => _addSubAccount(note),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().scale(delay: delay + 150.ms),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
          Text(
            'Loading notes...',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 100,
            color: Colors.white.withOpacity(0.2),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),
          Text(
            'No notes yet',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white.withOpacity(0.4),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 10),
          Text(
            'Tap the button below to create your first note',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.3),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    // Close Hive box when screen is disposed
    _repository.close();
    super.dispose();
  }
}

