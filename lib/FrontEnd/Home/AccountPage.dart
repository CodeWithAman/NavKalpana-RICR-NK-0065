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
  bool isFetching = true;

  String name = '';
  String email = '';
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!snap.exists) {
        if (mounted) userNotFound(context);
        return;
      }

      final data = snap.data() as Map<String, dynamic>;

      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        profilePicture = data['profilePicture'] ?? '';
        isFetching = false;
      });
    } catch (_) {
      if (mounted) userNotFound(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF0),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 70.h),

                    /// ================= PROFILE CARD =================
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26.r,
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : const AssetImage(
                                        "assets/images/profilePicture.jpg",
                                      )
                                      as ImageProvider,
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capitalizeFirstLetterOfEachWord(name),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEEF0),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    /// ================= PREMIUM CARD =================
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/premiumFrame.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        leading: Container(
                          height: 46.h,
                          width: 46.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white54,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/icons/crown.png",
                              height: 24.h,
                              width: 24.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          "Premium Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          "Enjoy your premium features",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    /// ================= SETTINGS =================
                    Text(
                      "Account Settings",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        children: [
                          _settingsTile(
                            icon: Icons.person_outline,
                            label: "Account Information",
                          ),
                          _divider(),
                          _settingsTile(
                            icon: Icons.lock_outline,
                            label: "Privacy & Security",
                          ),
                          _divider(),
                          _settingsTile(
                            icon: Icons.notifications_none,
                            label: "Notifications",
                          ),
                          _divider(),
                          _settingsTile(
                            icon: Icons.help_outline,
                            label: "Help & Support",
                          ),
                          _divider(),
                          _settingsTile(
                            icon: Icons.logout,
                            label: "Logout",
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  /// ================= SETTINGS TILE =================
  Widget _settingsTile({
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: Icon(
        icon,
        size: 20,
        color: isDestructive ? Colors.redAccent : Colors.black,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.redAccent : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: Colors.grey.shade300),
    );
  }
}
