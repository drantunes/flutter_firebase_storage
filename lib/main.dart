import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_storage/pages/error_page.dart';
import 'package:flutter_firebase_storage/pages/loading_page.dart';
import 'package:flutter_firebase_storage/pages/storage_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _inicializacao = Firebase.initializeApp();

  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: FutureBuilder(
        // Inicia o FlutterFire:
        future: _inicializacao,
        builder: (context, app) {
          // Se completa, carrega a home
          if (app.connectionState == ConnectionState.done) {
            return const StoragePage();
          }

          // Verificação de erros
          if (app.hasError) return const ErrorPage();

          // Enquanto inicia, mostra um loading
          return const LoadingPage();
        },
      ),
    );
  }
}
