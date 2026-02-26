import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ledger/FrontEnd/Extras/CommonFunctions.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isFetching = false;

  String profilePicture = '';
  String name = '';
  String email = '';

  Future<void> loadUserData() async {
    setState(() {
      isFetching = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          // U S E R   D A T A
          profilePicture = snapshot.data()?['profilePicture'] ?? '';
          name = snapshot.data()?['name'] ?? '';
          email = snapshot.data()?['email'] ?? '';

          // E X T R A S
          isFetching = false;
        });
      } else {
        if (mounted) userNotFound(context);
      }
    } catch (e) {
      if (mounted) userNotFound(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFEDEEF0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 72.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  height: 49.h,
                  width: 49.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/profilePicture.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  email,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black45),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99.r),
                    color: Color(0xFFEDEEF0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 7.h,
                    ),
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                image: DecorationImage(
                  image: AssetImage("assets/images/premiumFrame.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                leading: Container(
                  height: 49.h,
                  width: 49.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 1.5.w),
                    shape: BoxShape.circle,
                    color: Colors.white12,
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/icons/crown.png",
                      height: 28.h,
                      width: 28.w,
                      color: Colors.white,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  "Premium Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17.sp,
                  ),
                ),
                subtitle: Text(
                  "Enjoy your premium feaatures",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),
            Text(
              "Account Settings",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    leading: Image.asset(
                      "assets/icons/key.png",
                      height: 16.h,
                      width: 16.w,
                    ),
                    title: Text(
                      "Account Information",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14.sp),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(
                      right: 16.w,
                      left: 16.w,
                      bottom: -6.h,
                    ),
                    leading: Image.asset(
                      "assets/icons/key.png",
                      height: 16.h,
                      width: 16.w,
                    ),
                    title: Text(
                      "Account Information",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
