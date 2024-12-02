import 'package:collab_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../projects/controllers/project_controller.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../projects/views/project_view.dart';
import '../../tasks/views/task_view.dart';
import '../views/overview_view.dart';
import '../views/settings_view.dart';

class DashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    Get.put(ProjectController());
    Get.put(TaskController());
  }

  final List<Widget> pages = [
    const OverviewView(),
    const ProjectView(),
    const TaskView(),
    const SettingsView(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.auth);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 