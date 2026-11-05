import 'package:flutter/foundation.dart';

class Homework {
  const Homework({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueAt,
    this.notes = '',
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueAt;
  final String notes;
  final bool isCompleted;

  bool isMissingAt(DateTime now) => !isCompleted && dueAt.isBefore(now);

  Homework copyWith({bool? isCompleted}) {
    return Homework(
      id: id,
      title: title,
      subject: subject,
      dueAt: dueAt,
      notes: notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class HomeworkStore extends ChangeNotifier {
  HomeworkStore._();

  static final HomeworkStore instance = HomeworkStore._();

  final List<Homework> _homework = [];
  int _nextId = 0;

  List<Homework> get homework => List.unmodifiable(_homework);

  void add({
    required String title,
    required String subject,
    required DateTime dueAt,
    String notes = '',
  }) {
    _homework.add(
      Homework(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
        title: title,
        subject: subject,
        dueAt: dueAt,
        notes: notes,
      ),
    );
    notifyListeners();
  }

  void setCompleted(String id, bool isCompleted) {
    final index = _homework.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _homework[index] = _homework[index].copyWith(isCompleted: isCompleted);
    notifyListeners();
  }
}
