import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/task_model.dart';

class ProjectDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final project = Rxn<Project>();
  final tasks = <Task>[].obs;
  final filteredTasks = <Task>[].obs;
  final members = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final taskFilter = 'all'.obs;
  final selectedFilter = 'all'.obs;

  // Controllers for editing project
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDeadline = DateTime.now().obs;

  // Controllers for adding members
  final emailController = TextEditingController();

  // Controllers for adding tasks
  final taskTitleController = TextEditingController();
  final taskDescriptionController = TextEditingController();
  final selectedTaskDueDate = DateTime.now().obs;

  // Add new variables
  final selectedRole = 'member'.obs;
  final isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAdminStatus();
    final projectId = Get.parameters['id'];
    if (projectId != null) {
      loadProject(projectId);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.onClose();
  }

  Future<void> loadProject(String projectId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      project.value = Project.fromFirestore(doc);
      await loadTasks();
      await loadMembers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load project',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTasks() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: project.value?.id)
          .get();

      tasks.value =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      filterTasks(taskFilter.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadMembers() async {
    try {
      members.clear();
      final membersList = project.value?.members ?? [];
      final creatorId = project.value?.createdBy;
      
      // Load creator first
      if (creatorId != null) {
        final creatorDoc = await _firestore.collection('users').doc(creatorId).get();
        if (creatorDoc.exists) {
          members.add({
            'uid': creatorId,
            'email': creatorDoc.data()?['email'] ?? '',
            'name': creatorDoc.data()?['name'] ?? '',
            'role': 'creator',  // Special role for creator
            'availabilityStatus': creatorDoc.data()?['availabilityStatus'] ?? 'available',
            'taskLimit': creatorDoc.data()?['taskLimit'] ?? 5,
            'assignedTasks': creatorDoc.data()?['assignedTasks'] ?? 0,
            'contributions': creatorDoc.data()?['contributions'] ?? {},
          });
        }
      }

      // Load other members
      for (final memberId in membersList) {
        if (memberId != creatorId) {  // Skip creator as they're already added
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            members.add({
              'uid': memberId,
              'email': userDoc.data()?['email'] ?? '',
              'name': userDoc.data()?['name'] ?? '',
              'role': userDoc.data()?['role'] ?? 'member',
              'availabilityStatus': userDoc.data()?['availabilityStatus'] ?? 'available',
              'taskLimit': userDoc.data()?['taskLimit'] ?? 5,
              'assignedTasks': userDoc.data()?['assignedTasks'] ?? 0,
              'contributions': userDoc.data()?['contributions'] ?? {},
            });
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load members');
    }
  }

  void filterTasks(String? filter) {
    if (filter != null) {
      selectedFilter.value = filter;
      taskFilter.value = filter;

      if (filter == 'all') {
        filteredTasks.value = tasks;
      } else {
        filteredTasks.value =
            tasks.where((task) => task.status == filter).toList();
      }
    }
  }

  Future<void> updateProject() async {
    try {
      final projectId = project.value?.id;
      if (projectId == null) return;

      await _firestore.collection('projects').doc(projectId).update({
        'name': nameController.text,
        'description': descriptionController.text,
        'deadline': Timestamp.fromDate(selectedDeadline.value),
      });

      await loadProject(projectId);

      Get.snackbar(
        'Success',
        'Project updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update project',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addMember() async {
    try {
      final email = emailController.text.trim();
      if (email.isEmpty) return;

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final userId = userQuery.docs.first.id;
      final projectId = project.value?.id;
      
      // Check if user is the creator
      if (userId == project.value?.createdBy) {
        Get.snackbar('Error', 'User is already the project creator');
        return;
      }

      if (projectId == null) return;

      await _firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'role': selectedRole.value,
        'taskLimit': 5,
        'assignedTasks': 0,
        'contributions': {
          'completed_tasks': 0,
          'comments': 0,
        },
      });

      emailController.clear();
      await loadMembers();
      Get.snackbar('Success', 'Member added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member');
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      final projectId = project.value?.id;
      if (projectId == null) return;

      await _firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayRemove([userId]),
      });

      await loadProject(projectId);

      Get.snackbar(
        'Success',
        'Member removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove member',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createTask() async {
    try {
      final projectId = project.value?.id;
      if (projectId == null) return;

      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final task = Task(
        id: '',
        projectId: projectId,
        title: taskTitleController.text,
        description: taskDescriptionController.text,
        dueDate: selectedTaskDueDate.value,
        status: 'todo',
        assignedTo: userId,
        createdBy: userId,
        createdAt: DateTime.now(),
        priority: 0,
        attachments: [],
        comments: [],
      );

      await _firestore.collection('tasks').add(task.toFirestore());

      taskTitleController.clear();
      taskDescriptionController.clear();
      selectedTaskDueDate.value = DateTime.now();

      await loadTasks();

      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTaskStatus(Task task, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'status': newStatus,
      });

      await loadTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).delete();
      await loadTasks();

      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDeadline.value = picked;
    }
  }

  Future<void> pickTaskDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTaskDueDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedTaskDueDate.value = picked;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'status': status,
      });

      // Optionally reload the project details
      await loadProjectDetails(projectId);

      Get.snackbar(
        'Success',
        'Project status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update project status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadProjectDetails(String projectId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        project.value = Project.fromFirestore(doc);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load project details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAdminStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        final userRole = userDoc.data()?['role'] as String?;
        isAdmin.value = userRole == 'admin';
      } else {
        isAdmin.value = false;
      }
    } catch (e) {
      isAdmin.value = false;
      print('Error checking admin status: $e');
    }
  }

  Future<void> updateMemberRole(String memberId, String newRole) async {
    try {
      await _firestore.collection('users').doc(memberId).update({
        'role': newRole,
      });
      await loadMembers();
      Get.snackbar('Success', 'Member role updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update member role');
    }
  }

  Future<void> updateMemberTaskLimit(String memberId, int newLimit) async {
    try {
      await _firestore.collection('users').doc(memberId).update({
        'taskLimit': newLimit,
      });
      await loadMembers();
      Get.snackbar('Success', 'Task limit updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task limit');
    }
  }
}
