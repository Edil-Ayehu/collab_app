import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final tasks = <Task>[].obs;
  final filteredTasks = <Task>[].obs;
  final isLoading = false.obs;
  
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  final selectedDueDate = DateTime.now().add(const Duration(days: 1)).obs;
  final selectedPriority = 0.obs;
  final currentFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .get();

      tasks.value = snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
      
      filterTasks(searchController.text);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final task = Task(
        id: '',
        projectId: '', // TODO: Add project selection
        title: titleController.text,
        description: descriptionController.text,
        dueDate: selectedDueDate.value,
        status: 'todo',
        assignedTo: userId,
        createdBy: userId,
        createdAt: DateTime.now(),
        priority: selectedPriority.value,
        attachments: [],
        comments: [],
      );

      await _firestore
          .collection('tasks')
          .add(task.toFirestore());

      titleController.clear();
      descriptionController.clear();
      selectedDueDate.value = DateTime.now().add(const Duration(days: 1));
      selectedPriority.value = 0;
      
      loadTasks();
      
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

  void filterTasks(String query) {
    final searchText = query.toLowerCase();
    filteredTasks.value = tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(searchText) ||
          task.description.toLowerCase().contains(searchText);
      final matchesFilter = currentFilter.value == 'all' ||
          task.status == currentFilter.value;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void changeFilter(String filter) {
    currentFilter.value = filter;
    filterTasks(searchController.text);
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

  void openTaskDetails(Task task) {
    // TODO: Implement task details view
    Get.toNamed('/task/${task.id}');
  }
} 