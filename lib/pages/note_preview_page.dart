import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/note.dart';
import 'note_editor_page.dart';

class NotePreviewPage extends StatefulWidget {
  final Note note;

  const NotePreviewPage({super.key, required this.note});

  @override
  State<NotePreviewPage> createState() => _NotePreviewPageState();
}

class _NotePreviewPageState extends State<NotePreviewPage> {
  late Note _currentNote;

  @override
  void initState() {
    super.initState();

    _currentNote = widget.note;
  }

  void _navigateToEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(note: _currentNote),
      ),
    ).then((result) {
      if (result == null || !mounted) {
        return;
      }

      setState(() {
        _currentNote = result;
      });
    });
  }

  Widget _build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentNote.title),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.foreground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _currentNote.content.isNotEmpty
                      ? _currentNote.content
                      : 'No content',
                  style: _currentNote.content.isNotEmpty
                      ? theme.textTheme.p
                      : theme.textTheme.muted,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ShadButton(
                leading: const Icon(LucideIcons.pencil, size: 16),
                onPressed: _navigateToEditor,
                child: const Text('Edit Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: _build);
  }
}
