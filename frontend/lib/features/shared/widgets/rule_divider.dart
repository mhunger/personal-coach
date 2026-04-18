import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Double-rule divider — two thin rule-gray lines with a small gap, set
/// between major editorial sections. Subtle but recognisably editorial.
class RuleDivider extends StatelessWidget {
  final double verticalPadding;
  final Color color;

  const RuleDivider({
    super.key,
    this.verticalPadding = 12,
    this.color = AppColors.ruleGray,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: color),
          const SizedBox(height: 3),
          Container(height: 1, color: color),
        ],
      ),
    );
  }
}
