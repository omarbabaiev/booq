import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String text;
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.text,
    required this.userName,
    required this.userEmail,
    required this.userPhotoUrl,
    this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      text: map['text'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
