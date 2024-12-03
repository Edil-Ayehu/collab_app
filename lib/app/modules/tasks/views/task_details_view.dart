import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_details_controller.dart';
import 'package:intl/intl.dart';

class TaskDetailsView extends GetView<TaskDetailsController> {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Task Details'),
        actions: [
          Obx(() {
            if (controller.hasPermission('edit_tasks')) {
              return IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _showEditTaskDialog(context),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            final hasEditPermission = controller.hasPermission('edit_tasks');
            final hasDeletePermission =
                controller.hasPermission('delete_tasks');
            final hasAssignPermission =
                controller.hasPermission('assign_tasks');

            if (hasEditPermission ||
                hasDeletePermission ||
                hasAssignPermission) {
              return PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) {
                  final items = <PopupMenuItem>[];

                  if (hasAssignPermission) {
                    items.add(
                      PopupMenuItem(
                        child: const Text('Change Assignee'),
                        onTap: () => _showAssigneeDialog(context),
                      ),
                    );
                  }

                  if (hasDeletePermission) {
                    items.add(
                      PopupMenuItem(
                        child: const Text('Delete Task'),
                        onTap: () {
                          // Add delete task functionality
                        },
                      ),
                    );
                  }

                  return items;
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskInfo(),
                const Divider(height: 32),
                _buildAssigneeSection(),
                const Divider(height: 32),
                _buildCommentsSection(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCommentInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Obx(() {
      final task = controller.task.value;
      if (task == null) return const Center(child: CircularProgressIndicator());

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(task.status),
                _buildPriorityIndicator(task.priority),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Due: ${controller.formatDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAssigneeSection() {
    return Obx(() {
      final task = controller.task.value;
      if (task == null) return const SizedBox();

      final canAssignTasks = controller.hasPermission('assign_tasks');

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assignee',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (canAssignTasks)
                  TextButton.icon(
                    onPressed: () => _showAssigneeDialog(Get.context!),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Change'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(
                    Icons.person,
                    color: Colors.teal.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.assigneeName.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (controller.assigneeEmail.value.isNotEmpty)
                        Text(
                          controller.assigneeEmail.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        _buildCommentList(),
      ],
    );
  }

  Widget _buildCommentList() {
    return Obx(() {
      if (controller.comments.isEmpty) {
        return const Center(child: Text('No comments yet.'));
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.comments[index];
          final commentText = comment['text'] as String;
          final userName = comment['userName'] as String;
          final timestamp = comment['timestamp'] as DateTime;

          return ListTile(
            leading: CircleAvatar(
              child: Text(userName[0].toUpperCase()),
            ),
            title: Row(
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getFormattedTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: _buildCommentTextSpans(commentText),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          );
        },
      );
    });
  }

  String _getFormattedTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return DateFormat('MMM d, yyyy, h:mm a').format(timestamp);
    } else if (difference.inDays > 7) {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  List<TextSpan> _buildCommentTextSpans(String commentText) {
    final regex = RegExp(r'(@\w+)');
    final matches = regex.allMatches(commentText);
    int lastMatchEnd = 0;
    final spans = <TextSpan>[];

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
            TextSpan(text: commentText.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style:
            TextStyle(color: Colors.blue.shade400, fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < commentText.length) {
      spans.add(TextSpan(text: commentText.substring(lastMatchEnd)));
    }

    return spans;
  }

Widget _buildCommentInput() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Mention suggestions
      Obx(() {
        if (controller.showMentionsList.value) {
          return Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.filteredMembers.length,
              itemBuilder: (context, index) {
                final member = controller.filteredMembers[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: Text(
                      (member['name']?.toString() ?? member['email']?.toString() ?? '?')[0].toUpperCase(),
                      style: TextStyle(color: Colors.teal.shade700),
                    ),
                  ),
                  title: Text(member['name']?.toString() ?? ''),
                  subtitle: Text(member['email']?.toString() ?? ''),
                  onTap: () => controller.selectMemberMention(member),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      // Comment input
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 8 + MediaQuery.of(Get.context!).viewPadding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.commentController,
                onChanged: (value) {
                  // Check for @ mentions
                  final lastAtIndex = value.lastIndexOf('@');
                  if (lastAtIndex != -1) {
                    final query = value.substring(lastAtIndex + 1);
                    controller.filterMembersForMention(query);
                  } else {
                    controller.showMentionsList.value = false;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Add a comment... Use @ to mention',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Colors.teal,
              onPressed: controller.addComment,
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'todo':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    IconData icon;
    Color color;
    String label;

    switch (priority) {
      case 3:
        icon = Icons.flag_rounded;
        color = Colors.red;
        label = 'Urgent';
        break;
      case 2:
        icon = Icons.flag_rounded;
        color = Colors.orange;
        label = 'High';
        break;
      case 1:
        icon = Icons.flag_rounded;
        color = Colors.blue;
        label = 'Medium';
        break;
      default:
        icon = Icons.flag_outlined;
        color = Colors.grey;
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade400;
      case 'in_progress':
        return Colors.blue.shade400;
      case 'todo':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  Future<void> _showEditTaskDialog(BuildContext context) async {
    final task = controller.task.value;
    if (task == null) return;

    controller.titleController.text = task.title;
    controller.descriptionController.text = task.description;
    controller.selectedDueDate.value = task.dueDate;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
                title: const Text('Due Date'),
                subtitle: Obx(() => Text(
                      controller.formatDate(controller.selectedDueDate.value),
                    )),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => controller.pickDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: task.priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Low')),
                  DropdownMenuItem(value: 1, child: Text('Medium')),
                  DropdownMenuItem(value: 2, child: Text('High')),
                  DropdownMenuItem(value: 3, child: Text('Urgent')),
                ],
                onChanged: controller.updatePriority,
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
              controller.updateTask();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssigneeDialog(BuildContext context) async {
    if (!controller.hasPermission('assign_tasks')) {
      Get.snackbar(
        'Error',
        'You don\'t have permission to assign tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Assignee'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.projectMembers.isEmpty) {
              return const Center(
                child: Text('No members available'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.projectMembers.length,
              itemBuilder: (context, index) {
                final member = controller.projectMembers[index];
                final assignedTasks = member['assignedTasks'] as int? ?? 0;
                final taskLimit = member['taskLimit'] as int? ?? 5;
                final isEnabled = assignedTasks < taskLimit;

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(member['name']?.toString() ??
                      member['email']?.toString() ??
                      'Unknown User'),
                  subtitle: Text(
                    'Tasks: $assignedTasks/$taskLimit',
                    style: TextStyle(
                      color: isEnabled ? Colors.grey : Colors.red,
                    ),
                  ),
                  enabled: isEnabled,
                  onTap: isEnabled
                      ? () {
                          controller.updateAssignee(member['uid'] as String);
                          Get.back();
                        }
                      : null,
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
