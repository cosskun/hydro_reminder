import 'package:flutter/material.dart';

/// In-app Dashboard card showing the mascot strictly aligned with the user's hydration level / energy ladder
class HydrationStatusCard extends StatelessWidget {
  final Map<String, String> status;
  final Color statusColor;
  final bool isDark;

  const HydrationStatusCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = status['emoji'] ?? '💧';
    // Strictly display the hydration energy ladder illustration on the in-app dashboard
    final displayAsset = status['energyImageAsset'] ?? status['imageAsset'];
    final displayTitle = status['energyTitle'] ?? status['title'] ?? 'Canlılık Seviyesi';
    final displayMessage = status['energyMessage'] ?? status['message'] ?? '';
    final energyPercentage = status['energyPercentage'] ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: statusColor.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(isDark ? 0.20 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Left: Hydration Level Mascot Stage
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widgetColors(isDark, statusColor),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(isDark ? 0.25 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: displayAsset != null
                  ? Image.asset(
                      displayAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // 2. Right: Title Badge, Energy Battery Chip & Mascot Dialogue
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '⚡ %$energyPercentage',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayMessage,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Color> widgetColors(bool isDark, Color statusColor) {
    return isDark
        ? [const Color(0xFF334155), const Color(0xFF1E293B)]
        : [statusColor.withOpacity(0.18), Colors.white];
  }
}
