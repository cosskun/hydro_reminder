import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/mascot_model.dart';

/// Shows an interactive preview of all 10 daily routine states & 5 energy ladder levels for a chosen mascot
void showMascotStatePreviewDialog(BuildContext context, MascotCharacter mascot, {String lang = 'tr'}) {
  final isEn = lang == 'en';
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // 1. Resolve all 10 routine states without heuristic collapses or energy overrides
  final routineStates = MascotState.values.map((state) {
    return MascotResolver.resolveDialogueForState(
      mascotType: mascot.id,
      state: state,
      lang: lang,
    );
  }).toList();

  // 2. Resolve all 5 progressive energy ladder levels (0%, 25%, 50%, 75%, 100%)
  const energyTiers = MascotEnergyTier.values;
  final energyStates = energyTiers.map((tier) {
    return MascotResolver.resolveDialogueForEnergyTier(
      mascotType: mascot.id,
      tier: tier,
      lang: lang,
    );
  }).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final double navBarHeight = math.max(
        MediaQuery.of(ctx).viewPadding.bottom,
        MediaQuery.of(ctx).padding.bottom,
      );
      final double bottomPadding = navBarHeight > 0 ? navBarHeight + 14 : 16.0;
      int selectedTab = 0; // 0: 10 Routine States, 1: 5 Energy Ladder Levels

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.55,
            maxChildSize: 0.96,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header with Mascot Avatar & Title
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(ctx).colorScheme.primary,
                                Theme.of(ctx).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              mascot.defaultImageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(mascot.emoji, style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? mascot.nameEn : mascot.nameTr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Theme.of(ctx).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEn
                                    ? 'Expressions, smart reminders & energy tiers'
                                    : 'Gün içi ifadeler, akıllı uyarılar ve şarj kademeleri',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Segmented Toggle Bar: 10 Routine States vs 5 Energy Tiers
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(() => selectedTab = 0),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedTab == 0
                                      ? Theme.of(ctx).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: selectedTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(ctx).colorScheme.primary.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isEn ? '10 Daily States' : '10 Gün İçi Durum & Uyarı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.w600,
                                    color: selectedTab == 0
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(() => selectedTab = 1),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedTab == 1
                                      ? Theme.of(ctx).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: selectedTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(ctx).colorScheme.primary.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isEn ? '5 Energy Levels' : '5 Canlılık & Şarj Kademesi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.w600,
                                    color: selectedTab == 1
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section Description Hint
                    Text(
                      selectedTab == 0
                          ? (isEn
                              ? '10 unique context-aware daily expressions & smart reminders with distinct custom artwork.'
                              : 'Günün farklı saatleri ve su içme alışkanlıklarına özel 10 farklı çizim ve maskot mesajı.')
                          : (isEn
                              ? '5 progressive hydration levels from 0% to 100% daily intake with charging artwork.'
                              : 'Günlük hedefine ulaştıkça sıfırdan zirveye artan 5 farklı canlılık ve şarj seviyesi.'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Active Tab Item List
                    Expanded(
                      child: selectedTab == 0
                          ? _buildRoutineList(
                              scrollController: scrollController,
                              isDark: isDark,
                              isEn: isEn,
                              items: routineStates,
                            )
                          : _buildEnergyList(
                              scrollController: scrollController,
                              isDark: isDark,
                              isEn: isEn,
                              tiers: energyTiers,
                              items: energyStates,
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildRoutineList({
  required ScrollController scrollController,
  required bool isDark,
  required bool isEn,
  required List<MascotDialogue> items,
}) {
  return ListView.separated(
    controller: scrollController,
    physics: const BouncingScrollPhysics(),
    itemCount: items.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final item = items[index];
      final stateColor = Color(int.parse('FF${item.hexColor}', radix: 16));
      final stateTag = MascotResolver.getStateTag(item.state, isEn);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: stateColor.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: stateColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              stateTag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: stateColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildEnergyList({
  required ScrollController scrollController,
  required bool isDark,
  required bool isEn,
  required List<MascotEnergyTier> tiers,
  required List<MascotDialogue> items,
}) {
  return ListView.separated(
    controller: scrollController,
    physics: const BouncingScrollPhysics(),
    itemCount: items.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final tier = tiers[index];
      final item = items[index];
      final stateColor = Color(int.parse('FF${item.hexColor}', radix: 16));
      final tierLabel = isEn
          ? '${tier.stepValue}% Energy • Tier ${index + 1}'
          : '%${tier.stepValue} Canlılık • Seviye ${index + 1}';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: stateColor.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: stateColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              tierLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: stateColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
