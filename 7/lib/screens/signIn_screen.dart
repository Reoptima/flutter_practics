import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/url.dart';
import '../models/user.dart';
import '../screens/user_sceen.dart';
import '../screens/signUp_screen.dart';
import '../interceptors/custom_interceptor.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  TextEditingController controllerLogin = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  SharedPreferences? sharedPreferences;
  Dio DIO = Dio();

  Future<void> initSharedPreferences() async =>
      sharedPreferences = await SharedPreferences.getInstance();

  void setTokenSharedPreferences(String token) async =>
      await sharedPreferences!.setString('token', token);

  Future<void> auth() async {
    try {
      DIO.interceptors.add(CustomInterceptor());

      Response response = await DIO.post(URL.token.value,
          data: User(
              login: controllerLogin.text, password: controllerPassword.text));
      setTokenSharedPreferences(response.data['data']['accessToken']);
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const UserScreen()));
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Неверный логин или пароль', textAlign: TextAlign.center)));
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
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
                        auth();
                      },
                      child: const Text("Войти"),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("Зарегистрироваться"),
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
