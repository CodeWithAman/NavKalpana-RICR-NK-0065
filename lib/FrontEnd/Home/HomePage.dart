import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for the notched nav bar effect
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Base color
          gradient: RadialGradient(
            center: Alignment(0, -1.2), // Starts slightly above the screen
            radius: 1.5,
            colors: [
              Color(0xFFD6C6FF), // The soft purple
              Colors.white, // Fades to white
            ],
            stops: [0.0, 0.7], // Controls how quickly it fades
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTopBar(),
                const SizedBox(height: 40),
                _buildHeroSection(),
                const SizedBox(height: 40),
                _buildWalletTile(),
                const SizedBox(height: 30),
                _buildTransactionHeader(),
                Expanded(child: _buildTransactionList()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF13111A),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleIcon(Icons.settings_outlined),
        const Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Colors.black54,
            ),
            SizedBox(width: 8),
            Text(
              "Fri, 21 Jul",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
        _circleIcon(Icons.notifications_none_outlined),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        const Text(
          "This Month Spend",
          style: TextStyle(color: Colors.black45, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          "\$313.31",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: 0.5,
              child: const Icon(
                Icons.arrow_downward,
                size: 16,
                color: Colors.black87,
              ),
            ),
            const Text(
              " 67% below last month",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletTile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.local_mall_outlined, size: 22),
          SizedBox(width: 12),
          Text(
            "Spending Wallet",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          Spacer(),
          Text(
            "\$5,631.22",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "See All",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        'title': 'Spotify Subscriptions',
        'date': '15 July 2023',
        'amt': '-\$4.99',
        'icon': Icons.music_note,
        'color': Colors.green,
      },
      {
        'title': 'Copay Balance Top up',
        'date': '14 July 2023',
        'amt': '-\$11.32',
        'icon': Icons.account_balance_wallet,
        'color': Colors.blue,
      },
      {
        'title': 'UI8 Subscriptions',
        'date': '12 July 2023',
        'amt': '-\$188',
        'icon': Icons.grid_view_rounded,
        'color': Colors.black,
      },
      {
        'title': 'Freepik Subscriptions',
        'date': '11 July 2023',
        'amt': '-\$109',
        'icon': Icons.face,
        'color': Colors.blueAccent,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 15, bottom: 100),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: (item['color'] as Color).withOpacity(0.1),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    item['date'] as String,
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item['amt'] as String,
                style: TextStyle(
                  color: Colors.red[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navBtn(Icons.home_filled, "Home", true),
            _navBtn(Icons.assignment_outlined, "Transaction", false),
            const SizedBox(width: 40), // Space for the FAB notch
            _navBtn(Icons.bar_chart_rounded, "Analytics", false),
            _navBtn(Icons.person_outline, "Account", false),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, bool active) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF7B61FF) : Colors.black26,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF7B61FF) : Colors.black26,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}
