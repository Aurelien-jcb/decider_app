import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_decider_app/controller/auth_controller.dart';
import 'package:flutter_decider_app/models/account_model.dart';
import 'package:flutter_decider_app/views/home_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AuthController().getOrCreateUser();
  runApp(MultiProvider(
    providers: [
      Provider.value(
        value: AuthController(),
      ),
    ],
    child: const DeciderApp(),
  ));
}

class DeciderApp extends StatelessWidget {
  const DeciderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decider App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(context.read<AuthController>().currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Account account = Account.fromSnapshot(
                snapshot.data, context.read<AuthController>().currentUser?.uid);
            return HomeView(account: account);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
