import 'package:flutter/material.dart';

class SettingsCardWrapper extends StatelessWidget {
  final String title;
  final Widget? titleTrailing;
  final List<Widget> children;
  final bool isDangerZone;

  const SettingsCardWrapper({
    super.key,
    required this.title,
    this.titleTrailing,
    required this.children,
    this.isDangerZone = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor = isDark ? const Color(0xFF1C2541) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF3A506B) : Colors.blue.shade50;
    Color shadowColor = isDark ? Colors.black26 : Colors.blue.shade900.withOpacity(0.03);
    Color titleColor = isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900;

    if (isDangerZone) {
      bgColor = isDark ? const Color(0xFF3B1219) : Colors.red.shade50.withOpacity(0.3);
      borderColor = isDark ? Colors.red.shade900 : Colors.red.shade100.withOpacity(0.5);
      titleColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
      shadowColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: shadowColor == Colors.transparent
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleTrailing != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                titleTrailing!,
              ],
            )
          else
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
