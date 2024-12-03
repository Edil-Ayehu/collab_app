import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy;
  final List<String> members;
  final Map<String, String> memberRoles;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
    required this.members,
    required this.memberRoles,
    this.status = 'ongoing',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'members': members,
      'memberRoles': memberRoles,
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
      memberRoles: Map<String, String>.from(data['memberRoles'] ?? {}),
      status: data['status'] ?? 'ongoing',
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
    Map<String, String>? memberRoles,
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
      memberRoles: memberRoles ?? this.memberRoles,
      status: status ?? this.status,
    );
  }
} 