import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

void showDeletePresetDialog(BuildContext context, int amount, {VoidCallback? onConfirm}) {
  final provider = Provider.of<WaterProvider>(context, listen: false);
  final isEn = provider.language == 'en';
  final meta = WaterProvider.getPresetMeta(amount, lang: provider.language);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEn ? 'Remove ${meta['emoji']} Preset?' : '${meta['emoji']} Butonu Kaldır?'),
        content: Text(
          isEn
              ? 'Are you sure you want to remove the $amount ml (${meta['name']}) quick add button from dashboard?'
              : '$amount ml (${meta['name']}) hızlı su ekleme butonunu anasayfadan kaldırmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isEn ? 'Cancel' : 'Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<WaterProvider>(context, listen: false).removeQuickPreset(amount);
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEn ? '$amount ml button removed.' : '$amount ml butonu kaldırıldı.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(isEn ? 'Remove' : 'Kaldır'),
          ),
        ],
      );
    },
  );
}
