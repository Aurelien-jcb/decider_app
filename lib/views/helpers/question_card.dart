import 'package:flutter/material.dart';
import 'package:flutter_decider_app/extensions/string_extension.dart';
import 'package:intl/intl.dart';
import '../../models/question_model.dart';

class QuestionCard extends StatelessWidget {
  final Question _question;

  const QuestionCard(this._question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text('Should I ${_question.question} ?'),
                ),
              ],
            ),
            Row(
              children: [
                Text(_question.answer!.capitalize(),
                    style: Theme.of(context).textTheme.headline6),
                const Spacer(),
                Text(DateFormat('MM/dd/yyyy')
                    .format(_question.created!)
                    .toString())
              ],
            ),
          ],
        ),
      ),
    );
  }
}
