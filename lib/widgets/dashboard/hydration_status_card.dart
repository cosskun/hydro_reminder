import 'package:flutter/material.dart';

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
    final title = status['title'] ?? 'Durumunuz';
    final message = status['message'] ?? '';
    final emoji = status['emoji'] ?? '💧';
    final imageAsset = status['imageAsset'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // 1. Left: Mascot Character Stage
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                    : [statusColor.withOpacity(0.15), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // 2. Right: Title Badge & Speech Bubble Dialogue
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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
}
