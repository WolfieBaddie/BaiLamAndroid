import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const FilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6366F1);
    const surfaceLight = Color(0xFF1F2937);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.2) : surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? primaryColor : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                icon,
                size: 18,
                color: isActive ? primaryColor : Colors.grey[400]
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[300],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isActive && onClear != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              )
            ]
          ],
        ),
      ),
    );
  }
}