import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_model.dart';

class ProjectController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final projects = <Project>[].obs;
  final isLoading = false.obs;
  
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDeadline = DateTime.now().add(const Duration(days: 7)).obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('projects')
          .where('members', arrayContains: userId)
          .get();

      projects.value = snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load projects',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProject() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final project = Project(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        deadline: selectedDeadline.value,
        status: 'pending',
        members: [userId],
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('projects')
          .add(project.toFirestore());

      nameController.clear();
      descriptionController.clear();
      selectedDeadline.value = DateTime.now().add(const Duration(days: 7));
      
      loadProjects();
      
      Get.snackbar(
        'Success',
        'Project created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create project',
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

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void openProjectDetails(Project project) {
    // TODO: Implement project details view
    Get.toNamed('/project/${project.id}');
  }
} 