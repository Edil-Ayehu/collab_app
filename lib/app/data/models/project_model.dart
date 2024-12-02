import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy;
  final List<String> members;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
    required this.members,
    this.status = 'in progress',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'members': members,
      'status': status,
    };
  }

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      status: data['status'] ?? 'in progress',
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? deadline,
    DateTime? createdAt,
    String? createdBy,
    List<String>? members,
    String? status,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      status: status ?? this.status,
    );
  }
} 