import 'package:flutter/material.dart';

class CreativeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CreativeNavItem> items;

  const CreativeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30), // Floating off bottom
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white, // Pure white background
          borderRadius: BorderRadius.circular(35), // Pill shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = currentIndex == index;
            // Special styling for the Power/Logout button (last item)
            final isPowerBtn = index == 3;

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: isPowerBtn ? Colors.red : Colors.black,
                        borderRadius: BorderRadius.circular(25),
                      )
                    : BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      // Active is white, Inactive is light grey
                      color: isSelected ? Colors.white : Colors.grey[400],
                      size: 24,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CreativeNavItem {
  final IconData icon;
  final String label;

  CreativeNavItem({required this.icon, required this.label});
}
