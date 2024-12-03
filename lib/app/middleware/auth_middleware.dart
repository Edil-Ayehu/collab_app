import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser == null && 
        route != Routes.auth && 
        route != Routes.register) {
      return const RouteSettings(name: Routes.auth);
    }
    return null;
  }
} 