// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Note _$$_NoteFromJson(Map<String, dynamic> json) => _$_Note(
      id: json['id'] as int?,
      name: json['name'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      deleted: json['deleted'] as bool?,
    );

Map<String, dynamic> _$$_NoteToJson(_$_Note instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'text': instance.text,
      'category': instance.category,
      'deleted': instance.deleted,
    };
