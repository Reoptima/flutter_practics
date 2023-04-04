import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/url.dart';
import '../models/user.dart';
import '../screens/signIn_screen.dart';
import '../interceptors/custom_interceptor.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  TextEditingController controllerLogin = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  SharedPreferences? sharedPreferences;
  Dio DIO = Dio();

  Future<void> initSharedPreferences() async =>
      sharedPreferences = await SharedPreferences.getInstance();

  void clearSharedPreferences() async => await sharedPreferences!.clear();

  String getTokenSharedPreferences() {
    return sharedPreferences!.getString('token')!;
  }

  Future<void> updateProfile() async {
    String updateStatus = "Успешное обновление";
    try {
      await DIO.post(URL.user.value,
          data: User(login: controllerLogin.text, email: controllerEmail.text));
    } on DioError {
      updateStatus = "Данный логин уже занят";
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updateStatus, textAlign: TextAlign.center)));
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((value) async {
      String token = getTokenSharedPreferences();
      DIO.options.headers['Authorization'] = "Bearer $token";
      DIO.interceptors.add(CustomInterceptor());
      Response response = await DIO.get(URL.user.value);
      controllerEmail.text = response.data['data']['email'];
      controllerLogin.text = response.data['data']['login'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
            child: Center(
              child: Form(
                key: key,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controllerLogin,
                      validator: ((value) {
                        if (value == null || value.isEmpty) {
                          return "Логин не должен быть пустым";
                        }
                        if (value.length < 8 || value.length >= 16) {
                          return "Логин должен быть от 8 до 16 символов";
                        }
                        return null;
                      }),
                      decoration: const InputDecoration(
                        labelText: "Логин",
                      ),
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 20)),
                    TextFormField(
                      controller: controllerEmail,
                      validator: ((value) {
                        if (value == null || value.isEmpty) {
                          return "Email не должен быть пустым";
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return "Email введен неправильно";
                        }
                        return null;
                      }),
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      updateProfile();
                    },
                    child: const Text("Изменить"),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 5)),
                  ElevatedButton(
                    onPressed: () {
                      clearSharedPreferences();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()));
                    },
                    child: const Text("Выйти"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
