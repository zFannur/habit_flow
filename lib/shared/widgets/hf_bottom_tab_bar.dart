import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

class HFTabItem {
  const HFTabItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Bottom tab bar в варианте, который применён в реальных экранах
/// (today-screen.html и др.): плоский бар с верхним бордером и тенью.
/// Активная иконка в 44×28 pill с background rgba(accent,0.12).
/// Неактивная — text-tertiary. Лейбл fontSize 10.
class HFBottomTabBar extends StatelessWidget {
  const HFBottomTabBar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onChanged,
  });

  final List<HFTabItem> items;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, -2),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(child: _Tab(
              item: items[i],
              active: i == activeIndex,
              onTap: () => onChanged(i),
            )),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.active, required this.onTap});

  final HFTabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final color = active ? c.accent : c.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? c.accent.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: context.tt.bodyMedium!.copyWith(color: color, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
