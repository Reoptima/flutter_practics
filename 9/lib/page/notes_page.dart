import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';
import '../cubit/notes_cubit.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerText = TextEditingController();
  TextEditingController controllerCategory = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  List<Note> notes = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final notesCollection = FirebaseFirestore.instance.collection("notes");

  Future<void> getNotes(String search) async {
    notesCollection.get().then((value) {
      notes = [];
      for (var noteData in value.docs) {
        notes.add(Note(
            id: noteData.id,
            name: noteData["name"],
            text: noteData["text"],
            category: noteData["category"]));
      }
      context.read<NotesCubit>().setNotes(notes);
      return;
    });
  }

  Future<void> createNote() async {
    await notesCollection.add({
      "name": controllerName.text,
      "text": controllerText.text,
      "category": controllerCategory.text
    });
  }

  Future<void> updateNote(String id) async {
    await notesCollection.doc(id).set({
      "name": controllerName.text,
      "text": controllerText.text,
      "category": controllerCategory.text
    });
  }

  Future<void> deleteNote(String id) async {
    await notesCollection.doc(id).delete();
  }

  @override
  void initState() {
    super.initState();
    getNotes('');
  }

  void showNoteDialog(Note? note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            width: 300,
            height: 340,
            child: Column(
              children: [
                Center(
                  child: Form(
                    key: key,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controllerName,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Наименование не должно быть пустым";
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Наименование",
                          ),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
                        TextFormField(
                          controller: controllerText,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Текст не должен быть пустым";
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: "Текст",
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(25, 5, 25, 5)),
                        TextFormField(
                          controller: controllerCategory,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Категория не должна быть пустой";
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: "Категория",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (!key.currentState!.validate()) return;
                            if (note == null) {
                              await createNote();
                            } else {
                              await updateNote(note.id!);
                            }
                            getNotes('');
                            controllerName.text = '';
                            controllerText.text = '';
                            controllerCategory.text = '';
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          },
                          child: const Text("Сохранить"),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Отмена"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: double.infinity,
          height: 40,
          child: Center(
            child: TextField(
              onSubmitted: (value) => getNotes(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is UpdateNotes) {
              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text((state.notes.elementAt(index).id).toString()),
                    ),
                    title: Text(state.notes.elementAt(index).name),
                    subtitle: Text(state.notes.elementAt(index).text),
                    trailing: PopupMenuButton(
                      tooltip: "Действия",
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text("Изменить"),
                          onTap: () {
                            Note note = state.notes.elementAt(index);
                            controllerName.text = note.name;
                            controllerText.text = note.text;
                            controllerCategory.text = note.category;
                            Future.delayed(const Duration(seconds: 0),
                                () => showNoteDialog(note));
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Удалить"),
                          onTap: () async {
                            deleteNote(state.notes.elementAt(index).id!);
                            context.read<NotesCubit>().deleteNote(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
