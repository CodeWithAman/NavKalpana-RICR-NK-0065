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
    "AUD": r"A$",
    "CAD": r"CA$",
    "CHF": "CHF",
    "CNY": "元",
    "SGD": r"S$",
    "AED": "AED",
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    void _navigate(Widget page) {
      Navigator.of(context).push(
        PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 200),
          child: page,
        ),
      );
    }

    // ---------------- USER NOT LOGGED IN ----------------
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ---------------- USER LOGGED IN ----------------
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // ---------- ERROR ----------
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // ---------- LOADING ----------
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ---------- DATA ----------
        final data = snapshot.data!.data()!;

        final String name = data['name'] ?? '';
        final String currency = data['currency'] ?? 'INR';
        final String currencySymbol = currencySymbolMap[currency] ?? '₹';

        // ---------- UI ----------
        return Scaffold(
          backgroundColor: const Color(0XFFEDEEF0),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello ${capitalizeFirstLetterOfEachWord(name.split(" ").first)}!",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEE, d MMM').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        "assets/icons/notification.png",
                        height: 28.h,
                        width: 28.w,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // ---------- MONTH SPENDING CARD ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Month Spending",
                              style: TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "$currencySymbol 0.00",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today",
                              style: TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "$currencySymbol 0.00",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.rightToLeftJoined,
                              childCurrent: widget,
                              duration: const Duration(milliseconds: 120),
                              reverseDuration: const Duration(
                                milliseconds: 120,
                              ),
                              child: WalletPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/icons/transaction.png",
                              height: 20.h,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1D1F),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            "10,000",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _navigate(SelectExpenseCategoryPage());
                    },
                    child: Text("+"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
