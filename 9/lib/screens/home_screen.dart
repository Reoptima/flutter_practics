import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/cubit/notes_cubit.dart';
import 'package:flutter_application_1/page/notes_page.dart';

import '../screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HistoryPage());
  }
}
