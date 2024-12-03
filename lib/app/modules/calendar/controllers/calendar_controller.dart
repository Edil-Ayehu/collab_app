import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../projects/controllers/project_controller.dart';
import '../../tasks/controllers/task_controller.dart';

class CalendarController extends GetxController {
  final ProjectController projectController = Get.find();
  final TaskController taskController = Get.find();

  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;

  List<CalendarEvent> getEventsForDay(DateTime day) {
    final events = <CalendarEvent>[];

    // Add project deadlines
    for (final project in projectController.projects) {
      if (isSameDay(project.deadline, day)) {
        events.add(CalendarEvent(
          id: project.id,
          title: project.name,
          date: project.deadline,
          isProject: true,
        ));
      }
    }

    // Add task due dates
    for (final task in taskController.tasks) {
      if (isSameDay(task.dueDate, day)) {
        events.add(CalendarEvent(
          id: task.id,
          title: task.title,
          date: task.dueDate,
          isProject: false,
        ));
      }
    }

    return events;
  }

  String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final bool isProject;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.isProject,
  });
} 