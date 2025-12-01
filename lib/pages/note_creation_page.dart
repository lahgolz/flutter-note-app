import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/note.dart';
import '../services/database_service.dart';

class NoteCreationPage extends StatefulWidget {
  const NoteCreationPage({super.key});

  @override
  State<NoteCreationPage> createState() => _NoteCreationPageState();
}

class _NoteCreationPageState extends State<NoteCreationPage> {
  final _formKey = GlobalKey<ShadFormState>();
  final _dbService = DatabaseService();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() => _isSaving = true);

    final values = _formKey.currentState!.value;
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: values['title'] as String,
      content: values['content'] as String? ?? '',
      type: NoteType.text,
    );

    await _dbService.insertNote(note);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
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
