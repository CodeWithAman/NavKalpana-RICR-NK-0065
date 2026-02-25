import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:ledger/FrontEnd/Home/AccountPage.dart';
import 'package:ledger/FrontEnd/Home/AnalyticsPage.dart';
import 'package:ledger/FrontEnd/Home/HomePage.dart';
import 'package:ledger/FrontEnd/Home/TransactionsPage.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectIndex = 0;

  static const Color bg = Color(0xFF141415);
  static const Color nav = Color(0xFF1C1D1F);
  static const Color active = Color(0xFFEDEEF0);
  static const Color inactive = Color(0xFFB1B5B7);
  static const Color pill = Color(0xFF27292A);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      TransactionsPage(),
      AnalyticsPage(),
      AccountPage(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(index: selectIndex, children: pages),

      bottomNavigationBar: Container(
        color: nav,
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        child: GNav(
          selectedIndex: selectIndex,
          onTabChange: (i) => setState(() => selectIndex = i),

          gap: 8,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

          backgroundColor: nav,
          tabBackgroundColor: pill,

          color: inactive,
          activeColor: active,

          iconSize: 24.sp,
          rippleColor: Colors.transparent,
          hoverColor: Colors.transparent,
          haptic: false,

          tabs: [
            GButton(
              icon: Icons.home_rounded,
              leading: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  selectIndex == 0 ? active : inactive,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  "assets/icons/home.png",
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
              text: 'Home',
            ),
            GButton(
              icon: Icons.home_rounded,
              leading: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  selectIndex == 1 ? active : inactive,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  "assets/icons/transaction.png",
                  width: 24.sp,
                  height: 24.sp,
                ),
              ),
              text: 'Transactions',
            ),
            GButton(
              icon: Icons.home_rounded,
              leading: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  selectIndex == 2 ? active : inactive,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  "assets/icons/analytics.png",
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
              text: 'Analytics',
            ),
            GButton(
              icon: Icons.home_rounded,
              leading: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  selectIndex == 2 ? active : inactive,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  "assets/icons/person.png",
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
              text: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
