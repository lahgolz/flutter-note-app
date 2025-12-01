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

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content, 'type': type.name};
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: NoteType.values.firstWhere((type) => type.name == map['type']),
    );
  }
}
