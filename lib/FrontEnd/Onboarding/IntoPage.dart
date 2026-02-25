import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ledger/FrontEnd/Auth/SignupPage.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(const LedgerApp());
}

class LedgerApp extends StatelessWidget {
  const LedgerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const IntroPage(),
    );
  }
}

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  double _sliderPosition = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final double _buttonWidth = 280;
  final double _buttonHeight = 56;
  final double _sliderSize = 48;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _resetSlider() {
    _animation =
        Tween<double>(begin: _sliderPosition, end: 0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {
            _sliderPosition = _animation.value;
          });
        });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF111827), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 32),

                    Transform.scale(scale: 1.05, child: _buildPhoneMockup()),

                    const SizedBox(height: 32),

                    _buildHeadline(),
                    const SizedBox(height: 32),

                    _buildSlideButton(),
                    const SizedBox(height: 24),

                    _buildPageIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- LOGO ----------------

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        const Text(
          'Ledger',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- PHONE MOCKUP ----------------

  Widget _buildPhoneMockup() {
    return Container(
      width: 252,
      height: 504,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF1F2937), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
                ),
              ),
              child: Column(
                children: [
                  _buildMiniStatusBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          _buildFeatureCard(
                            'Welcome to Ledger!\nLet\'s get started.',
                            Icons.monetization_on_outlined,
                            isDark: true,
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureCard(
                            'Track your expenses and income automatically.',
                            Icons.bar_chart,
                            isDark: false,
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureCard(
                            'Receive automatic reminders to stay on track.',
                            Icons.notifications_outlined,
                            isDark: true,
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureCard(
                            'Effortlessly manage all your finances in one place.',
                            Icons.verified_user_outlined,
                            isDark: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STATUS BAR ----------------

  Widget _buildMiniStatusBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_4_bar,
                size: 12,
                color: Colors.black87,
              ),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 12, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- FEATURE CARD ----------------

  Widget _buildFeatureCard(String text, IconData icon, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF111827),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: isDark ? const Color(0xFF111827) : Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADLINE ----------------

  Widget _buildHeadline() {
    return Column(
      children: [
        const Text(
          'Smart, Simple\nBudgeting Anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Effortless Budgeting, Anytime,\nAnywhere with Ledger!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ---------------- SLIDER BUTTON ----------------

  Widget _buildSlideButton() {
    return SizedBox(
      width: _buttonWidth,
      height: _buttonHeight,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Get Started',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          Positioned(
            left: _sliderPosition,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sliderPosition = (_sliderPosition + details.delta.dx).clamp(
                    0.0,
                    _buttonWidth - _sliderSize,
                  );
                });
              },
              onHorizontalDragEnd: (_) {
                if (_sliderPosition > 180) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const SignupPage(),
                    ),
                  );
                }
                _resetSlider();
              },
              child: Container(
                width: _sliderSize,
                height: _sliderSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF111827),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PAGE INDICATOR ----------------

  Widget _buildPageIndicator() {
    return Container(
      width: 80,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}