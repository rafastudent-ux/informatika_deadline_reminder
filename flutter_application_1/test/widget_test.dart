// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/homework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('opens the deadline home and add homework page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await HomeworkStore.instance.initialize();
    await tester.pumpWidget(const MyApp());

    expect(find.text('My Deadlines'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saveHomeworkButton')), findsOneWidget);
  });

  testWidgets('confirms deleting a completed item on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final store = HomeworkStore.instance;
    await store.initialize();
    await store.add(
      title: 'A completed assignment with a long title',
      subject: 'Computer Science',
      dueAt: DateTime(2026, 12, 1, 15, 30),
    );
    await store.setCompleted(store.homework.single.id, true);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Delete completed homework'));
    await tester.pumpAndSettle();
    expect(find.text('Delete completed homework?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.homework, hasLength(1));

    await tester.tap(find.byTooltip('Delete completed homework'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(store.homework, isEmpty);
    expect(find.text('Completed homework will appear here.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers content at readable widths on a desktop screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await HomeworkStore.instance.initialize();
    await tester.pumpWidget(const MyApp());

    expect(tester.getSize(find.byType(ListView)).width, 960);

    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ListView)).width, 960);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ListView)).width, 640);
    expect(tester.takeException(), isNull);
  });
}
