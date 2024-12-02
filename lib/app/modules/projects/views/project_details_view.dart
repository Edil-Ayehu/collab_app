import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_details_controller.dart';
import '../../../data/models/task_model.dart';

class ProjectDetailsView extends GetView<ProjectDetailsController> {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.project.value?.name ?? '')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProjectDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.people_rounded),
            onPressed: () => _showMembersDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectInfo(),
              const SizedBox(height: 24),
              _buildTaskSection(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.teal,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_task_rounded),
      ),
    );
  }

  Widget _buildProjectInfo() {
    final project = controller.project.value;
    if (project == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                DropdownButton<String>(
                  value: project.status,
                  items: ['pending', 'in progress', 'completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.capitalize!,
                              style: TextStyle(
                                color: _getStatusColor(status),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateProjectStatus(project.id, value);
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    project.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(project.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: ${controller.formatDate(project.deadline)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${project.members.length} members',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            _buildTaskFilter(),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.filteredTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.selectedFilter.value == 'all'
                          ? 'No tasks found'
                          : 'No ${controller.selectedFilter.value.replaceAll('_', ' ')} tasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.selectedFilter.value == 'all'
                          ? 'Create a new task to get started'
                          : 'Try selecting a different filter',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return _buildTaskCard(task);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.status == 'completed',
          onChanged: (value) => controller.updateTaskStatus(
            task,
            value! ? 'completed' : 'todo',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == 'completed'
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.status == 'completed'
                ? Colors.grey.shade400
                : Colors.grey.shade800,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 4),
            Text(
              controller.formatDate(task.dueDate),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _showTaskOptions(task),
        ),
        onTap: () => Get.toNamed('/task/${task.id}'),
      ),
    );
  }

  Widget _buildTaskFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
              value: controller.selectedFilter.value,
              icon:
                  Icon(Icons.filter_list_rounded, color: Colors.grey.shade600),
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              isDense: true,
              items: [
                'all',
                'todo',
                'in_progress',
                'completed',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'all'
                        ? 'All Tasks'
                        : value.replaceAll('_', ' ').capitalize!,
                  ),
                );
              }).toList(),
              onChanged: (value) => controller.filterTasks(value),
            )),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showEditProjectDialog(BuildContext context) async {
    final project = controller.project.value;
    if (project == null) return;

    controller.nameController.text = project.name;
    controller.descriptionController.text = project.description;
    controller.selectedDeadline.value = project.deadline;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Deadline'),
                subtitle: Obx(() => Text(
                      controller.formatDate(controller.selectedDeadline.value),
                    )),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () => controller.pickDate(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProject();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMembersDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Members'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Add member by email',
                  suffixIcon: Icon(Icons.person_add_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() => ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.members.length,
                      itemBuilder: (context, index) {
                        final member = controller.members[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_rounded),
                          ),
                          title: Text(member['email'] ?? ''),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.remove_circle_outline_rounded),
                            onPressed: () => controller
                                .removeMember(member['uid'] as String),
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addMember();
              controller.emailController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit Task'),
              onTap: () {
                Get.back();
                Get.toNamed('/task/${task.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Delete Task',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.deleteTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.taskTitleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.taskDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Obx(() => Text(
                      controller
                          .formatDate(controller.selectedTaskDueDate.value),
                    )),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () => controller.pickTaskDate(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.createTask();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMembersChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_rounded, size: 16, color: Colors.teal.shade400),
          const SizedBox(width: 4),
          Text(
            '$count members',
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
