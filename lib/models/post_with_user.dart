import 'package:booq_last_attempt/models/post.dart';
import 'package:booq_last_attempt/models/user.dart';

class PostWithUser {
  final Post post;
  final AppUser user;
  final Post? originalPost;
  final AppUser? originalPostUser;

  PostWithUser({
    required this.post,
    required this.user,
    this.originalPost,
    this.originalPostUser,
  });
}
