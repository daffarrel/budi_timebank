import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/rating.dart';

class ClientRating {
  /// Rate provider after completing a job
  static Future<void> rateProvider(
      {required int rating,
      required String jobId,
      required String providerId,
      String? message}) async {
    Rating rate = Rating(
      rating: rating,
      message: message,
      jobId: jobId,
      rateeId: providerId,
      authorId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('ratings')
        .doc()
        .set(rate.toMap());
  }

  /// Get rating of a job. Return null if no rating
  static Future<Rating?> getRatingByJobId({required String jobId}) async {
    var docsSnapshot = FirebaseFirestore.instance
        .collection('ratings')
        .where('jobId', isEqualTo: jobId);

    var docs = await docsSnapshot.get();
    if (docs.docs.isEmpty) return null;
    return Rating.fromJson(docs.docs.first.data());
  }

  /// Retrieve all given rating
  static Future<List<Rating>> getAllGivenRating() async {
    var docsSnapshot = FirebaseFirestore.instance
        .collection('ratings')
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    var docs = await docsSnapshot.get();
    return docs.docs.map((e) => Rating.fromJson(e.data())).toList();
  }

  /// Retrieve all received rating for the current user
  static Future<List<Rating>> getAllReceivedRating() async {
    var docsSnapshot = FirebaseFirestore.instance
        .collection('ratings')
        .where('rateeId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    var docs = await docsSnapshot.get();
    return docs.docs.map((e) => Rating.fromJson(e.data())).toList();
  }

  /// Retrieve all received rating for user id provided
  static Future<List<Rating>> getAllReceivedRatingForUserId(String uid) async {
    var docsSnapshot = FirebaseFirestore.instance
        .collection('ratings')
        .where('rateeId', isEqualTo: uid);
    var docs = await docsSnapshot.get();
    return docs.docs.map((e) => Rating.fromJson(e.data())).toList();
  }
}
