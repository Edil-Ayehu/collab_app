import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String assignedTo;
  final String createdBy;
  final DateTime createdAt;
  final int priority;
  final List<String> attachments;
  final List<Map<String, dynamic>> comments;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    required this.priority,
    required this.attachments,
    required this.comments,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'todo',
      assignedTo: data['assignedTo'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: data['priority'] ?? 0,
      attachments: List<String>.from(data['attachments'] ?? []),
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority,
      'attachments': attachments,
      'comments': comments,
    };
  }
} 