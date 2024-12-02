import 'package:collab_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn.value = true;
        Get.offAllNamed(Routes.dashboard);
      } else {
        isLoggedIn.value = false;
        Get.offAllNamed(Routes.auth);
      }
    });
  }

  Future<void> signIn() async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(Routes.dashboard);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        throw FirebaseAuthException(
          code: 'passwords-dont-match',
          message: 'Passwords do not match',
        );
      }

      if (nameController.text.isEmpty || phoneController.text.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-fields',
          message: 'Please fill in all fields',
        );
      }

      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = UserModel(
        id: userCredential.user!.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        role: 'member',
        availabilityStatus: 'available',
        taskLimit: 5,
        assignedTasks: 0,
        contributions: {},
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toFirestore());

      Get.offAllNamed(Routes.dashboard);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 