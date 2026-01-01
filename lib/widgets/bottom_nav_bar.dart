import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Theme Constants matching your App
    const Color primaryColor = Color(0xFF6366F1); // Indigo
    const Color surfaceColor = Color(0xFF1F2937); // Dark Surface

    // Calculate active colors
    final Color activeColor = primaryColor;
    final Color inactiveColor = Colors.grey[600]!;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // --- 1. Background Layer (Blur + Border) ---
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.9), // Darker, semi-transparent
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- 2. Content Layer ---
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- LEFT: HOME ---
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: "Home",
                      index: 0,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),

                    // --- CENTER: CREATE (Floating) ---
                    Transform.translate(
                      offset: const Offset(0, -25), // Float higher
                      child: GestureDetector(
                        onTap: () => onTap(1),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: primaryColor, // Indigo Button
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    // --- RIGHT: REGISTRATIONS ---
                    _buildNavItem(
                      icon: Icons.confirmation_number_rounded, // Ticket/Registration icon
                      label: "My Tickets",
                      index: 2,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                boxShadow: isSelected
                    ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 12)]
                    : [],
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            // Optional: Dot indicator or Label
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}