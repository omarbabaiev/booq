import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/comment_controller.dart';
import '../../../utils/date_utils.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';

class CommentSheet extends StatelessWidget {
  final Post post;
  final AppUser postUser;
  CommentSheet({required this.post, required this.postUser});

  @override
  Widget build(BuildContext context) {
    final commentController = Get.put(CommentController(post.id));
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Şərhlər',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final comments = commentController.comments;
                if (comments.isEmpty) {
                  return Center(child: Text('Hələ şərh yoxdur.'));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading:
                          comment.userPhotoUrl.isNotEmpty
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  comment.userPhotoUrl,
                                ),
                              )
                              : CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        comment.userName.isNotEmpty
                            ? comment.userName
                            : 'Anonim',
                      ),
                      subtitle: Text(comment.text),
                      trailing:
                          comment.createdAt != null
                              ? Text(formatDate(comment.createdAt!))
                              : null,
                    );
                  },
                );
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController.textController,
                    decoration: InputDecoration(
                      hintText: 'Şərh yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                SizedBox(width: 8),
                Obx(
                  () => IconButton(
                    icon:
                        commentController.isLoading.value
                            ? CircularProgressIndicator()
                            : Icon(Icons.send, color: Color(0xFFB8B6F8)),
                    onPressed:
                        commentController.isLoading.value
                            ? null
                            : () => commentController.addComment(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
