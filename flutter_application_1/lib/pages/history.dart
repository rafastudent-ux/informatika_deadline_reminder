import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/homework.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _confirmDelete(BuildContext context, Homework item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete completed homework?'),
        content: Text('“${item.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await HomeworkStore.instance.delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: HomeworkStore.instance,
      builder: (context, _) {
        final completed =
            HomeworkStore.instance.homework
                .where((item) => item.isCompleted)
                .toList()
              ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

        final horizontalPadding = MediaQuery.sizeOf(context).width < 400
            ? 16.0
            : 24.0;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
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
                        Icon(
                          Icons.check_circle_outline,
                          size: 44,
                          color: Colors.grey,
                        ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
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
                                OutlinedButton(
                                  onPressed: () async => HomeworkStore.instance
                                      .setCompleted(item.id, false),
                                  child: const Text('Move to Home'),
                                ),
                                IconButton(
                                  tooltip: 'Delete completed homework',
                                  onPressed: () =>
                                      _confirmDelete(context, item),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
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
