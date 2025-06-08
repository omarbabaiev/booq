import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  static final UserService _userService = UserService();

  static Future<Map<String, dynamic>> addPost({
    required String text,
    required String userUid,
    required List<String> imageUrls,
    String? repostedFromPostId,
  }) async {
    try {
      final currentUser = await _userService.getUserById(userUid);
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Kullanıcı bulunamadı.',
        }; // User not found
      }

      final now = DateTime.now();
      DateTime lastPostTimestamp =
          currentUser.lastPostTimestamp ?? DateTime(2000);
      int postsTodayCount = currentUser.postsTodayCount;

      // Reset count if it's a new day
      if (lastPostTimestamp.year != now.year ||
          lastPostTimestamp.month != now.month ||
          lastPostTimestamp.day != now.day) {
        postsTodayCount = 0;
      }

      if (postsTodayCount >= 5) {
        return {
          'success': false,
          'message': 'Gündə 5-dən çox paylaşım edə bilməzsiniz.',
        };
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'userUid': userUid,
        'likes': [],
        'commentsCount': 0,
        'reposts': 0,
        'imageUrls': imageUrls,
        'repostedFromPostId': repostedFromPostId,
      });

      // Update user's post count and timestamp via UserService transaction
      await _userService.updatePostCountAndTimestamp(userUid);
      await _userService.incrementUserPostsCount(userUid);

      return {'success': true, 'message': 'Paylaşım uğurla göndərildi!'};
    } catch (e) {
      print('Post əlavə edilərkən xəta: ' + e.toString());
      return {
        'success': false,
        'message': 'Post əlavə edilərkən xəta: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> repostPost({
    required String originalPostId,
    required String repostingUserUid,
  }) async {
    try {
      final currentUser = await _userService.getUserById(repostingUserUid);
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Kullanıcı bulunamadı.',
        }; // Reposting user not found
      }

      final now = DateTime.now();
      DateTime lastRepostTimestamp =
          currentUser.lastRepostTimestamp ?? DateTime(2000);
      int repostsTodayCount = currentUser.repostsTodayCount;

      // Reset count if it's a new day
      if (lastRepostTimestamp.year != now.year ||
          lastRepostTimestamp.month != now.month ||
          lastRepostTimestamp.day != now.day) {
        repostsTodayCount = 0;
      }

      if (repostsTodayCount >= 5) {
        return {
          'success': false,
          'message': 'Gündə 5-dən çox repost edə bilməzsiniz.',
        };
      }

      final originalPostDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(originalPostId)
              .get();

      if (!originalPostDoc.exists || originalPostDoc.data() == null) {
        print('Original post not found: $originalPostId');
        return {'success': false, 'message': 'Orijinal post tapılmadı.'};
      }

      final originalPost = Post.fromMap(
        originalPostDoc.data()!,
        originalPostDoc.id,
      );

      await FirebaseFirestore.instance.collection('posts').add({
        'text': '',
        'createdAt': FieldValue.serverTimestamp(),
        'userUid': repostingUserUid,
        'likes': [],
        'commentsCount': 0,
        'reposts': 0,
        'imageUrls': [],
        'repostedFromPostId': originalPostId,
      });

      // Update user's repost count and timestamp via UserService transaction
      await _userService.updateRepostCountAndTimestamp(repostingUserUid);
      await _userService.incrementUserPostsCount(repostingUserUid);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(originalPostId)
          .update({'reposts': FieldValue.increment(1)});

      return {'success': true, 'message': 'Paylaşım uğurla repost edildi!'};
    } catch (e) {
      print('Repost əlavə edilərkən xəta: ' + e.toString());
      return {
        'success': false,
        'message': 'Repost əlavə edilərkən xəta: ${e.toString()}',
      };
    }
  }

  static Future<void> deletePost(
    String postId,
    String userUid,
    List<String> imageUrls,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      batch.delete(FirebaseFirestore.instance.collection('posts').doc(postId));

      // Fetch user to check postsCount before decrementing
      final currentUserAppUser = await _userService.getUserById(userUid);
      if (currentUserAppUser != null && currentUserAppUser.postsCount > 0) {
        batch.update(
          FirebaseFirestore.instance.collection('users').doc(userUid),
          {'postsCount': FieldValue.increment(-1)},
        );
      }

      if (imageUrls.isNotEmpty) {
        final storage = FirebaseStorage.instance;
        for (String url in imageUrls) {
          try {
            final Uri uri = Uri.parse(url);
            String path = uri.pathSegments
                .sublist(uri.pathSegments.indexOf('o') + 1)
                .join('/');
            path = Uri.decodeComponent(path);
            await storage.ref(path).delete();
          } catch (e) {
            print('Error deleting image from Storage: $e');
          }
        }
      }

      await batch.commit();
      print('Post and associated data deleted successfully.');
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  static Future<Post?> getPostById(String postId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
      if (doc.exists && doc.data() != null) {
        return Post.fromMap(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Post gətirilərkən xəta: ' + e.toString());
      return null;
    }
  }

  static Future<void> likePost(String postId, String userId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  static Future<void> unlikePost(String postId, String userId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  static Future<void> repost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'reposts': FieldValue.increment(1),
    });
  }

  static Future<void> incrementComments(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }
}
