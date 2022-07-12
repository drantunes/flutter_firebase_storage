import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_storage/pages/error_page.dart';
import 'package:flutter_firebase_storage/pages/loading_page.dart';
import 'package:flutter_firebase_storage/pages/storage_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _inicializacao = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.dark,
      ),
      home: FutureBuilder(
        future: _inicializacao,
        builder: (context, app) {
          if (app.connectionState == ConnectionState.done) {
            return const StoragePage();
          }

          if (app.hasError) return const ErrorPage();

          return const LoadingPage();
        },
      ),
    );
  }
}
