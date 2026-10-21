import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _showRoutineVisual = false;

  @override
  Widget build(BuildContext context) {
    final emoji = widget.status['emoji'] ?? '💧';
    final primaryAsset = widget.status['imageAsset'];
    final routineAsset = widget.status['routineImageAsset'];
    final energyPercentage = widget.status['energyPercentage'];

    final bool canToggle = routineAsset != null &&
        routineAsset.isNotEmpty &&
        primaryAsset != null &&
        routineAsset != primaryAsset;

    final displayAsset = (_showRoutineVisual && canToggle) ? routineAsset : primaryAsset;
    final displayTitle = (_showRoutineVisual && canToggle && widget.status['routineTitle']?.isNotEmpty == true)
        ? widget.status['routineTitle']!
        : (widget.status['title'] ?? 'Durumunuz');
    final displayMessage = (_showRoutineVisual && canToggle && widget.status['routineMessage']?.isNotEmpty == true)
        ? widget.status['routineMessage']!
        : (widget.status['message'] ?? '');

    return GestureDetector(
      onTap: canToggle
          ? () {
              HapticFeedback.lightImpact();
              setState(() {
                _showRoutineVisual = !_showRoutineVisual;
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
            // 1. Left: Mascot Character Stage (Enlarged to 88x88 for prominent impact)
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDark
                      ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                      : [widget.statusColor.withOpacity(0.18), Colors.white],
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

            // 2. Right: Title Badge, Energy Chip & Speech Bubble Dialogue
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
                      if (energyPercentage != null && energyPercentage.isNotEmpty) ...[
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
                            _showRoutineVisual ? '🌙 Rutin' : '⚡ %$energyPercentage',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: widget.statusColor,
                            ),
                          ),
                        ),
                      ],
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
                  if (canToggle) ...[
                    const SizedBox(height: 4),
                    Text(
                      _showRoutineVisual ? '⚡ Enerji moduna dönmek için dokun' : '🔄 Saat rutinini görmek için dokun',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
