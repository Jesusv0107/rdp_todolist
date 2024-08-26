import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rdp_todolist/screens/home_page.dart';
import 'firebase_options.dart';

void main() async {
//Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Firebase with the current platform's deafault options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
