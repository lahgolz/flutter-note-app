import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/note.dart';
import '../services/database_service.dart';
import 'note_creation_page.dart';
import 'note_preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final popoverController = ShadPopoverController();
  final searchController = TextEditingController();
  final _dbService = DatabaseService();
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    final notes = await _dbService.getAllNotes();

    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    popoverController.dispose();
    searchController.dispose();

    super.dispose();
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }

    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _createTextNote() {
    popoverController.hide();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteCreationPage()),
    ).then((result) {
      if (!mounted) {
        return;
      }

      _loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ShadInput(
                controller: searchController,
                placeholder: const Text('Search notes...'),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    LucideIcons.search,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? _buildSkeletonList()
                  : _filteredNotes.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildNotesList(),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: ShadPopover(
                controller: popoverController,
                popover: (context) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note Type',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ShadButton.ghost(
                        leading: Icon(LucideIcons.fileText, size: 16),
                        onPressed: _createTextNote,
                        child: const Text('Text'),
                      ),
                    ],
                  ),
                ),
                child: ShadButton(
                  width: double.infinity,
                  leading: Icon(LucideIcons.plus, size: 16),
                  onPressed: popoverController.toggle,
                  child: const Text('Create Note'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ShadThemeData theme) {
    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? LucideIcons.searchX : LucideIcons.notebookPen,
            size: 64,
            color: theme.colorScheme.mutedForeground,
          ),

          const SizedBox(height: 16),

          Text(
            isSearching ? 'No notes found' : 'No notes yet',
            style: theme.textTheme.h4,
          ),

          const SizedBox(height: 8),

          Text(
            isSearching
                ? 'Try a different search term'
                : 'Create your first note to get started',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredNotes.length,
      separatorBuilder: (context, index) => const ShadSeparator.horizontal(),
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];

        return ListTile(
          leading: Icon(LucideIcons.fileText, size: 20),
          title: Text(note.title),
          subtitle: note.content.isNotEmpty
              ? Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotePreviewPage(note: note),
              ),
            ).then((result) {
              if (result == true && mounted) {
                _loadNotes();
              }
            });
          },
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    final theme = ShadTheme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (context, index) => const ShadSeparator.horizontal(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
