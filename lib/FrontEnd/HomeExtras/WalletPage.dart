import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ledger/FrontEnd/HomeExtras/AddRecurringExpensePage.dart';
import 'package:ledger/FrontEnd/HomeExtras/RecurringExpensesPage.dart';
import 'package:ledger/FrontEnd/HomeExtras/SetBudgetPage.dart';
import 'package:page_transition/page_transition.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Wallet",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Financial Setup"),
            SizedBox(height: 12.h),

            _walletCard(
              icon: Icons.account_balance_wallet,
              title: "Set Monthly Budget",
              subtitle: "Define your spending limit",
              onTap: () {
                _navigate(SetBudgePage());
              },
            ),

            _walletCard(
              icon: Icons.repeat,
              title: "Recurring Expenses",
              subtitle: "Manage monthly & yearly bills",
              onTap: () {
                _navigate(const RecurringExpensesPage());
              },
            ),

            _walletCard(
              icon: Icons.add_circle_outline,
              title: "Add Recurring Expense",
              subtitle: "Rent, EMI, subscriptions",
              onTap: () {
                _navigate(const AddRecurringExpensePage());
              },
            ),

            SizedBox(height: 24.h),
            _sectionTitle("Coming Soon"),
            SizedBox(height: 12.h),

            _disabledCard(
              icon: Icons.savings,
              title: "Savings Goals",
              subtitle: "Track long-term goals",
            ),

            _disabledCard(
              icon: Icons.trending_up,
              title: "Income Settings",
              subtitle: "Manage income sources",
            ),
          ],
        ),
      ),
    );
  }

  // ================= NAVIGATION =================

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

  // ================= UI COMPONENTS =================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _walletCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _disabledCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(icon, color: Colors.black54),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black38),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock, color: Colors.black38),
        ],
      ),
    );
  }
}
