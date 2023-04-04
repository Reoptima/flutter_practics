import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/url.dart';
import '../models/user.dart';
import '../screens/signIn_screen.dart';
import '../interceptors/custom_interceptor.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController controllerLogin = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  Dio DIO = Dio();

  Future<void> register() async {
    try {
      DIO.interceptors.add(CustomInterceptor());
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
      await DIO.put(URL.token.value,
          data: User(
              login: controllerLogin.text,
              email: controllerEmail.text,
              password: controllerPassword.text));
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Данный логин уже занят', textAlign: TextAlign.center)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                          if (value.length < 2) {
                            return "Логин должен быть от 2 символов";
                          }
                          if (value.length >= 16) {
                            return "Логин должен быть до 16 символов";
                          }
                          return null;
                        }),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Логин",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(25, 5, 25, 20),
                      ),
                      TextFormField(
                        controller: controllerEmail,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return "Почта не должен быть пустым";
                          }
                          return null;
                        }),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Почта",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(25, 5, 25, 20),
                      ),
                      TextFormField(
                        controller: controllerPassword,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return "Пароль не должен быть пустым";
                          }
                          if (value.length < 2) {
                            return "Пароль должен быть от 2 символов";
                          }
                          if (value.length >= 16) {
                            return "Пароль должен быть до 16 символов";
                          }
                          return null;
                        }),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Пароль",
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
                        if (!key.currentState!.validate()) return;
                        register();
                      },
                      child: const Text("Зарегистрироваться"),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text("Назад"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
