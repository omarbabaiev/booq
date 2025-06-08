import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/post_controller.dart';
import 'dart:io';

class PostScreen extends StatelessWidget {
  final PostController postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Yeni Paylaşım'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB8B6F8),
              Color(0xFFF3F3FB),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 340,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Fikrinizi paylaşın',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A3A5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: postController.textController,
                    decoration: InputDecoration(
                      hintText: 'Nə düşünürsən?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF3F3FB),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: postController.pickImages,
                    icon: Icon(Icons.image),
                    label: Text('Şəkil seç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF3F3FB),
                      foregroundColor: Color(0xFF3A3A5A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() {
                    if (postController.selectedImages.isEmpty) {
                      return SizedBox.shrink();
                    } else {
                      return Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: postController.selectedImages.length,
                          itemBuilder: (context, index) {
                            final imageFile =
                                postController.selectedImages[index];
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      imageFile,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => postController.selectedImages
                                        .removeAt(index),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.redAccent,
                                      child: Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  }),
                  SizedBox(height: 24),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: postController.isLoading.value
                              ? null
                              : () => postController.addPost(),
                          child: postController.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Paylaş'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB8B6F8),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
