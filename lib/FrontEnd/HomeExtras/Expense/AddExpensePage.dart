import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  final String categoryName;

  const AddExpensePage({super.key, required this.categoryName});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get monthId => DateFormat('yyyy-MM').format(selectedDate);
  String get dayId => DateFormat('yyyy-MM-dd').format(selectedDate);

  // ================= SAVE EXPENSE =================

  Future<void> saveExpense() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => isSaving = true);

    final batch = _firestore.batch();

    // 1️⃣ Expense reference
    final expenseRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc();

    // 2️⃣ Monthly analytics reference
    final monthRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('analytics')
        .doc(monthId);

    // 3️⃣ Daily analytics reference
    final dayRef = monthRef.collection('daily').doc(dayId);

    // -------- ADD EXPENSE --------
    batch.set(expenseRef, {
      "amount": amount,
      "categoryName": widget.categoryName,
      "note": _noteController.text.trim(),
      "date": Timestamp.fromDate(selectedDate),
      "createdAt": FieldValue.serverTimestamp(),
    });

    // -------- UPDATE MONTHLY SPENT --------
    batch.set(monthRef, {
      "month": monthId,
      "totalSpent": FieldValue.increment(amount),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // -------- UPDATE DAILY SPENT --------
    batch.set(dayRef, {
      "date": dayId,
      "spent": FieldValue.increment(amount),
    }, SetOptions(merge: true));

    await batch.commit();

    setState(() => isSaving = false);
    Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _categoryCard(),
            const SizedBox(height: 24),
            _amountInput(),
            const SizedBox(height: 16),
            _noteInput(),
            const SizedBox(height: 16),
            _datePicker(),
            const Spacer(),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _categoryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.category, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            widget.categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _amountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        prefixText: "₹ ",
        hintText: "0",
        border: UnderlineInputBorder(),
      ),
    );
  }

  Widget _noteInput() {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(
        hintText: "Add note (optional)",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _datePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Colors.black),
      title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: isSaving ? null : saveExpense,
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Expense", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
