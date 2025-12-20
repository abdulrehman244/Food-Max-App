const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Auto-send notification when a new notification document is created
exports.sendUserNotification = functions.firestore
    .document("notifications/{notifId}")
    .onCreate(async (snap, context) => {

  const data = snap.data();
  const userId = data.userId; // user ID from notification document
  const title = data.title;
  const body = data.body;

  // Get user FCM token
  const userDoc = await admin.firestore().collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (!fcmToken) {
    console.log("❌ No FCM token for user:", userId);
    return;
  }

  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: fcmToken,
  };

  await admin.messaging().send(message);
  console.log("✅ Notification sent to user:", userId);
});
