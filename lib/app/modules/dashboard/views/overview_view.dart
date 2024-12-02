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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildStatCard(
                      title: 'Active Projects',
                      value: projectController.projects
                          .where((p) => p.status != 'completed')
                          .length
                          .toString(),
                      icon: Icons.folder_rounded,
                      color: Colors.teal.shade300,
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildStatCard(
                      title: 'Pending Tasks',
                      value: taskController.tasks
                          .where((t) => t.status != 'completed')
                          .length
                          .toString(),
                      icon: Icons.task_rounded,
                      color: Colors.orange.shade300,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final recentProjects = projectController.projects
            .take(3)
            .map((p) => _buildActivityItem(
                  'Project Created',
                  p.name,
                  p.createdAt,
                  Icons.folder_rounded,
                  Colors.teal.shade300,
                ))
            .toList();

        final recentTasks = taskController.tasks
            .take(3)
            .map((t) => _buildActivityItem(
                  'Task Added',
                  t.title,
                  t.createdAt,
                  Icons.task_rounded,
                  Colors.orange.shade300,
                ))
            .toList();

        final allActivities = [...recentProjects, ...recentTasks]
          ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allActivities.take(5).length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (context, index) => allActivities[index],
          ),
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        action,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        timeAgo,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
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
