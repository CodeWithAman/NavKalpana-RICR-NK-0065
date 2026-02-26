// CategoryModel

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  factory CategoryModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: d['name'] ?? 'Other',
      icon: Icons.apps,
      isDefault: false,
    );
  }

  // Default built-in categories
  static List<CategoryModel> get defaults => const [
        CategoryModel(id: 'groceries',    name: 'Groceries',    icon: Icons.shopping_cart,    isDefault: true),
        CategoryModel(id: 'food',         name: 'Food',         icon: Icons.restaurant,       isDefault: true),
        CategoryModel(id: 'travel',       name: 'Travel',       icon: Icons.flight,           isDefault: true),
        CategoryModel(id: 'transport',    name: 'Transport',    icon: Icons.directions_car,   isDefault: true),
        CategoryModel(id: 'home',         name: 'Home',         icon: Icons.home,             isDefault: true),
        CategoryModel(id: 'insurance',    name: 'Insurance',    icon: Icons.security,         isDefault: true),
        CategoryModel(id: 'education',    name: 'Education',    icon: Icons.school,           isDefault: true),
        CategoryModel(id: 'shopping',     name: 'Shopping',     icon: Icons.shopping_bag,     isDefault: true),
        CategoryModel(id: 'internet',     name: 'Internet',     icon: Icons.wifi,             isDefault: true),
        CategoryModel(id: 'rent',         name: 'Rent',         icon: Icons.receipt_long,     isDefault: true),
        CategoryModel(id: 'gym',          name: 'Gym',          icon: Icons.fitness_center,   isDefault: true),
        CategoryModel(id: 'subscription', name: 'Subscription', icon: Icons.subscriptions,    isDefault: true),
        CategoryModel(id: 'health',       name: 'Health',       icon: Icons.local_hospital,   isDefault: true),
        CategoryModel(id: 'entertainment',name: 'Entertainment',icon: Icons.movie,            isDefault: true),
        CategoryModel(id: 'other',        name: 'Other',        icon: Icons.apps,             isDefault: true),
      ];
}
