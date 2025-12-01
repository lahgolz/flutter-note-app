import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/note.dart';
import '../services/database_service.dart';

class NoteEditorPage extends StatefulWidget {
  final Note note;

  const NoteEditorPage({super.key, required this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<ShadFormState>();
  final _dbService = DatabaseService();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() => _isSaving = true);

    final values = _formKey.currentState!.value;
    final updatedNote = Note(
      id: widget.note.id,
      title: values['title'] as String,
      content: values['content'] as String? ?? '',
      type: widget.note.type,
    );

    await _dbService.updateNote(updatedNote);

    if (mounted) {
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Note updated'),
          description: const Text('Your changes have been saved.'),
        ),
      );

      Navigator.pop(context, updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.foreground,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadInputFormField(
                  id: 'title',
                  label: const Text('Title'),
                  placeholder: const Text('Enter note title'),
                  initialValue: widget.note.title,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Title is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ShadTextareaFormField(
                    id: 'content',
                    label: const Text('Content'),
                    placeholder: const Text('Write your note here...'),
                    initialValue: widget.note.content,
                  ),
                ),
                const SizedBox(height: 16),
                ShadButton(
                  onPressed: _isSaving ? null : _saveNote,
                  enabled: !_isSaving,
                  leading: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.save, size: 16),
                  child: Text(_isSaving ? 'Saving...' : 'Save Note'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
