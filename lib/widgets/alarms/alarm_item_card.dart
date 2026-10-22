import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_setting.dart';
import '../../providers/water_provider.dart';

class AlarmItemCard extends StatelessWidget {
  final AlarmSetting alarm;
  final VoidCallback onTap;

  const AlarmItemCard({
    super.key,
    required this.alarm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.12),
          ),
        ),
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.alarm_rounded,
                color: alarm.isEnabled ? primary : (isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.timeFormatted,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: alarm.isEnabled
                            ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B))
                            : (isDark ? const Color(0xFF64748B) : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          alarm.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0B132B) : primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3A506B) : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            alarm.soundName,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Toggle switch
              Switch(
                value: alarm.isEnabled,
                activeThumbColor: primary,
                activeTrackColor: primary.withValues(alpha: 0.5),
                inactiveThumbColor: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                inactiveTrackColor: isDark ? const Color(0xFF0B132B) : Colors.grey.shade200,
                onChanged: (val) {
                  provider.toggleAlarm(alarm.id, val);
                },
              ),
              // Delete icon
              IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade300,
                  size: 20,
                ),
                onPressed: () {
                  provider.deleteAlarm(alarm.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
