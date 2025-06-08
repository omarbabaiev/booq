import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final DateTime? createdAt;
  final List<String> likes;
  final int commentsCount;
  final int reposts;
  final String userUid;
  final List<String> imageUrls;
  final String? repostedFromPostId;

  Post({
    required this.id,
    required this.text,
    this.createdAt,
    required this.likes,
    required this.commentsCount,
    required this.reposts,
    required this.userUid,
    required this.imageUrls,
    this.repostedFromPostId,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      text: map['text'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      reposts: map['reposts'] ?? 0,
      userUid: map['userUid'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      repostedFromPostId: map['repostedFromPostId'],
    );
  }
}
