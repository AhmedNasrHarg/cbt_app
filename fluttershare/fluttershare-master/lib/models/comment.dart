import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {

  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final int timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp
  });

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      username: doc["username"],
      userId: doc["userId"],
      avatarUrl: doc["avatarUrl"],
      comment: doc["comment"],
      timestamp: doc["timestamp"]
    );
  }
}