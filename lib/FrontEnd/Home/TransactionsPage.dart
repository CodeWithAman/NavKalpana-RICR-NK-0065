import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedMonth = DateTime.now();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get dayStart => DateFormat('yyyy-MM-dd').format(selectedDate);

  DateTime get dayStartTime =>
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  DateTime get dayEndTime => dayStartTime.add(const Duration(days: 1));

  // ================= PICKERS =================

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => selectedMonth = picked);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: user == null
          ? const Center(child: Text("User not logged in"))
          : Column(
              children: [
                _filters(),
                _summaryCards(user.uid),
                const Divider(height: 1),
                Expanded(child: _transactionsList(user.uid)),
              ],
            ),
    );
  }

  // ================= FILTER BAR =================

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _filterChip(
            label: DateFormat('dd MMM').format(selectedDate),
            icon: Icons.calendar_today,
            onTap: pickDate,
          ),
          const SizedBox(width: 12),
          _filterChip(
            label: DateFormat('MMMM yyyy').format(selectedMonth),
            icon: Icons.date_range,
            onTap: pickMonth,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCards(String uid) {
    final monthId = DateFormat('yyyy-MM').format(selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: "Today",
              stream: _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('analytics')
                  .doc(DateFormat('yyyy-MM').format(selectedDate))
                  .collection('daily')
                  .doc(DateFormat('yyyy-MM-dd').format(selectedDate))
                  .snapshots(),
              field: "spent",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              title: "This Month",
              stream: _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('analytics')
                  .doc(monthId)
                  .snapshots(),
              field: "totalSpent",
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required Stream<DocumentSnapshot> stream,
    required String field,
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final amount = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data![field] ?? 0
            : 0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                "₹$amount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TRANSACTION LIST =================

  Widget _transactionsList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStartTime),
          )
          .where('date', isLessThan: Timestamp.fromDate(dayEndTime))
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No transactions for selected date",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _transactionTile(data);
          },
        );
      },
    );
  }

  Widget _transactionTile(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.receipt, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['categoryName'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  data['note'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "₹${data['amount']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
