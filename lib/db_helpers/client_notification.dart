import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Handle sending push notifications to users
///
/// Limitations: Notifications will not received if app in foreground, to fix that,
/// implement [FirebaseMessaging.onMessage] listener
class ClientNotification {
  static final HttpsCallable sendNotificationCallable =
      FirebaseFunctions.instance.httpsCallable('sendNotification');

  /// Base function to send notification to user
  static Future<void> sendNotification(
      String receiverUid, String title, String content) async {
    try {
      final result = await sendNotificationCallable.call(<String, dynamic>{
        'receiverUid': receiverUid,
        'title': title,
        'content': content,
      });

      debugPrint('Notification sent successfully: ${result.data}');
    } catch (error) {
      debugPrint('Error sending notification: $error');
    }
  }

  /// Notify the requestor that a new applicant has applied for their job
  static Future<void> notifyAddApplicant(
      String receiverUid, String jobTitle) async {
    await sendNotification(receiverUid, 'New Applicant',
        'A new applicant has applied for the job: $jobTitle');
  }

  /// Notify the job applicant that their application has been accepted by requestor
  static Future<void> notifyAcceptProvider(
      String receiverUid, String jobTitle) async {
    await sendNotification(receiverUid, 'Provider Selected',
        'You have been accepted as a provider for the job: $jobTitle');
  }

  /// Notify the job provider that their job is started by the requestor
  static Future<void> notifyStartJob(
      String receiverUid, String jobTitle) async {
    await sendNotification(
        receiverUid, 'Job Started', 'You can now start the job $jobTitle');
  }

  /// Notify the job provider that their job completion has been verified by job creator
  static Future<void> notifyVerifyCompleteJob(
      String receiverUid, String jobTitle) async {
    await sendNotification(receiverUid, 'Completion Verified',
        'Congratulations! The job $jobTitle completion is successfully verified. Please check your rewarded points');
  }

  /// Notify the job provider that their job completion has been verified by the requestor
  static Future<void> claimCompleteJob(
      String receiverUid, String jobTitle) async {
    await sendNotification(receiverUid, 'Job completion need verification',
        'Provider of job $jobTitle has claimed that the job is completed, please verify the completion');
  }

  /// Notify the job provider that their job have been rated by the requestor
  static Future<void> notifyProviderRated(
      String receiverUid, String jobTitle, int starRating) async {
    await sendNotification(receiverUid, 'Job rated',
        'You have received $starRating stars for $jobTitle');
  }
}
