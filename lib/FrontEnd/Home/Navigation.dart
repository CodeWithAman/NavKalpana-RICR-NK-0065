import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ledger/FrontEnd/Home/AccountPage.dart';
import 'package:ledger/FrontEnd/Home/AnalyticsPage.dart';
import 'package:ledger/FrontEnd/Home/HomePage.dart';
import 'package:ledger/FrontEnd/Home/TransactionsPage.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with WidgetsBindingObserver {
  int selectIndex = 0;

  void changeTab(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).viewPadding.bottom == 0
        ? null
        : SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFFFFFFFF),
            ),
          );
    List<Widget> body = [
      HomePage(),
      TransactionsPage(),
      AnalyticsPage(),
      AccountPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: selectIndex, children: body),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black12, blurRadius: 4.6.r),
          ],
        ),
        child: BottomNavigationBar(
          iconSize: ScreenUtil().setSp(27),
          enableFeedback: false,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 100,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 0.sp,
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 0.sp,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: changeTab,
          currentIndex: selectIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: "Transactions",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: "Analytics",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.black,
      //   shape: CircleBorder(),
      //   onPressed: () {},
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),

      // // FloatingActionButton
      // bottomNavigationBar:

      // BottomAppBar(
      //   shape: CircularNotchedRectangle(),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       IconButton(
      //         onPressed: () {},
      //         icon: Icon(Icons.home, color: Colors.amber),
      //       ),
      //       // IconButton
      //       IconButton(
      //         onPressed: () {},
      //         icon: Icon(Icons.settings, color: Colors.black45),
      //       ),
      //       // IconButton
      //     ],
      //   ),
      // ),
      // BottomAppBar
    );
  }
}
