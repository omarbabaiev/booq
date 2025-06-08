import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/search_controller.dart' as my_search;
import '../../models/user.dart';

class SearchScreen extends StatelessWidget {
  final my_search.SearchController searchController =
      Get.put(my_search.SearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kəşf et'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => searchController.searchText.value = v,
              decoration: InputDecoration(
                hintText: 'İstifadəçi axtar...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Color(0xFFF3F3FB),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final users = searchController.filteredUsers;
              if (users.isEmpty) {
                return Center(child: Text('İstifadəçi tapılmadı.'));
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserTile(user: user, controller: searchController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final my_search.SearchController controller;
  const _UserTile({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentUserId = controller.currentUserId;
    final isFollowing = user.followers.contains(currentUserId);
    final isRequested = user.followRequests.contains(currentUserId);
    return ListTile(
      leading: user.photoUrl.isNotEmpty
          ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl))
          : CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.name.isNotEmpty ? user.name : 'Anonim'),
      subtitle: Text(user.username ?? ''),
      trailing: _buildActionButton(isFollowing, isRequested, user, controller),
    );
  }

  Widget _buildActionButton(bool isFollowing, bool isRequested, AppUser user,
      my_search.SearchController controller) {
    if (isFollowing) {
      return ElevatedButton(
        onPressed: () => controller.unfollowUser(user.id),
        child: Text('Unfollow'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      );
    } else if (isRequested) {
      return OutlinedButton(
        onPressed: null,
        child: Text('İstək göndərildi'),
      );
    } else {
      return ElevatedButton(
        onPressed: () => controller.sendFollowRequest(user.id),
        child: Text('Follow'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFB8B6F8),
          foregroundColor: Colors.white,
        ),
      );
    }
  }
}
