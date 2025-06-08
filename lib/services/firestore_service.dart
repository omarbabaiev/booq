import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBookPost(Map<String, dynamic> data) async {
    await _db.collection('book_posts').add(data);
  }

  Stream<QuerySnapshot> getBookPosts() {
    return _db.collection('book_posts').snapshots();
  }

  Future<void> addExchange(Map<String, dynamic> data) async {
    await _db.collection('exchanges').add(data);
  }
}
