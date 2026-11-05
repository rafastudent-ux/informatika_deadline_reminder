import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/homework.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = HomeworkStore.instance.homework
        .where((item) => item.isCompleted)
        .toList()
      ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Deadline Zone',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Completed Assignments  ·  ${completed.length} Done',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        if (completed.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 72),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 44, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Completed homework will appear here.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          for (final item in completed)
            Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 34, top: 4),
                      child: Text(
                        '${item.subject} · Due ${_formatDateTime(item.dueAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF079669),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => HomeworkStore.instance.setCompleted(
                            item.id,
                            false,
                          ),
                          child: const Text('Move to Home'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

String _formatDateTime(DateTime date) =>
    '${_month(date.month)} ${date.day}, ${date.year}, ${_formatTime(date)}';

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
}

String _month(int month) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];