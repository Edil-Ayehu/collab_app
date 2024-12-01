import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final String status;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.status,
    required this.members,
    required this.createdBy,
    required this.createdAt,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      members: List<String>.from(data['members'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'members': members,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 