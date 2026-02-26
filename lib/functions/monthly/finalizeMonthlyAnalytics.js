const functions = require("firebase-functions");
const admin = require("firebase-admin");

const db = admin.firestore();

exports.finalizeMonthlyAnalytics = functions.pubsub
  .schedule("1 of month 00:10")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const now = new Date();

    // Get previous month
    const prev = new Date(now.getFullYear(), now.getMonth() - 1);
    const monthId = `${prev.getFullYear()}-${String(
      prev.getMonth() + 1,
    ).padStart(2, "0")}`;

    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const analyticsRef = db
        .collection("users")
        .doc(userId)
        .collection("analytics")
        .doc(monthId);

      const analyticsSnap = await analyticsRef.get();
      if (!analyticsSnap.exists) continue;

      await analyticsRef.set(
        {
          finalized: true,
          finalizedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    return null;
  });
