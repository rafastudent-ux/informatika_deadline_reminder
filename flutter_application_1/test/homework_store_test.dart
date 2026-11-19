import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/homework.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('homework and completion state survive loading again', () async {
    SharedPreferences.setMockInitialValues({});
    final store = HomeworkStore.instance;
    await store.initialize();

    final dueAt = DateTime(2026, 12, 1, 15, 30);
    await store.add(
      title: 'Review chapter',
      subject: 'Math',
      dueAt: dueAt,
      notes: 'Exercises 1-5',
    );
    final item = store.homework.single;
    await store.setCompleted(item.id, true);

    await store.initialize();

    expect(store.homework, hasLength(1));
    expect(store.homework.single.title, 'Review chapter');
    expect(store.homework.single.subject, 'Math');
    expect(store.homework.single.dueAt, dueAt);
    expect(store.homework.single.notes, 'Exercises 1-5');
    expect(store.homework.single.isCompleted, isTrue);
  });

  test(
    'deleting homework removes only the selected item and persists',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = HomeworkStore.instance;
      await store.initialize();
      await store.add(
        title: 'Keep this',
        subject: 'Science',
        dueAt: DateTime(2026, 12, 1),
      );
      await store.add(
        title: 'Delete this',
        subject: 'Math',
        dueAt: DateTime(2026, 12, 2),
      );
      final itemToDelete = store.homework.last;

      await store.delete(itemToDelete.id);
      await store.initialize();

      expect(store.homework, hasLength(1));
      expect(store.homework.single.title, 'Keep this');
    },
  );
}
