import 'package:flutter/material.dart';

class PostForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(decoration: InputDecoration(labelText: 'Kitab adı')),
        TextField(decoration: InputDecoration(labelText: 'Müəllif')),
        TextField(decoration: InputDecoration(labelText: 'Təsvir')),
        // Şəkil seçimi və dəyişmə/pulsuz seçimi əlavə ediləcək
        ElevatedButton(onPressed: () {}, child: Text('Paylaş')),
      ],
    );
  }
}
