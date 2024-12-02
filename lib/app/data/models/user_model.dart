import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String availabilityStatus;
  final int taskLimit;
  final int assignedTasks;
  final Map<String, int> contributions;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.availabilityStatus,
    required this.taskLimit,
    required this.assignedTasks,
    required this.contributions,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'availabilityStatus': availabilityStatus,
      'taskLimit': taskLimit,
      'assignedTasks': assignedTasks,
      'contributions': contributions,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'member',
      availabilityStatus: data['availabilityStatus'] ?? 'available',
      taskLimit: data['taskLimit'] ?? 5,
      assignedTasks: data['assignedTasks'] ?? 0,
      contributions: Map<String, int>.from(data['contributions'] ?? {}),
    );
  }
} 