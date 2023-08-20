/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// Send notification to a user by its uid
exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated",
        "Only authenticated users can call this function.");
  }

  const {receiverUid, title, content} = data;

  // Get the receiver's FCM token from their userUid
  const receiverUserDoc = await admin.firestore().
      collection("fcmUserTokens").
      doc(receiverUid).
      get();
  const receiverFcmToken = receiverUserDoc.data().fcmToken;
  logger.log("receiverFcmToken:", receiverFcmToken);

  if (!receiverFcmToken) {
    throw new functions.https.HttpsError("failed-precondition",
        "Receiver does not have a valid FCM token.");
  }

  // Construct the FCM message payload
  const message = {
    notification: {
      title: title,
      body: content,
    },
    token: receiverFcmToken,
  };
  logger.info("message to be send:", message);

  try {
    // Send the FCM message
    const response = await admin.messaging().send(message);
    logger.info("Notification sent successfully:", response);
    return {success: true};
  } catch (error) {
    logger.error("Error sending notification:", error);
    throw new functions.https.HttpsError("internal",
        "An error occurred while sending the notification.");
  }
});

// For debugging & testing purposes
exports.sendNotificationTest = onRequest( async (request, response) => {
  const receiverFcmToken = request.query.token;
  logger.log("receiverFcmToken", receiverFcmToken);

  if (!receiverFcmToken) {
    throw new functions.https.HttpsError("failed-precondition",
        "Receiver does not have a valid FCM token.");
  }

  // Construct the FCM message payload
  const message = {
    notification: {
      title: "Tes notification function endpoint",
      body: "meow meowmoew",
    },
    token: receiverFcmToken,
  };
  logger.log(message, {structuredData: true});

  try {
    // Send the FCM message
    const res = await admin.messaging().send(message);
    console.log("Notification sent successfully:", res);
    response.send(res);
  } catch (error) {
    console.error("Error sending notification:", error);
    response.send(error);
    throw new functions.https.HttpsError("internal",
        "An error occurred while sending the notification.");
  }
});
