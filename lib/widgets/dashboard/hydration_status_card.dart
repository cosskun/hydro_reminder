import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-app Dashboard card showing the live mascot routine aligned with time of day and hydration needs
/// with tap-to-toggle capability to preview the hydration energy charge ladder
class HydrationStatusCard extends StatefulWidget {
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
  State<HydrationStatusCard> createState() => _HydrationStatusCardState();
}

class _HydrationStatusCardState extends State<HydrationStatusCard> {
  bool _showEnergyVisual = false;

  @override
  Widget build(BuildContext context) {
    final emoji = widget.status['emoji'] ?? '💧';
    final routineAsset = widget.status['routineImageAsset'] ?? widget.status['imageAsset'];
    final energyAsset = widget.status['energyImageAsset'];

    final bool canToggle = energyAsset != null &&
        energyAsset.isNotEmpty &&
        routineAsset != null &&
        routineAsset.isNotEmpty &&
        energyAsset != routineAsset;

    final displayAsset = (_showEnergyVisual && canToggle)
        ? energyAsset
        : (routineAsset ?? widget.status['imageAsset']);

    final displayTitle = (_showEnergyVisual && canToggle && widget.status['energyTitle']?.isNotEmpty == true)
        ? widget.status['energyTitle']!
        : (widget.status['routineTitle'] ?? widget.status['title'] ?? 'Durumunuz');

    final displayMessage = (_showEnergyVisual && canToggle && widget.status['energyMessage']?.isNotEmpty == true)
        ? widget.status['energyMessage']!
        : (widget.status['routineMessage'] ?? widget.status['message'] ?? '');

    final energyPercentage = widget.status['energyPercentage'] ?? '0';

    return GestureDetector(
      onTap: canToggle
          ? () {
              HapticFeedback.lightImpact();
              setState(() {
                _showEnergyVisual = !_showEnergyVisual;
              });
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.statusColor.withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.statusColor.withOpacity(widget.isDark ? 0.20 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Left: Hydration Mascot Character Stage
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widgetColors(widget.isDark, widget.statusColor),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.statusColor.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.statusColor.withOpacity(widget.isDark ? 0.25 : 0.12),
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
                            color: widget.statusColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: widget.statusColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '⚡ %$energyPercentage',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: widget.statusColor,
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
                      color: widget.isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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

  static List<Color> widgetColors(bool isDark, Color statusColor) {
    return isDark
        ? [const Color(0xFF334155), const Color(0xFF1E293B)]
        : [statusColor.withOpacity(0.18), Colors.white];
  }
}
