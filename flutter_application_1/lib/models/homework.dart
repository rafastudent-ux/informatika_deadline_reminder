import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _storageKey = 'homework_items';

  List<Homework> _homework = [];
  int _nextId = 0;

  List<Homework> get homework => List.unmodifiable(_homework);

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedHomework = preferences.getString(_storageKey);
    if (savedHomework == null) {
      _homework = [];
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(savedHomework);
    if (decoded is! List) {
      throw const FormatException('Saved homework data is not a list.');
    }

    _homework = decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Saved homework item is invalid.');
      }
      return Homework(
        id: item['id'] as String,
        title: item['title'] as String,
        subject: item['subject'] as String,
        dueAt: DateTime.parse(item['dueAt'] as String),
        notes: item['notes'] as String,
        isCompleted: item['isCompleted'] as bool,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> add({
    required String title,
    required String subject,
    required DateTime dueAt,
    String notes = '',
  }) async {
    final homework = [
      ..._homework,
      Homework(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
        title: title,
        subject: subject,
        dueAt: dueAt,
        notes: notes,
      ),
    ];
    await _save(homework);
    _homework = homework;
    notifyListeners();
  }

  Future<void> setCompleted(String id, bool isCompleted) async {
    final index = _homework.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final homework = [..._homework];
    homework[index] = homework[index].copyWith(isCompleted: isCompleted);
    await _save(homework);
    _homework = homework;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final homework = _homework.where((item) => item.id != id).toList();
    if (homework.length == _homework.length) return;

    await _save(homework);
    _homework = homework;
    notifyListeners();
  }

  Future<void> _save(List<Homework> homework) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(
        homework
            .map(
              (item) => {
                'id': item.id,
                'title': item.title,
                'subject': item.subject,
                'dueAt': item.dueAt.toIso8601String(),
                'notes': item.notes,
                'isCompleted': item.isCompleted,
              },
            )
            .toList(),
      ),
    );
    if (!saved) {
      throw StateError('Could not save homework to local storage.');
    }
  }
}
