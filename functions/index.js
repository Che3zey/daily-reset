const { setGlobalOptions } = require("firebase-functions");
const { onSchedule } = require("firebase-functions/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

/**
 * 🔔 DAILY 12PM PUSH NOTIFICATION
 */
exports.dailyChallengeReminder = onSchedule(
  {
    schedule: "0 12 * * *", // 12:00 PM every day
    timeZone: "America/New_York", // change if needed
  },
  async () => {
    console.log("Running daily reminder job...");

    const db = admin.firestore();

    // 🔍 Get all users
    const usersSnapshot = await db.collection("users").get();

    const tokens = [];

    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found.");
      return null;
    }

    // 📩 Notification payload
    const message = {
      notification: {
        title: "Daily Challenges 🔥",
        body: "Don’t forget to complete your challenges today!",
      },
      tokens: tokens,
    };

    // 🚀 Send notifications
    const response = await admin.messaging().sendEachForMulticast(message);

    console.log("Sent messages:", response.successCount);
    console.log("Failed messages:", response.failureCount);

    return null;
  }
);