import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post.dart';
import '../controllers/feed_controller.dart';
import '../utils/date_utils.dart';
import '../models/user.dart';
import '../../controllers/liked_users_controller.dart';
import '../../screens/home/widgets/liked_users_sheet.dart';
import '../../screens/image_view_screen.dart';
import '../models/post_with_user.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/post_controller.dart';

class PostCard extends StatelessWidget {
  final PostWithUser postWithUser;
  final VoidCallback? onComment;
  const PostCard({Key? key, required this.postWithUser, this.onComment})
    : super(key: key);

  // Function to build the text with 'more' option
  Widget _buildPostText(BuildContext context, String text) {
    const int maxLines = 3; // Or a different number based on desired height
    final span = TextSpan(
      text: text,
      style: TextStyle(fontSize: 16, color: Color(0xFF3A3A5A)),
    );
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection:
          TextDirection.ltr, // Or TextDirection.rtl based on language
    );
    tp.layout(
      maxWidth:
          MediaQuery.of(context).size.width -
          32, // Adjust max width based on padding
    ); // Adjust max width based on padding

    if (!tp.didExceedMaxLines) {
      return Text(
        text,
        style: TextStyle(fontSize: 16, color: Color(0xFF3A3A5A)),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Color(0xFF3A3A5A)),
          ),
          // You can make this InkWell or GestureDetector clickable to expand
          Text(
            '.. more', // Or localize this string
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  // New helper widget to display original post content
  Widget _buildOriginalPostContent(
    BuildContext context,
    Post originalPost,
    AppUser originalPostUser,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Reduced margin
      padding: const EdgeInsets.all(8.0), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lighter grey for background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!), // Lighter border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              originalPostUser.photoUrl.isNotEmpty
                  ? CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(originalPostUser.photoUrl),
                  )
                  : CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      originalPostUser.name.isNotEmpty
                          ? originalPostUser.name
                          : 'Anonim',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      originalPostUser.username != null &&
                              originalPostUser.username!.isNotEmpty
                          ? '@${originalPostUser.username!}'
                          : 'Username yoxdur',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPostText(context, originalPost.text),
          if (originalPost.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: originalPost.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          originalPost.imageUrls[index],
                          fit: BoxFit.cover,
                          width: 150, // Smaller width for original post images
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 150,
                              color: Colors.grey[300],
                              child: Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedController = Get.find<FeedController>();
    final authController = Get.find<AuthController>();
    final postController = Get.find<PostController>();

    final currentUserId = authController.user?.uid;
    final post = postWithUser.post;
    final user = postWithUser.user;
    final isLiked = currentUserId != null && post.likes.contains(currentUserId);

    final originalPost = postWithUser.originalPost;
    final originalPostUser = postWithUser.originalPostUser;

    return Container(
      color:
          Colors.white, // No rounded corners, no box shadow, just solid color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reposted by section
          if (originalPost != null && originalPostUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.repeat, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${user.username ?? user.name} reposted',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  _buildOriginalPostContent(
                    context,
                    originalPost,
                    originalPostUser,
                  ),
                ],
              ),
            ),
          // User Info and More Options
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                user.photoUrl.isNotEmpty
                    ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.photoUrl),
                    )
                    : CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, color: Color(0xFFB8B6F8)),
                    ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty ? user.name : 'Anonim',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A3A5A),
                        ),
                      ),
                      Text(
                        user.username != null && user.username!.isNotEmpty
                            ? '@${user.username!}'
                            : 'Username yoxdur',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'delete') {
                      Get.defaultDialog(
                        title: 'Postu Sil',
                        middleText:
                            'Bu postu silmək istədiyinizə əminsinizmi? Bu əməliyyat geri alına bilməz.',
                        textConfirm: 'Sil',
                        textCancel: 'Ləğv Et',
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.redAccent,
                        onConfirm: () async {
                          Get.back();
                          await postController.deletePost(
                            post.id,
                            post.userUid,
                            post.imageUrls,
                          );
                        },
                      );
                    } else if (result == 'report') {
                      Get.snackbar('Şikayət Edildi', 'Göndəri şikayət edildi.');
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (currentUserId == post.userUid) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Göndərini Sil'),
                        ),
                      ];
                    } else {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'report',
                          child: Text('Göndərini Şikayət Et'),
                        ),
                      ];
                    }
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Post Text
          if (post.text.isNotEmpty && originalPost == null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildPostText(context, post.text),
            ),
          // Post Images
          if (post.imageUrls.isNotEmpty && originalPost == null)
            // No padding here for full-width images
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 4.0,
                    ), // Reduced spacing between images
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: InkWell(
                        onTap: () {
                          Get.to(
                            () => ImageViewScreen(
                              imageUrl: post.imageUrls[index],
                              heroTag: 'postImage${post.id}$index',
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'postImage${post.id}$index',
                          child: Image.network(
                            post.imageUrls[index],
                            fit: BoxFit.cover,
                            width:
                                MediaQuery.of(context).size.width, // Full width
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.grey[300],
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Action Buttons and Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            if (currentUserId == null) {
                              Get.snackbar(
                                'Xəta',
                                'Bəyənmək üçün daxil olmalısınız.',
                              );
                              return;
                            }
                            if (isLiked) {
                              feedController.likeOrUnlike(post);
                            } else {
                              feedController.likeOrUnlike(post);
                            }
                          },
                        ),
                        Text('${post.likes.length} Bəyənmə'),
                        SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            Icons.comment_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: onComment,
                        ),
                        Text('${post.commentsCount} Şərh'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.repeat, color: Colors.grey),
                          onPressed: () {
                            if (currentUserId == null) {
                              Get.snackbar(
                                'Xəta',
                                'Repost etmək üçün daxil olmalısınız.',
                              );
                              return;
                            }
                            feedController.repost(post);
                          },
                        ),
                        Text('${post.reposts} Repost'),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatDate(post.createdAt!),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ), // Add a small vertical space between posts
        ],
      ),
    );
  }
}
