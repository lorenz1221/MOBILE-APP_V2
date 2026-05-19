import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

class AppBrand extends StatelessWidget {
  final bool compact;

  const AppBrand({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: compact ? 32 : 36,
          width: compact ? 32 : 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
            size: compact ? 18 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Inventory MS',
              style: TextStyle(
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (!compact)
              const Text(
                'Stock and Sales Control',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
