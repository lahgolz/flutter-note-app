import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;

    notifyListeners();

    _notes = await _dbService.getAllNotes();
    _isLoading = false;

    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _dbService.insertNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _dbService.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _dbService.deleteNote(id);
    await loadNotes();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}
