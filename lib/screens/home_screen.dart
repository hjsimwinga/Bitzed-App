import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/common_widgets.dart';
import 'buy_bitcoin_screen.dart';
import 'spend_bitcoin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const AppLoadingWidget(message: 'Loading BitZed...');
          }

          if (appState.error != null) {
            return AppErrorWidget(
              message: appState.error!,
              onRetry: () => appState.initializeApp(),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Top Section - Logo and Exchange Rate on same row
                    _buildTopRow(context, appState),
                    
                    const SizedBox(height: 40),
                    
                    // Main Action Buttons
                    _buildMainButtons(context, appState),
                    
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildWhatsAppButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopRow(BuildContext context, AppStateProvider appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo and App Name
        Flexible(
          child: Row(
            children: [
              _buildEagleLogo(),
              const SizedBox(width: 12),
              const Text(
                'BitZed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
        
        // Exchange Rate Display - Top Right
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              appState.currentRate != null 
                  ? '1 ZMW = ${appState.convertZMWToSats(1).toStringAsFixed(0)} sats'
                  : '1 ZMW = 38 sats',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEagleLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Eagle head (more detailed)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: CustomPaint(
              painter: EaglePainter(),
            ),
          ),
          // Bitcoin symbol overlay with lightning
          Positioned(
            right: 5,
            bottom: 5,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lightning bolt background
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Bitcoin symbol
                  const Text(
                    '₿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, AppStateProvider appState) {
    return Column(
      children: [
        // Spend Bitcoin Button - 2x height
        _buildActionButton(
          context: context,
          title: 'Spend Bitcoin',
          color: Colors.orange[600]!,
          onTap: () {
            if (appState.spendStatus?.outOfStock == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appState.spendStatus?.message ?? 'Spend service is currently unavailable'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SpendBitcoinScreen(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Buy Bitcoin Button - 2x height
        _buildActionButton(
          context: context,
          title: 'Buy Bitcoin',
          color: Colors.blue[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BuyBitcoinScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120, // 2x height (was 60)
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24, // 2x font size (was 18)
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green[600],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.chat,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// Custom painter for eagle logo
class EaglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange[300]!
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.orange[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Eagle head shape
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.3, size.width * 0.2, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.7, size.width * 0.3, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.7, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.7, size.width * 0.8, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width * 0.7, size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    // Eagle eye
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4),
      size.width * 0.08,
      eyePaint,
    );

    // Eagle beak
    final beakPaint = Paint()
      ..color = Colors.orange[600]!
      ..style = PaintingStyle.fill;

    final beakPath = Path();
    beakPath.moveTo(size.width * 0.2, size.height * 0.5);
    beakPath.lineTo(size.width * 0.1, size.height * 0.6);
    beakPath.lineTo(size.width * 0.2, size.height * 0.7);
    beakPath.close();

    canvas.drawPath(beakPath, beakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}