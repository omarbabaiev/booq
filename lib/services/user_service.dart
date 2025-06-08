import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // Import Uint8List

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUserExists(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<bool> isUsernameUnique(String username) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> createOrUpdateUserProfile({
    required String userId,
    required String name,
    required String email,
    required String photoUrl,
    String? username,
    String? bio,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();
    final data = <String, dynamic>{
      // Explicitly define map type
      'id': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'username': username ?? '',
      'bio': bio ?? '',
      'createdAt':
          doc.exists
              ? doc.data() != null
                  ? doc.data()!['createdAt']
                  : FieldValue.serverTimestamp()
              : FieldValue.serverTimestamp(), // Preserve createdAt if exists
    };

    // Set lastUsernameChangeDate only if creating for the first time or username is being set for the first time
    if (!doc.exists || (doc.exists && doc.data()?['username'] == null)) {
      data['lastUsernameChangeDate'] = FieldValue.serverTimestamp();
    }

    await userRef.set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? newPhotoPath, // Path to the new photo file
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists || doc.data() == null) {
      return {
        'success': false,
        'message': 'Kullanıcı tapılmadı.',
      }; // User not found
    }

    final currentUser = AppUser.fromMap(doc.data()!, doc.id);
    String? updatedUsername =
        username; // Keep track of the username being updated

    // Check username change restriction
    if (username != null &&
        username.isNotEmpty &&
        username != currentUser.username) {
      final lastChangeDate = currentUser.lastUsernameChangeDate;
      final now = DateTime.now();
      final minChangeInterval = Duration(days: 14);

      if (lastChangeDate != null &&
          now.difference(lastChangeDate) < minChangeInterval) {
        final remainingDays =
            minChangeInterval.inDays - now.difference(lastChangeDate).inDays;
        return {
          'success': false,
          'message':
              'İstifadəçi adınızı ${remainingDays} gün ərzində yenidən dəyişə bilməzsiniz.',
        }; // Restriction applies
      }

      // Check username uniqueness only if changing
      final isUnique = await isUsernameUnique(username);
      if (!isUnique) {
        return {
          'success': false,
          'message': 'Bu istifadəçi adı artıq istifadə olunur.',
        }; // Not unique
      }
    }

    String? updatedPhotoUrl;
    // Upload new photo if provided
    if (newPhotoPath != null && newPhotoPath.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$userId.jpg');
        // Read file as bytes and convert to Uint8List (Placeholder)
        final fileBytes = await readFileAsBytes(newPhotoPath);
        final uint8List = Uint8List.fromList(
          fileBytes,
        ); // Convert List<int> to Uint8List
        final uploadTask = await storageRef.putData(uint8List); // Use Uint8List
        updatedPhotoUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        print('Şəkil yüklənməsi xətası: $e');
        return {
          'success': false,
          'message': 'Profil şəkli yüklənərkən xəta baş verdi.',
        }; // Photo upload failed
      }
    }

    final Map<String, dynamic> updateData = {};
    if (username != null &&
        username.isNotEmpty &&
        username != currentUser.username) {
      updateData['username'] = username;
      updateData['lastUsernameChangeDate'] =
          FieldValue.serverTimestamp(); // Update change date
    }
    if (bio != null) {
      updateData['bio'] = bio; // Allow setting bio to empty string
    }
    if (updatedPhotoUrl != null) {
      updateData['photoUrl'] = updatedPhotoUrl;
    }

    if (updateData.isNotEmpty) {
      await userRef.update(updateData);
    }

    return {'success': true, 'message': 'Profil uğurla yeniləndi.'}; // Success
  }

  // Helper function to read file as bytes (need to add platform-specific implementation or use a package like image_picker)
  Future<List<int>> readFileAsBytes(String path) async {
    // This is a placeholder. In a real app, you would use file system packages.
    // Using image_picker for example:
    // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) { return await pickedFile.readAsBytes(); }
    // return [];
    throw UnimplementedError(
      'File reading not implemented. Use a package like image_picker.',
    );
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Kullanıcı profili getirilirken hata: $e');
      return null;
    }
  }

  Stream<List<AppUser>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AppUser.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> sendFollowRequest(
    String currentUserId,
    String targetUserId,
  ) async {
    await _firestore.collection('users').doc(targetUserId).update({
      'followRequests': FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Update current user's following array and count
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayUnion([targetUserId]),
      'followingCount': FieldValue.increment(1),
    });

    // Update target user's followers array and count, and remove follow request
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayUnion([currentUserId]),
      'followRequests': FieldValue.arrayRemove([currentUserId]),
      'followersCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Update current user's following array and count
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayRemove([targetUserId]),
      'followingCount': FieldValue.increment(-1),
    });

    // Update target user's followers array and count
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayRemove([currentUserId]),
      'followersCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<void> incrementUserPostsCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  Future<void> decrementUserPostsCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(-1),
    });
  }

  Future<AppUser?> updatePostCountAndTimestamp(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    return _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User not found');
      }

      final currentUser = AppUser.fromMap(userDoc.data()!, userDoc.id);
      final now = DateTime.now();

      int newPostsTodayCount = currentUser.postsTodayCount;
      DateTime? newLastPostTimestamp = currentUser.lastPostTimestamp;

      // Reset count if it's a new day
      if (newLastPostTimestamp == null ||
          newLastPostTimestamp.year != now.year ||
          newLastPostTimestamp.month != now.month ||
          newLastPostTimestamp.day != now.day) {
        newPostsTodayCount = 0;
      }

      newPostsTodayCount++;
      newLastPostTimestamp = now;

      transaction.update(userRef, {
        'postsTodayCount': newPostsTodayCount,
        'lastPostTimestamp': FieldValue.serverTimestamp(),
      });

      // Return the updated user object (optional, but useful for client-side state)
      return AppUser(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        followers: currentUser.followers,
        following: currentUser.following,
        followRequests: currentUser.followRequests,
        username: currentUser.username,
        bio: currentUser.bio,
        lastUsernameChangeDate: currentUser.lastUsernameChangeDate,
        followersCount: currentUser.followersCount,
        followingCount: currentUser.followingCount,
        postsCount: currentUser.postsCount,
        postsTodayCount: newPostsTodayCount,
        lastPostTimestamp: newLastPostTimestamp,
        repostsTodayCount: currentUser.repostsTodayCount,
        lastRepostTimestamp: currentUser.lastRepostTimestamp,
        commentsLastHourCount: currentUser.commentsLastHourCount,
        lastCommentTimestamp: currentUser.lastCommentTimestamp,
      );
    });
  }

  Future<AppUser?> updateRepostCountAndTimestamp(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    return _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User not found');
      }

      final currentUser = AppUser.fromMap(userDoc.data()!, userDoc.id);
      final now = DateTime.now();

      int newRepostsTodayCount = currentUser.repostsTodayCount;
      DateTime? newLastRepostTimestamp = currentUser.lastRepostTimestamp;

      // Reset count if it's a new day
      if (newLastRepostTimestamp == null ||
          newLastRepostTimestamp.year != now.year ||
          newLastRepostTimestamp.month != now.month ||
          newLastRepostTimestamp.day != now.day) {
        newRepostsTodayCount = 0;
      }

      newRepostsTodayCount++;
      newLastRepostTimestamp = now;

      transaction.update(userRef, {
        'repostsTodayCount': newRepostsTodayCount,
        'lastRepostTimestamp': FieldValue.serverTimestamp(),
      });

      return AppUser(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        followers: currentUser.followers,
        following: currentUser.following,
        followRequests: currentUser.followRequests,
        username: currentUser.username,
        bio: currentUser.bio,
        lastUsernameChangeDate: currentUser.lastUsernameChangeDate,
        followersCount: currentUser.followersCount,
        followingCount: currentUser.followingCount,
        postsCount: currentUser.postsCount,
        postsTodayCount: currentUser.postsTodayCount,
        lastPostTimestamp: currentUser.lastPostTimestamp,
        repostsTodayCount: newRepostsTodayCount,
        lastRepostTimestamp: newLastRepostTimestamp,
        commentsLastHourCount: currentUser.commentsLastHourCount,
        lastCommentTimestamp: currentUser.lastCommentTimestamp,
      );
    });
  }

  Future<AppUser?> updateCommentCountAndTimestamp(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    return _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User not found');
      }

      final currentUser = AppUser.fromMap(userDoc.data()!, userDoc.id);
      final now = DateTime.now();

      int newCommentsLastHourCount = currentUser.commentsLastHourCount;
      DateTime? newLastCommentTimestamp = currentUser.lastCommentTimestamp;

      // Reset count if it's been more than an hour
      if (newLastCommentTimestamp == null ||
          now.difference(newLastCommentTimestamp).inHours >= 1) {
        newCommentsLastHourCount = 0;
      }

      newCommentsLastHourCount++;
      newLastCommentTimestamp = now;

      transaction.update(userRef, {
        'commentsLastHourCount': newCommentsLastHourCount,
        'lastCommentTimestamp': FieldValue.serverTimestamp(),
      });

      return AppUser(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        followers: currentUser.followers,
        following: currentUser.following,
        followRequests: currentUser.followRequests,
        username: currentUser.username,
        bio: currentUser.bio,
        lastUsernameChangeDate: currentUser.lastUsernameChangeDate,
        followersCount: currentUser.followersCount,
        followingCount: currentUser.followingCount,
        postsCount: currentUser.postsCount,
        postsTodayCount: currentUser.postsTodayCount,
        lastPostTimestamp: currentUser.lastPostTimestamp,
        repostsTodayCount: currentUser.repostsTodayCount,
        lastRepostTimestamp: currentUser.lastRepostTimestamp,
        commentsLastHourCount: newCommentsLastHourCount,
        lastCommentTimestamp: newLastCommentTimestamp,
      );
    });
  }
}
