import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../projects/controllers/project_controller.dart';
import '../../tasks/controllers/task_controller.dart';

class OverviewView extends GetView<DashboardController> {
  const OverviewView({super.key});

  ProjectController get projectController => Get.find<ProjectController>();
  TaskController get taskController => Get.find<TaskController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => _buildStatCard(
                title: 'Active Projects',
                value: projectController.projects
                    .where((p) => p.status != 'completed')
                    .length
                    .toString(),
                icon: Icons.folder,
                color: Colors.blue,
              )),
          const SizedBox(height: 16),
          Obx(() => _buildStatCard(
                title: 'Pending Tasks',
                value: taskController.tasks
                    .where((t) => t.status != 'completed')
                    .length
                    .toString(),
                icon: Icons.task,
                color: Colors.orange,
              )),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return Card(
      child: Obx(() {
        final recentProjects = projectController.projects
            .take(3)
            .map((p) => _buildActivityItem(
                  'Project Created',
                  p.name,
                  p.createdAt,
                  Icons.folder,
                  Colors.blue,
                ))
            .toList();

        final recentTasks = taskController.tasks
            .take(3)
            .map((t) => _buildActivityItem(
                  'Task Added',
                  t.title,
                  t.createdAt,
                  Icons.task,
                  Colors.orange,
                ))
            .toList();

        final allActivities = [...recentProjects, ...recentTasks]
          ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: allActivities.take(5).toList(),
        );
      }),
    );
  }

  Widget _buildActivityItem(
    String action,
    String title,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    final timeAgo = _getTimeAgo(timestamp);
    
    return ListTile(
      key: Key(timestamp.toString()),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(action),
      trailing: Text(timeAgo),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 