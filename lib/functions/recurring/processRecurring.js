const functions = require("firebase-functions");
const admin = require("firebase-admin");

const db = admin.firestore();

exports.processRecurringExpenses = functions.pubsub
  .schedule("every day 01:00")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const usersSnapshot = await db.collection("users").get();
    const now = new Date();

    const currentMonth = `${now.getFullYear()}-${String(
      now.getMonth() + 1,
    ).padStart(2, "0")}`;

    const currentYear = `${now.getFullYear()}`;

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const recurringSnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("recurring_expenses")
        .where("isActive", "==", true)
        .get();

      for (const recurringDoc of recurringSnapshot.docs) {
        const data = recurringDoc.data();
        const lastProcessed = data.lastProcessed || null;

        let shouldProcess = false;
        let newLastProcessed = null;

        // -------- MONTHLY LOGIC --------
        if (data.cycle === "monthly" && lastProcessed !== currentMonth) {
          shouldProcess = true;
          newLastProcessed = currentMonth;
        }

        // -------- YEARLY LOGIC --------
        if (data.cycle === "yearly" && lastProcessed !== currentYear) {
          shouldProcess = true;
          newLastProcessed = currentYear;
        }

        if (!shouldProcess) continue;

        // -------- ADD EXPENSE --------
        await db
          .collection("users")
          .doc(userId)
          .collection("expenses")
          .add({
            amount: data.amount,
            categoryName: "Recurring",
            description: `${data.title} (Auto)`,
            date: admin.firestore.Timestamp.fromDate(
              new Date(now.getFullYear(), now.getMonth(), 1),
            ),
            isRecurring: true,
            recurringId: recurringDoc.id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // -------- UPDATE LAST PROCESSED --------
        await recurringDoc.ref.update({
          lastProcessed: newLastProcessed,
        });
      }
    }

    return null;
  });
