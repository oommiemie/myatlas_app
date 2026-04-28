import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/liquid_glass_button.dart';

class HomeUserHeader extends StatelessWidget {
  final String date;
  final String name;
  final bool hasUnread;
  final VoidCallback? onNotifications;

  const HomeUserHeader({
    super.key,
    required this.date,
    required this.name,
    this.hasUnread = false,
    this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              LiquidGlassButton(
                icon: CupertinoIcons.bell,
                iconColor: const Color(0xFF1A1A1A),
                size: 44,
                iconSize: 20,
                onTap: onNotifications,
              ),
              if (hasUnread)
                Positioned(
                  right: 10,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE62E05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
