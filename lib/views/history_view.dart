import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decider_app/controller/auth_controller.dart';
import 'package:flutter_decider_app/views/helpers/question_card.dart';
import 'package:provider/provider.dart';

import '../models/question_model.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<Object> _historyList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUsersQuestionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past decisions'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _historyList.length,
          itemBuilder: (context, index) {
            return QuestionCard(_historyList[index] as Question);
          },
        ),
      ),
    );
  }

  Future getUsersQuestionList() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(context.read<AuthController>().currentUser?.uid)
        .collection('questions')
        .orderBy('created', descending: true)
        .get();
    setState(() {
      _historyList =
          List.from(data.docs.map((doc) => Question.fromSnapshot(doc)));
    });
  }
}
