import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/earnings_history.dart';
import '../model/profile.dart';

class ClientUser {
  /// Return profile data with userUid
  static Future<Profile> getUserProfileById(String id) async {
    var res =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    var userProfile = res['profile'];
    var profile = Profile.fromJson(userProfile);
    profile.userUid = id;
    return profile;
  }

  /// Add points to current user
  static Future<void> addPoints(
      {required double points,
      String reason = "rewards",
      String? senderId}) async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;
    var data = EarningsHistory(
        date: DateTime.now(),
        amount: points.toDouble(),
        reason: reason,
        from: senderId == null ? "system" : "id:$senderId",
        to: 'id:$userUid');
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .update({
      'earningsHistory': FieldValue.arrayUnion([data.toFirestoreMap()])
    });
  }

  /// Get earnings history
  static Future<List<EarningsHistory>> getUserEarningsHistory() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;
    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    if (!snapshot.exists) throw Exception("User $userUid not exist");
    var data = snapshot.data()!;
    var earningsData = data['earningsHistory'] as List<dynamic>;
    var earnings =
        earningsData.map((e) => EarningsHistory.fromJson(e)).toList();

    return earnings;
  }

  /// Get total points
  static Future<double> getTotalPoints() async {
    var earnings = await getUserEarningsHistory();
    // sum all the `amount` in the earnings
    double total = 0;
    for (var element in earnings) {
      total += element.amount;
    }
    return total;
  }

  /// Transfer time points to another user
  static Future<void> transferPoints(
      String receiverId, double amount, String jobId) async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;
    // add points to receiver
    var data = EarningsHistory(
        date: DateTime.now(),
        amount: amount,
        reason: 'job:$jobId',
        from: 'id:$userUid',
        to: 'id:$receiverId');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .update({
      'earningsHistory': FieldValue.arrayUnion([data.toFirestoreMap()])
    });

    // deduct points from current user
    // same thing as the data above, but with negative amount
    var data1 = EarningsHistory(
        date: DateTime.now(),
        amount: -amount,
        reason: 'job:$jobId',
        from: "id:$userUid",
        to: 'id:$receiverId');
    await FirebaseFirestore.instance.collection('users').doc(userUid).update({
      'earningsHistory': FieldValue.arrayUnion([data1.toFirestoreMap()])
    });
  }

  static Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final imgReferences =
          FirebaseStorage.instance.ref('avatars/$userUid.png');
      await imgReferences.putFile(imageFile);
      final urlImage = await imgReferences.getDownloadURL();

      return urlImage;
    } on FirebaseException catch (error) {
      throw Exception(error.message.toString());
    }
  }

  /// Uplaod and set profile picture
  static Future<void> setProfilePicture(String imageUrl) async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    try {
      // save to firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .update({'profile.avatar': imageUrl});
    } on FirebaseException catch (error) {
      throw Exception(error.message.toString());
    } catch (error) {
      throw Exception('Unexpected error occured');
    }
  }

  static Future<void> saveFcmToken(String token) {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('fcmUserTokens')
        .doc(userUid)
        .set({'fcmToken': token});
  }
}
