import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/dialogs/alarm_edit_dialog.dart';
import '../widgets/alarms/alarm_item_card.dart';
import '../widgets/alarms/empty_alarms_view.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = provider.language == 'en';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEn ? 'Reminder Alarms ⏰' : 'Hatırlatıcı Alarmlar ⏰',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => showAlarmEditDialog(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'Persistent fullscreen smart alarms ring at your designated times.'
                : 'Belirlediğiniz saatlerde tam ekran kapatılamayan akıllı alarmlar çalar.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // List of Alarms
          if (provider.alarms.isEmpty)
            const EmptyAlarmsView()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = provider.alarms[index];
                return AlarmItemCard(
                  alarm: alarm,
                  onTap: () => showAlarmEditDialog(context, alarm),
                );
              },
            ),
        ],
      ),
    );
  }
}
