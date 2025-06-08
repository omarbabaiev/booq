import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/liked_users_controller.dart'; // Will create this controller

class LikedUsersSheet extends StatelessWidget {
  final List<String> userIds; // List of UIDs of users who liked the post

  const LikedUsersSheet({Key? key, required this.userIds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller will be injected when the sheet is shown
    final LikedUsersController controller = Get.find<LikedUsersController>();

    // Pass userIds to the controller after it's created/found
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLikedUsers(userIds); // Fetch data after widget is built
    });

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Text('Bəyənənlər',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.likedUsers.isEmpty) {
                  return Center(
                      child: Text(
                          'Hələ bəyənmə yoxdur.')); // Should not happen if list is empty
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.likedUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.likedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child:
                            user.photoUrl.isEmpty ? Icon(Icons.person) : null,
                      ),
                      title: Text(user.name.isNotEmpty ? user.name : 'Anonim'),
                      subtitle: Text(
                          user.username != null && user.username!.isNotEmpty
                              ? '@${user.username!}'
                              : ''), // Show username with @
                      // You can add onTap here to navigate to user profile
                      onTap: () {
                        // TODO: Navigate to user profile screen
                        print('Navigate to user profile: ${user.id}');
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
