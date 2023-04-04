import 'package:freezed_annotation/freezed_annotation.dart';
part 'note.g.dart';
part 'note.freezed.dart';

@freezed
class Note with _$Note {
  const factory Note(
      {int? id,
      required String name,
      required String text,
      required String category,
      bool? deleted}) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
