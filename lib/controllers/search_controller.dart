import 'package:get/get.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'auth_controller.dart';

class SearchController extends GetxController {
  RxList<AppUser> users = <AppUser>[].obs;
  RxString searchText = ''.obs;
  String? get currentUserId => Get.find<AuthController>().user?.uid;

  @override
  void onInit() {
    super.onInit();
    print('SearchController: Fetching all users from UserService.');
    UserService().getAllUsers().listen((data) {
      print('SearchController: Received ${data.length} users.');
      users.value = data;
      print('Fetched Usernames: ${data.map((u) => u.username).join(', ')}');
    });
  }

  List<AppUser> get filteredUsers {
    final query = searchText.value.toLowerCase();
    print('SearchController: Filtering users with query: $query');
    final filteredList = users
        .where((u) =>
            u.id != currentUserId &&
            (u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query) ||
                (u.username != null &&
                    u.username!.toLowerCase().contains(query))))
        .toList();
    print('SearchController: Filtered ${filteredList.length} users.');
    print(
        'Filtered Usernames: ${filteredList.map((u) => u.username).join(', ')}');
    return filteredList;
  }

  Future<void> sendFollowRequest(String targetUserId) async {
    if (currentUserId == null) return;
    await UserService().sendFollowRequest(currentUserId!, targetUserId);
  }

  Future<void> followUser(String targetUserId) async {
    if (currentUserId == null) return;
    await UserService().followUser(currentUserId!, targetUserId);
  }

  Future<void> unfollowUser(String targetUserId) async {
    if (currentUserId == null) return;
    await UserService().unfollowUser(currentUserId!, targetUserId);
  }
}
