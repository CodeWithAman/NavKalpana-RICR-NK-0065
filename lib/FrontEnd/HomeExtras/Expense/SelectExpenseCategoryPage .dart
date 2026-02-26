import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ledger/FrontEnd/HomeExtras/Expense/AddCategoryPage.dart';
import 'package:ledger/FrontEnd/HomeExtras/Expense/AddExpensePage.dart';

class SelectExpenseCategoryPage extends StatelessWidget {
  const SelectExpenseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // -------- DEFAULT CATEGORIES --------
    final defaultCategories = [
      _Category("Groceries", Icons.shopping_cart),
      _Category("Travel", Icons.flight),
      _Category("Car", Icons.directions_car),
      _Category("Home", Icons.home),
      _Category("Insurance", Icons.security),
      _Category("Education", Icons.school),
      _Category("Marketing", Icons.campaign),
      _Category("Shopping", Icons.shopping_bag),
      _Category("Internet", Icons.wifi),
      _Category("Water", Icons.water_drop),
      _Category("Rent", Icons.receipt_long),
      _Category("Gym", Icons.fitness_center),
      _Category("Subscription", Icons.subscriptions),
      _Category("Vacation", Icons.beach_access),
      _Category("Other", Icons.apps),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Select Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _searchBar(),
            SizedBox(height: 20.h),

            // ================= CATEGORIES GRID =================
            Expanded(
              child: user == null
                  ? const Center(child: Text("User not logged in"))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('categories')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final customCategories = snapshot.hasData
                            ? snapshot.data!.docs
                                  .map(
                                    (doc) => _Category(doc['name'], Icons.apps),
                                  )
                                  .toList()
                            : <_Category>[];

                        final allCategories = [
                          _Category("Add", Icons.add, isAdd: true),
                          ...defaultCategories,
                          ...customCategories,
                        ];

                        return GridView.builder(
                          itemCount: allCategories.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 0.85,
                              ),
                          itemBuilder: (context, index) {
                            final category = allCategories[index];
                            return _categoryTile(context, category);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH BAR =================

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search for Categories",
          hintStyle: TextStyle(color: Colors.grey),
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  // ================= CATEGORY TILE =================

  Widget _categoryTile(BuildContext context, _Category category) {
    final isAdd = category.isAdd;

    return GestureDetector(
      onTap: () async {
        if (isAdd) {
          // ➕ ADD CATEGORY
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          );

          if (added == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Category added")));
          }
        } else {
          // ➡️ GO TO ADD EXPENSE PAGE
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpensePage(categoryName: category.name),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            height: 56.h,
            width: 56.h,
            decoration: BoxDecoration(
              color: isAdd ? Colors.black : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              category.icon,
              color: isAdd ? Colors.white : Colors.black,
              size: 26.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CATEGORY MODEL =================

class _Category {
  final String name;
  final IconData icon;
  final bool isAdd;

  _Category(this.name, this.icon, {this.isAdd = false});
}
