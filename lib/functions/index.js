const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

exports.verifyPin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User not authenticated",
    );
  }

  const uid = context.auth.uid;
  const enteredPin = data.pin;

  if (!enteredPin || enteredPin.length !== 4) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid PIN");
  }

  const enteredHash = crypto
    .createHash("sha256")
    .update(enteredPin)
    .digest("hex");

  const userDoc = await admin.firestore().collection("users").doc(uid).get();

  if (!userDoc.exists) {
    throw new functions.https.HttpsError("not-found", "User not found");
  }

  return {
    success: enteredHash === userDoc.data().pin,
  };
});
