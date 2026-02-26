const admin = require("firebase-admin");

// Initialize Firebase Admin SDK ONCE
admin.initializeApp();

// ================= RECURRING EXPENSES =================
exports.processRecurringExpenses =
  require("./recurring/processRecurring").processRecurringExpenses;

// ================= BUDGET ALERTS (later) =================
// exports.checkBudgetAlerts =
//   require("./alerts/budgetAlerts").checkBudgetAlerts;

// ================= FUTURE FUNCTIONS =================
// exports.someOtherFunction =
//   require("./path/to/file").functionName;
