import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define Theme Colors matching FilterButton/Header
    const Color primaryColor = Color(0xFF6366F1); // Indigo
    const Color backgroundColor = Color(0xFF111827); // Dark Background
    const Color surfaceColor = Color(0xFF1F2937); // Surface Color

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // --- Icon Container ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event_note_rounded, // More modern icon
                  size: 80,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 40),

              // --- Title ---
              const Text(
                'Tech-Events Hub',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Discover and join the best tech events\nhappening around you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Matching app rounded style
                    ),
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    'Explore Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}