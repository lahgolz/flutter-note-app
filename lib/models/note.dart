enum NoteType { text }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteType type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
  });
}
