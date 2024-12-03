import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';
import '../../../helpers/role_permissions.dart';

class TaskDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final task = Rxn<Task>();
  final comments = <Map<String, dynamic>>[].obs;
  final projectMembers = <Map<String, dynamic>>[].obs;
  final assigneeName = ''.obs;
  final assigneeEmail = ''.obs;
  final isLoading = false.obs;
  final currentUserRole = ''.obs;

  // Controllers for editing
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final commentController = TextEditingController();
  final selectedDueDate = DateTime.now().obs;

  final mentionFilter = ''.obs;
  final showMentionsList = false.obs;
  final filteredMembers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTaskDetails().then((_) {
      checkUserRole();
      loadProjectMembers();
    });
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadTaskDetails() async {
    isLoading.value = true;
    try {
      final taskId = Get.parameters['id'];
      if (taskId != null) {
        final doc = await _firestore.collection('tasks').doc(taskId).get();
        task.value = Task.fromFirestore(doc);

        await loadComments();
        await loadAssigneeName();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .doc(task.value?.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      comments.value = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final userDoc = await _firestore
              .collection('users')
              .doc(data['userId'] as String)
              .get();

          return {
            ...data,
            'id': doc.id,
            'userName': userDoc.data()?['name'] ?? 'Unknown User',
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
          };
        }).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load comments',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadProjectMembers() async {
    try {
      final projectDoc = await _firestore
          .collection('projects')
          .doc(task.value?.projectId)
          .get();

      final memberIds = List<String>.from(projectDoc.data()?['members'] ?? []);

      // Get all tasks to count assignments
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: task.value?.projectId)
          .get();

      // Count tasks per member
      final taskCounts = <String, int>{};
      for (var taskDoc in tasksSnapshot.docs) {
        final assigneeId = taskDoc.data()['assignedTo'] as String?;
        if (assigneeId != null) {
          taskCounts[assigneeId] = (taskCounts[assigneeId] ?? 0) + 1;
        }
      }

      projectMembers.value = await Future.wait(
        memberIds.map((memberId) async {
          final userDoc =
              await _firestore.collection('users').doc(memberId).get();

          final userData = userDoc.data() ?? {};
          return {
            'uid': memberId,
            'email': userData['email'] ?? '',
            'name': userData['name'] ?? '',
            'taskLimit':
                userData['taskLimit'] ?? 5, // Default limit of 5 if not set
            'assignedTasks': taskCounts[memberId] ?? 0,
          };
        }).toList(),
      );
    } catch (e) {
      print('Error loading project members: $e'); // Debug print
      Get.snackbar(
        'Error',
        'Failed to load project members',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadAssigneeName() async {
    try {
      final assigneeId = task.value?.assigneeId;
      if (assigneeId == null) {
        assigneeName.value = 'Unassigned';
        assigneeEmail.value = '';
        return;
      }

      final userDoc = await _firestore.collection('users').doc(assigneeId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        assigneeName.value = userData['name'] ?? 'Unknown User';
        assigneeEmail.value = userData['email'] ?? '';
      } else {
        assigneeName.value = 'Unknown User';
        assigneeEmail.value = '';
      }

      print('Loaded assignee name: ${assigneeName.value}'); // Debug print
      print('Loaded assignee email: ${assigneeEmail.value}'); // Debug print
    } catch (e) {
      print('Error loading assignee details: $e'); // Debug print
      assigneeName.value = 'Error loading assignee';
      assigneeEmail.value = '';
      Get.snackbar(
        'Error',
        'Failed to load assignee details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTask() async {
    try {
      final taskId = task.value?.id;
      if (taskId == null) return;

      await _firestore.collection('tasks').doc(taskId).update({
        'title': titleController.text,
        'description': descriptionController.text,
        'dueDate': Timestamp.fromDate(selectedDueDate.value),
      });

      await loadTaskDetails();

      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTaskStatus(String newStatus) async {
    try {
      final taskId = task.value?.id;
      if (taskId == null) return;

      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
      });

      await loadTaskDetails();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePriority(int? newPriority) async {
    try {
      final taskId = task.value?.id;
      if (taskId == null || newPriority == null) return;

      await _firestore.collection('tasks').doc(taskId).update({
        'priority': newPriority,
      });

      await loadTaskDetails();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update priority',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAssignee(String newAssigneeId) async {
    print('Current user role: ${currentUserRole.value}'); // Debug print
    if (!hasPermission('assign_tasks')) {
      Get.snackbar(
        'Error',
        'You don\'t have permission to assign tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final taskId = task.value?.id;
      if (taskId == null) return;

      await _firestore.collection('tasks').doc(taskId).update({
        'assigneeId':
            newAssigneeId, // Make sure this matches with loadAssigneeName
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await loadTaskDetails(); // This will reload assignee name
      Get.snackbar(
        'Success',
        'Task assigned successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error assigning task: $e'); // Debug print
      Get.snackbar(
        'Error',
        'Failed to assign task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addComment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final commentText = commentController.text.trim();
      if (commentText.isEmpty) return;

      // Extract mentions from comment
      final mentionedUsers = <String>{};
      final regex = RegExp(r'@(\w+)');
      final matches = regex.allMatches(commentText);
      
      for (final match in matches) {
        final username = match.group(1);
        if (username != null) {
          final member = projectMembers.firstWhereOrNull(
            (m) => m['name']?.toString() == username || 
                   m['email']?.toString() == username
          );
          if (member != null) {
            mentionedUsers.add(member['uid'] as String);
          }
        }
      }

      await _firestore
          .collection('tasks')
          .doc(task.value?.id)
          .collection('comments')
          .add({
        'text': commentText,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'mentions': mentionedUsers.toList(),
      });

      commentController.clear();
      loadComments();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDueDate.value = picked;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> checkUserRole() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final projectDoc = await _firestore
          .collection('projects')
          .doc(task.value?.projectId)
          .get();

      if (projectDoc.exists) {
        // Check if user is the project creator
        if (userId == projectDoc.data()?['createdBy']) {
          currentUserRole.value = 'creator';
          print('User is creator: $userId'); // Debug print
        } else {
          // If not creator, get role from memberRoles
          final memberRoles =
              projectDoc.data()?['memberRoles'] as Map<String, dynamic>?;
          currentUserRole.value = memberRoles?[userId] ?? 'viewer';
          print(
              'User role from memberRoles: ${currentUserRole.value}'); // Debug print
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
      currentUserRole.value = 'viewer'; // Default to viewer on error
    }
  }

  bool hasPermission(String permission) {
    print(
        'Checking permission: $permission for role: ${currentUserRole.value}'); // Debug print
    final hasPermission =
        RolePermissions.hasPermission(currentUserRole.value, permission);
    print('Permission result: $hasPermission'); // Debug print
    return hasPermission;
  }

  void filterMembersForMention(String query) {
    if (query.isEmpty) {
      showMentionsList.value = false;
      return;
    }
    
    final searchText = query.toLowerCase();
    filteredMembers.value = projectMembers
        .where((member) => 
          (member['name']?.toString().toLowerCase() ?? '')
              .contains(searchText) ||
          (member['email']?.toString().toLowerCase() ?? '')
              .contains(searchText))
        .toList();
    
    showMentionsList.value = true;
  }

  void selectMemberMention(Map<String, dynamic> member) {
    final currentText = commentController.text;
    final lastAtIndex = currentText.lastIndexOf('@');
    
    if (lastAtIndex != -1) {
      final beforeMention = currentText.substring(0, lastAtIndex);
      final memberName = member['name']?.toString() ?? member['email']?.toString() ?? '';
      commentController.text = '$beforeMention@$memberName ';
      commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: commentController.text.length),
      );
    }
    
    showMentionsList.value = false;
  }
}
