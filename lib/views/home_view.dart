import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decider_app/extensions/string_extension.dart';
import 'package:flutter_decider_app/models/question_model.dart';
import 'package:flutter_decider_app/views/history_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../controller/auth_controller.dart';
import '../models/account_model.dart';

enum AppStatus { ready, waiting }

class HomeView extends StatefulWidget {
  final Account account;

  const HomeView({Key? key, required this.account}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _answer = '';
  final TextEditingController _questionController = TextEditingController();
  bool _askBtnActive = false;
  final Question _question = Question();
  AppStatus? _appStatus;
  int _timeTilNextFree = 0;
  final CountdownController _countDownController = CountdownController();
  @override
  void initState() {
    super.initState();
    _timeTilNextFree = widget.account.nextFreeQuestion
            ?.difference((DateTime.now()))
            .inSeconds ??
        0;
    _giveFreeDecision(widget.account.bank, _timeTilNextFree);
  }

  @override
  Widget build(BuildContext context) {
    _setAppStatus();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dicider App',
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HistoryView(),
                    ),
                  );
                },
                child: const Icon(Icons.history),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Decisions left : ${widget.account.bank}'),
                ),
                _nextFreeCountdown(),
                const Spacer(),
                _buildQuestionForm(),
                const Spacer(
                  flex: 1,
                ),
                // Text('Account type : free'),
                // Text("${context.read<AuthController>().currentUser?.uid}")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionForm() {
    if (_appStatus == AppStatus.ready) {
      return Column(
        children: [
          Text(
            'Should I',
            style: Theme.of(context).textTheme.headline4,
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
            child: TextField(
              controller: _questionController,
              decoration: const InputDecoration(helperText: 'Enter a question'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                setState(() {
                  _askBtnActive = value.isNotEmpty ? true : false;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _askBtnActive == true ? _answerQuestion : null,
            child: const Text('Ask'),
          ),
          _questionAndAnswer()
        ],
      );
    } else {
      return _questionAndAnswer();
    }
  }

  Widget _nextFreeCountdown() {
    if (_appStatus == AppStatus.waiting) {
      _countDownController.start();
      var f = NumberFormat("00", "fr_FR");
      return Column(
        children: [
          const Text('You will get one free decision in '),
          Countdown(
            controller: _countDownController,
            seconds: _timeTilNextFree,
            build: (BuildContext context, double time) => Text(
                "${f.format(time ~/ 3600)}:${f.format((time % 3600) ~/ 60)}:${f.format(time.toInt() % 60)}"),
            interval: const Duration(seconds: 1),
            onFinished: () {
              _giveFreeDecision(widget.account.bank, 0);
              setState(() {
                _timeTilNextFree = 0;
                _appStatus = AppStatus.ready;
              });
            },
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _questionAndAnswer() {
    if (_answer != "") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text('Should I : ${_question.question}?'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Answer : ${_answer.capitalize()}",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  String _getAnswer() {
    var answerOptions = ['yes', 'no', 'definitely', 'not right now'];
    return answerOptions[Random().nextInt(answerOptions.length)];
  }

  void _giveFreeDecision(currrentBank, timeTilNextFree) {
    if (currrentBank <= 0 && timeTilNextFree <= 0) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.account.uid)
          .update({'bank': 1});
    }
  }

  void _setAppStatus() {
    if (widget.account.bank > 0) {
      setState(() {
        _appStatus = AppStatus.ready;
      });
    } else {
      setState(() {
        _appStatus = AppStatus.waiting;
      });
    }
  }

  void _answerQuestion() async {
    setState(() {
      _answer = _getAnswer();
    });

    // save to DB
    _question.question = _questionController.text;
    _question.answer = _answer;
    _question.created = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.account.uid)
        .collection('questions')
        .add(_question.toJson());

    widget.account.bank -= 1;
    widget.account.nextFreeQuestion = DateTime.now().add(
      const Duration(seconds: 20),
    );
    setState(() {
      _timeTilNextFree = widget.account.nextFreeQuestion
              ?.difference((DateTime.now()))
              .inSeconds ??
          0;
      if (widget.account.bank == 0) {
        _appStatus = AppStatus.waiting;
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.account.uid)
        .update(widget.account.toJson());

    _questionController.text = "";
  }
}
