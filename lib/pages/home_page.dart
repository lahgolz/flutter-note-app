import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final popoverController = ShadPopoverController();
  final searchController = TextEditingController();
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'First Note',
      content: 'This is the content of the first note.',
      type: NoteType.text,
    ),
    Note(
      id: '2',
      title: 'Second Note',
      content: 'This is the content of the second note.',
      type: NoteType.text,
    ),
  ];
  String _searchQuery = '';

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
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Note',
      content: '',
      type: NoteType.text,
    );

    setState(() {
      _notes.add(newNote);
    });
    popoverController.hide();
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
              child: _filteredNotes.isEmpty
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
            // TODO: Navigate to note editor
          },
        );
      },
    );
  }
}
