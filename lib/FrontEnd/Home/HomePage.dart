import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ledger/FrontEnd/Extras/CommonFunctions.dart';
import 'package:ledger/FrontEnd/HomeExtras/Expense/SelectExpenseCategoryPage%20.dart';
import 'package:ledger/FrontEnd/HomeExtras/WalletPage.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> currencySymbolMap = {
    "USD": r"$",
    "EUR": "€",
    "INR": "₹",
    "GBP": "£",
    "JPY": "¥",
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = DateTime.now();
    final monthId = DateFormat('yyyy-MM').format(now);
    final todayId = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayId = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));

    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnap.data!.data() as Map<String, dynamic>;
        final name = userData['name'] ?? '';
        final currency = userData['currency'] ?? 'INR';
        final budget = (userData['monthlyBudget'] ?? 0).toDouble();
        final symbol = currencySymbolMap[currency] ?? '₹';

        return Scaffold(
          backgroundColor: const Color(0xFFEDEEF0),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),

                      // ================= HEADER =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello ${capitalizeFirstLetterOfEachWord(name.split(" ").first)}!",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                DateFormat('EEE, d MMM').format(now),
                                style: const TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          Image.asset(
                            "assets/icons/notification.png",
                            height: 24.h,
                            width: 24.w,
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ================= MONTH + TODAY =================
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title: "This Month",
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('analytics')
                                  .doc(monthId)
                                  .snapshots(),
                              field: "totalSpent",
                              symbol: symbol,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _todayComparisonCard(
                              uid: user.uid,
                              monthId: monthId,
                              todayId: todayId,
                              yesterdayId: yesterdayId,
                              symbol: symbol,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // ================= SPENDING WALLET =================
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('analytics')
                            .doc(monthId)
                            .snapshots(),
                        builder: (context, snap) {
                          final spent = (snap.hasData && snap.data!.exists)
                              ? ((snap.data!.data()
                                            as Map<
                                              String,
                                              dynamic
                                            >)['totalSpent'] ??
                                        0)
                                    .toDouble()
                              : 0.0;

                          final left = (budget - spent).clamp(0, budget);

                          return Container(
                            padding: EdgeInsets.all(14.h),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/premiumFrame.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.wallet,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    "Spending Wallet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "$symbol${left.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      // ================= ACTIONS =================
                      Row(
                        children: [
                          _actionBtn(
                            icon: Icons.add,
                            label: "Add",
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const SelectExpenseCategoryPage(),
                                ),
                              );
                            },
                          ),
                          _actionBtn(
                            icon: Icons.account_balance_wallet,
                            label: "Wallet",
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const WalletPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),

                // ================= RECENT TRANSACTIONS =================
                recentTransactions(
                  uid: user.uid,
                  currencySymbol: symbol,
                  dayStart: dayStart,
                  dayEnd: dayEnd,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STAT CARD =================

  Widget _statCard({
    required String title,
    required Stream<DocumentSnapshot> stream,
    required String field,
    required String symbol,
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snap) {
        final value = (snap.hasData && snap.data!.exists)
            ? ((snap.data!.data() as Map<String, dynamic>)[field] ?? 0)
                  .toDouble()
            : 0.0;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "$symbol${value.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TODAY COMPARISON (PERCENTAGE) =================

  Widget _todayComparisonCard({
    required String uid,
    required String monthId,
    required String todayId,
    required String yesterdayId,
    required String symbol,
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analytics')
          .doc(monthId)
          .collection('daily')
          .doc(todayId)
          .snapshots(),
      builder: (context, todaySnap) {
        final todaySpent = (todaySnap.hasData && todaySnap.data!.exists)
            ? ((todaySnap.data!.data() as Map<String, dynamic>)['spent'] ?? 0)
                  .toDouble()
            : 0.0;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('analytics')
              .doc(monthId)
              .collection('daily')
              .doc(yesterdayId)
              .snapshots(),
          builder: (context, ySnap) {
            final yesterdaySpent = (ySnap.hasData && ySnap.data!.exists)
                ? ((ySnap.data!.data() as Map<String, dynamic>)['spent'] ?? 0)
                      .toDouble()
                : 0.0;

            final hasComparison = yesterdaySpent > 0;
            final percentChange = hasComparison
                ? ((todaySpent - yesterdaySpent) / yesterdaySpent) * 100
                : 0.0;

            final isMore = percentChange > 0;

            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today",
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      hasComparison
                          ? Container(
                              decoration: BoxDecoration(
                                color: isMore
                                    ? Colors.orangeAccent.withOpacity(0.2)
                                    : Colors.greenAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.h,
                                  horizontal: 4.w,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isMore
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 16,
                                      color: isMore
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                      weight: 100,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${percentChange.abs().toStringAsFixed(1)}% ",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isMore
                                            ? Colors.orangeAccent
                                            : Colors.greenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "$symbol${todaySpent.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= ACTION BUTTON =================

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 12.w),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [Icon(icon), const SizedBox(height: 6), Text(label)],
          ),
        ),
      ),
    );
  }
}

// ================= RECENT TRANSACTIONS =================

Widget recentTransactions({
  required String uid,
  required String currencySymbol,
  required DateTime dayStart,
  required DateTime dayEnd,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('expenses')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
              )
              .where('date', isLessThan: Timestamp.fromDate(dayEnd))
              .orderBy('date', descending: true)
              .limit(6)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                "No transactions today",
                style: TextStyle(color: Colors.black45),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(d['categoryName'] ?? 'Expense'),
                  subtitle: (d['note'] ?? "").toString().isNotEmpty
                      ? Text(d['note'])
                      : null,
                  trailing: Text(
                    "-$currencySymbol${d['amount']}",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}
