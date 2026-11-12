import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/homework.dart';
import 'package:flutter_application_1/pages/add_homework.dart';
import 'package:flutter_application_1/pages/history.dart';

enum _DeadlineFilter { all, today, thisWeek, overdue }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  _DeadlineFilter _filter = _DeadlineFilter.all;

  Future<void> _addHomework() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AddHomeworkPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: HomeworkStore.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(
            child: _selectedTab == 0 ? _buildHome() : const HistoryPage(),
          ),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildHome() {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final weekEnd = today.add(const Duration(days: 7));
    final items =
        HomeworkStore.instance.homework
            .where((item) => !item.isCompleted)
            .where((item) {
              switch (_filter) {
                case _DeadlineFilter.all:
                  return true;
                case _DeadlineFilter.today:
                  return DateUtils.isSameDay(item.dueAt, today);
                case _DeadlineFilter.thisWeek:
                  return !DateUtils.dateOnly(item.dueAt).isBefore(today) &&
                      DateUtils.dateOnly(item.dueAt).isBefore(weekEnd);
                case _DeadlineFilter.overdue:
                  return item.isMissingAt(now);
              }
            })
            .toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text('Good morning 👋', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        const Text(
          'My Deadlines',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', _DeadlineFilter.all),
              _filterChip('Today', _DeadlineFilter.today),
              _filterChip('This Week', _DeadlineFilter.thisWeek),
              _filterChip('Overdue', _DeadlineFilter.overdue),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Column(
              children: [
                const Icon(Icons.event_available, size: 44, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  _filter == _DeadlineFilter.all
                      ? 'No homework yet'
                      : 'No deadlines in this section',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                const Text('Tap + to add a homework deadline.'),
              ],
            ),
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            if (index == 0 ||
                !DateUtils.isSameDay(
                  items[index - 1].dueAt,
                  items[index].dueAt,
                ))
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Text(
                  _dateHeading(items[index].dueAt, today),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            _HomeworkCard(
              homework: items[index],
              onComplete: () async =>
                  HomeworkStore.instance.setCompleted(items[index].id, true),
            ),
          ],
      ],
    );
  }

  Widget _filterChip(String label, _DeadlineFilter filter) {
    final isSelected = _filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filter = filter),
        selectedColor: Colors.black,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? Colors.black : const Color(0xFFEAEAEA),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 58,
                  height: 42,
                  child: FilledButton(
                    onPressed: _addHomework,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.check_circle_outline,
                label: 'Done',
                selected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: selected ? Colors.black : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  const _HomeworkCard({required this.homework, required this.onComplete});

  final Homework homework;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final missing = homework.isMissingAt(DateTime.now());

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEAEAEA)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: IconButton(
          tooltip: 'Mark as done',
          onPressed: onComplete,
          icon: const Icon(Icons.radio_button_unchecked),
        ),
        title: Text(
          homework.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${homework.subject} · ${_formatDateTime(homework.dueAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: missing
            ? const Text(
                'Missing',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Text(
                _formatTime(homework.dueAt),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
      ),
    );
  }
}

String _dateHeading(DateTime date, DateTime today) {
  final dateOnly = DateUtils.dateOnly(date);
  if (DateUtils.isSameDay(dateOnly, today)) {
    return 'Today — ${_formatDate(date)}';
  }
  if (DateUtils.isSameDay(dateOnly, today.add(const Duration(days: 1)))) {
    return 'Tomorrow — ${_formatDate(date)}';
  }
  return '${_weekday(date.weekday)} — ${_formatDate(date)}';
}

String _formatDateTime(DateTime date) =>
    '${_formatDate(date)}, ${_formatTime(date)}';

String _formatDate(DateTime date) =>
    '${_month(date.month)} ${date.day}, ${date.year}';

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

String _weekday(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];
