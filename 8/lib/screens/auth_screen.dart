import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  FirebaseAuth auth = FirebaseAuth.instance;

  void authLinkToEmail(String email) async {
    try {
      ActionCodeSettings acs = ActionCodeSettings(
          url: 'https://ssjkss.page.link/tobR?email=$email',
          androidPackageName: 'com.example.flutter_application_1',
          handleCodeInApp: true,
          androidInstallApp: false);
      await FirebaseAuth.instance
          .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Письмо отправлено вам на почту',
                      textAlign: TextAlign.center))));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message.toString(), textAlign: TextAlign.center)));
    }
  }

  void authWithEmailAndPassword(String email, String password) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomeScreen())));
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Неверная почта и пароль', textAlign: TextAlign.center)));
    }
  }

  void authAnonymously() async =>
      await auth.signInAnonymously().then((value) => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const HomeScreen())));

  void getDynamicLinkAndSignIn() async {
    PendingDynamicLinkData dynamicLink =
        await FirebaseDynamicLinks.instance.onLink.first;
    try {
      String link = dynamicLink.link.toString();
      if (auth.isSignInWithEmailLink(link)) {
        String continueUrl = dynamicLink.link.queryParameters['continueUrl']!;
        String email = Uri.parse(continueUrl).queryParameters['email']!;

        await auth.signInWithEmailLink(email: email, emailLink: link);

        // ignore: use_build_context_synchronously
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } on FirebaseAuthException {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ссылка уже используется, опробуйте позже',
              textAlign: TextAlign.center)));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getDynamicLinkAndSignIn();
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
            Form(
              key: key,
              child: Column(
                children: [
                  TextFormField(
                    controller: controllerEmail,
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "Почта не должена быть пустой";
                      }
                      if (value.length < 2) {
                        return "Почта должена быть от 2 символов";
                      }
                      if (value.length >= 16) {
                        return "Почта должена быть до 16 символов";
                      }
                      return null;
                    }),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Почта",
                    ),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 20)),
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
                  const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 20)),
                  ElevatedButton(
                      onPressed: () {
                        if (!key.currentState!.validate()) return;
                        authWithEmailAndPassword(controllerEmail.text.trim(),
                            controllerPassword.text.trim());
                      },
                      child: const Text("Войти")),
                  const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 5)),
                  ElevatedButton(
                      onPressed: () => authAnonymously(),
                      child: const Text("Войти анонимно")),
                  const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 5)),
                  ElevatedButton(
                      onPressed: () =>
                          authLinkToEmail(controllerEmail.text.trim()),
                      child: const Text("Войти по ссылке")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
