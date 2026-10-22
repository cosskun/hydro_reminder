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
    Color borderColor = isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.12);
    Color shadowColor = isDark ? Colors.black26 : theme.colorScheme.primary.withValues(alpha: 0.04);
    Color titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    if (isDangerZone) {
      bgColor = isDark ? const Color(0xFF3B1219) : Colors.red.shade50.withValues(alpha: 0.3);
      borderColor = isDark ? Colors.red.shade900 : Colors.red.shade100.withValues(alpha: 0.5);
      titleColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
      shadowColor = Colors.transparent;
    }

    return Container(
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
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          if (titleTrailing != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                titleTrailing!,
              ],
            )
          else
            Text(
              title,
              maxLines: 2,
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
    ),
  ),
);
  }
}
