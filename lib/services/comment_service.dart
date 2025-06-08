import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  static Future<void> addComment({
    required String postId,
    required String text,
    required String userName,
    required String userEmail,
    required String userPhotoUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'postId': postId,
      'text': text,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Comment>> getComments(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.id))
            .toList());
  }
}
