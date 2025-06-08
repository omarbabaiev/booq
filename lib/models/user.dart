import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final List<String> followers;
  final List<String> following;
  final List<String> followRequests;
  final String? username;
  final String? bio;
  final DateTime? lastUsernameChangeDate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int postsTodayCount;
  final DateTime? lastPostTimestamp;
  final int repostsTodayCount;
  final DateTime? lastRepostTimestamp;
  final int commentsLastHourCount;
  final DateTime? lastCommentTimestamp;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.followRequests,
    this.username,
    this.bio,
    this.lastUsernameChangeDate,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.postsTodayCount = 0,
    this.lastPostTimestamp,
    this.repostsTodayCount = 0,
    this.lastRepostTimestamp,
    this.commentsLastHourCount = 0,
    this.lastCommentTimestamp,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      followRequests: List<String>.from(map['followRequests'] ?? []),
      username: map['username'],
      bio: map['bio'],
      lastUsernameChangeDate:
          map['lastUsernameChangeDate'] != null
              ? (map['lastUsernameChangeDate'] as Timestamp).toDate()
              : null,
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      postsTodayCount: map['postsTodayCount'] ?? 0,
      lastPostTimestamp:
          map['lastPostTimestamp'] != null
              ? (map['lastPostTimestamp'] as Timestamp).toDate()
              : null,
      repostsTodayCount: map['repostsTodayCount'] ?? 0,
      lastRepostTimestamp:
          map['lastRepostTimestamp'] != null
              ? (map['lastRepostTimestamp'] as Timestamp).toDate()
              : null,
      commentsLastHourCount: map['commentsLastHourCount'] ?? 0,
      lastCommentTimestamp:
          map['lastCommentTimestamp'] != null
              ? (map['lastCommentTimestamp'] as Timestamp).toDate()
              : null,
    );
  }
}
