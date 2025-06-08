import 'package:booq_last_attempt/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../post/post_screen.dart';
import '../profile/profile_screen.dart';
import 'search_screen.dart';
import '../../controllers/feed_controller.dart';
import 'feed_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final BottomNavController navController = Get.put(BottomNavController());
  final FeedController feedController = Get.put(FeedController());

  // Define pages for each tab (Home, Search, Notifications, Profile)
  final List<Widget> pages = [
    FeedView(),
    SearchScreen(),
    // Note: PostScreen will be opened via FloatingActionButton, not a bottom nav tab
    NotificationsScreen(),
    ProfileScreen(),
  ];

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body:
            pages[navController.tabIndex.value], // Use the selected page index
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the PostScreen when the FAB is pressed
            Get.to(() => PostScreen()); // Use Get.to to push the new screen
          },
          child: Icon(Icons.add, size: 30), // Plus icon
          backgroundColor: Colors.amber, // Example background color
          shape: CircleBorder(), // Make it round
          elevation: 0, // No shadow
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // Center the FAB
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(), // Cutout for the FAB
          notchMargin: 8.0, // Space between FAB and BottomAppBar
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Distribute icons evenly
            children: <Widget>[
              // Home Icon
              IconButton(
                icon: Icon(
                  navController.tabIndex.value == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  color:
                      navController.tabIndex.value == 0
                          ? Colors.black
                          : Colors.grey, // Change color based on selection
                  size: 28,
                ),
                onPressed: () => navController.changeTab(0), // Index 0 for Home
              ),
              // Search Icon
              IconButton(
                icon: Icon(
                  navController.tabIndex.value == 1
                      ? Icons.search
                      : Icons.search_outlined,
                  color:
                      navController.tabIndex.value == 1
                          ? Colors.black
                          : Colors.grey,
                  size: 28,
                ),
                onPressed:
                    () => navController.changeTab(1), // Index 1 for Search
              ),
              // Placeholder for the FAB
              SizedBox(width: 48), // The size of the FAB cutout + some margin
              // Notifications Icon
              IconButton(
                icon: Icon(
                  navController.tabIndex.value == 2
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  color:
                      navController.tabIndex.value == 2
                          ? Colors.black
                          : Colors.grey,
                  size: 28,
                ),
                onPressed:
                    () =>
                        navController.changeTab(2), // Index 2 for Notifications
              ),
              // Profile Icon
              IconButton(
                icon: Icon(
                  navController.tabIndex.value == 3
                      ? Icons.person
                      : Icons.person_outline,
                  color:
                      navController.tabIndex.value == 3
                          ? Colors.black
                          : Colors.grey,
                  size: 28,
                ),
                onPressed:
                    () => navController.changeTab(3), // Index 3 for Profile
              ),
            ],
          ),
        ),
      ),
    );
  }
}
