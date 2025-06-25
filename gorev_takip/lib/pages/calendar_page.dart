import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final TaskService _taskService = TaskService();
  final Map<DateTime, List<Task>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.getTasksOnce();
    setState(() {
      _events.clear();
      for (var task in tasks) {
        final dateKey =
            DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        _events.putIfAbsent(dateKey, () => []).add(task);
      }
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Takvim")),
      body: Column(
        children: [
          TableCalendar(
            locale: 'tr_TR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedDay == null
                ? "Bir gün seçiniz"
                : "${_selectedDay!.day}.${_selectedDay!.month}.${_selectedDay!.year} görevleri",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Gün seçiniz"))
                : ListView(
                    children: _getTasksForDay(_selectedDay!).map((task) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description),
                          trailing: task.isCompleted
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
