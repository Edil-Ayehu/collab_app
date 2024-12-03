import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String projectId;
  final String? assigneeId;
  final String createdBy;
  final DateTime createdAt;
  final int priority;
  final List<String> attachments;
  final List<Map<String, dynamic>> comments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.projectId,
    this.assigneeId,
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
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'todo',
      projectId: data['projectId'] ?? '',
      assigneeId: data['assigneeId'],
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
      'assigneeId': assigneeId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority,
      'attachments': attachments,
      'comments': comments,
    };
  }
} 