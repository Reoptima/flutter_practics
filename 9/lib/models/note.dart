class Note {
  Note(
      {required this.name,
      required this.text,
      required this.category,
      this.id});

  String? id = "";
  String name = "";
  String text = "";
  String category = "";
}
