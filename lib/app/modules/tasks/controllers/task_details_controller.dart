import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';

class TaskDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final task = Rxn<Task>();
  final comments = <Map<String, dynamic>>[].obs;
  final projectMembers = <Map<String, dynamic>>[].obs;
  final assigneeName = ''.obs;
  final isLoading = false.obs;

  // Controllers for editing
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final commentController = TextEditingController();
  final selectedDueDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    final taskId = Get.parameters['id'];
    if (taskId != null) {
      loadTask(taskId);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadTask(String taskId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      task.value = Task.fromFirestore(doc);
      
      await loadComments();
      await loadProjectMembers();
      await loadAssigneeName();
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
      
      projectMembers.value = await Future.wait(
        memberIds.map((memberId) async {
          final userDoc = await _firestore
              .collection('users')
              .doc(memberId)
              .get();
          
          return {
            'uid': memberId,
            'email': userDoc.data()?['email'] ?? '',
            'name': userDoc.data()?['name'] ?? '',
          };
        }).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load project members',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadAssigneeName() async {
    try {
      final assigneeId = task.value?.assignedTo;
      if (assigneeId == null) return;

      final userDoc = await _firestore
          .collection('users')
          .doc(assigneeId)
          .get();

      assigneeName.value = userDoc.data()?['name'] ?? 'Unknown User';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assignee name',
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

      await loadTask(taskId);

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

      await loadTask(taskId);
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

      await loadTask(taskId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update priority',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAssignee(String newAssigneeId) async {
    try {
      final taskId = task.value?.id;
      if (taskId == null) return;

      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': newAssigneeId,
      });

      await loadTask(taskId);

      Get.snackbar(
        'Success',
        'Task assignee updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update assignee',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addComment() async {
    try {
      final taskId = task.value?.id;
      final userId = _auth.currentUser?.uid;
      if (taskId == null || userId == null) return;

      final comment = {
        'text': commentController.text,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(comment);

      commentController.clear();
      await loadComments();
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
} 