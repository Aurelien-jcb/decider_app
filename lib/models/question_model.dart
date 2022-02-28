class Question {
  String? question;
  String? answer;
  DateTime? created;

  Question();

  Map<String, dynamic> toJson() =>
      {'question': question, 'answer': answer, 'created': created};

  Question.fromSnapshot(snapshot)
      : question = snapshot.data()['question'],
        answer = snapshot.data()['answer'],
        created = snapshot.data()['created'].toDate();
}
