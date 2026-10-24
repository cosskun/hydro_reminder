import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-app Dashboard card showing the live mascot routine aligned with time of day and hydration needs
/// with tap-to-toggle capability to preview the hydration energy charge ladder
class HydrationStatusCard extends StatefulWidget {
  final Map<String, String> status;
  final Color statusColor;
  final bool isDark;
  final bool isCompact;

  const HydrationStatusCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.isDark,
    this.isCompact = false,
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
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 11 : 14,
          vertical: widget.isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(widget.isCompact ? 18 : 22),
          border: Border.all(
            color: widget.statusColor.withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.statusColor.withOpacity(widget.isDark ? 0.20 : 0.08),
              blurRadius: widget.isCompact ? 10 : 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Left: Hydration Mascot Character Stage
            Container(
              width: widget.isCompact ? 68 : 88,
              height: widget.isCompact ? 68 : 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widgetColors(widget.isDark, widget.statusColor),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
                border: Border.all(
                  color: widget.statusColor.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.statusColor.withOpacity(widget.isDark ? 0.25 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.isCompact ? 14 : 18),
                child: displayAsset != null
                    ? Image.asset(
                        displayAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: widget.isCompact ? 32 : 40),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: widget.isCompact ? 32 : 40),
                        ),
                      ),
              ),
            ),
            SizedBox(width: widget.isCompact ? 10 : 14),

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
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isCompact ? 7 : 9,
                            vertical: widget.isCompact ? 2 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: widget.isCompact ? 11 : 12,
                              fontWeight: FontWeight.w800,
                              color: widget.statusColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isCompact ? 5 : 7,
                          vertical: widget.isCompact ? 1.5 : 2.5,
                        ),
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
                            fontSize: widget.isCompact ? 9.5 : 10.5,
                            fontWeight: FontWeight.w800,
                            color: widget.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.isCompact ? 4 : 6),
                  Text(
                    displayMessage,
                    maxLines: widget.isCompact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.isCompact ? 11.5 : 13,
                      fontWeight: FontWeight.w600,
                      height: widget.isCompact ? 1.25 : 1.35,
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
