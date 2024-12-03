import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../projects/controllers/project_controller.dart';
import '../../tasks/controllers/task_controller.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Obx(() => TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) {
            return isSameDay(controller.selectedDay.value, day);
          },
          eventLoader: controller.getEventsForDay,
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.teal.shade300,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDay.value = selectedDay;
            controller.focusedDay.value = focusedDay;
          },
        ));
  }

  Widget _buildEventsList() {
    return Expanded(
      child: Obx(() {
        final events = controller.getEventsForDay(controller.selectedDay.value);
        if (events.isEmpty) {
          return Center(
            child: Text(
              'No deadlines on this day',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      }),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.isProject
              ? Colors.teal.shade100
              : Colors.orange.shade100,
          child: Icon(
            event.isProject ? Icons.folder_rounded : Icons.task_rounded,
            color: event.isProject ? Colors.teal : Colors.orange,
          ),
        ),
        title: Text(event.title),
        subtitle: Text(event.isProject ? 'Project Deadline' : 'Task Due Date'),
        trailing: Text(
          controller.formatTime(event.date),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        onTap: () => event.isProject
            ? Get.toNamed('/project/${event.id}')
            : Get.toNamed('/task/${event.id}'),
      ),
    );
  }
} 