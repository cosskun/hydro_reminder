import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

void showDeletePresetDialog(BuildContext context, int amount, {VoidCallback? onConfirm}) {
  final meta = WaterProvider.getPresetMeta(amount);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${meta['emoji']} Butonu Kaldır?'),
        content: Text('$amount ml (${meta['name']}) hızlı su ekleme butonunu anasayfadan kaldırmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<WaterProvider>(context, listen: false).removeQuickPreset(amount);
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$amount ml butonu kaldırıldı.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaldır'),
          ),
        ],
      );
    },
  );
}
