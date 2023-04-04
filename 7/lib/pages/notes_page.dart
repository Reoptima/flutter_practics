import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/url.dart';
import '../models/note.dart';
import '../cubit/notes_cubit.dart';
import '../interceptors/custom_interceptor.dart';

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
  SharedPreferences? sharedPreferences;
  Dio DIO = Dio();
  List<Note> notes = [];

  Future<void> initSharedPreferences() async =>
      sharedPreferences = await SharedPreferences.getInstance();

  void clearSharedPreferences() async => await sharedPreferences!.clear();

  String getTokenSharedPreferences() {
    return sharedPreferences!.getString('token')!;
  }

  Future<void> getNotes(String search) async {
    try {
      Response response =
          await DIO.get(URL.note.value, queryParameters: {'search': search});
      if (response.data['message'] == 'Заметки не найдены') {
        // ignore: use_build_context_synchronously
        context.read<NotesCubit>().clearNotes();
        return;
      }

      notes =
          (response.data['data'] as List).map((x) => Note.fromJson(x)).toList();

      // ignore: use_build_context_synchronously
      context.read<NotesCubit>().setNotes(notes);
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> createNote() async {
    try {
      await DIO.post(URL.note.value,
          data: Note(
              name: controllerName.text,
              text: controllerText.text,
              category: controllerCategory.text));
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> updateNote(int id) async {
    try {
      await DIO.put('${URL.note.value}/$id',
          data: Note(
              name: controllerName.text,
              text: controllerText.text,
              category: controllerCategory.text));
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await DIO.delete('${URL.note.value}/$id');
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((value) async {
      String token = getTokenSharedPreferences();
      DIO.options.headers['Authorization'] = "Bearer $token";
      DIO.interceptors.add(CustomInterceptor());
      getNotes('');
    });
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
                        if (!state.notes.elementAt(index).deleted!)
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
