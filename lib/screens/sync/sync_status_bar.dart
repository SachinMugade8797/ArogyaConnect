import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/sync/sync_engine.dart';
import '../../providers/app_providers.dart';

class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncEngine = ref.watch(syncEngineProvider);

    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (syncEngine.status) {
      case SyncStatus.offline:
        bgColor = AppColors.slate100;
        textColor = AppColors.slate700;
        icon = Icons.cloud_off_rounded;
        text = 'Offline Mode • Local DB Active (${syncEngine.pendingCount} pending)';
        break;
      case SyncStatus.syncing:
        bgColor = AppColors.primary100;
        textColor = AppColors.primary800;
        icon = Icons.sync_rounded;
        text = 'Syncing offline records with cloud…';
        break;
      case SyncStatus.synced:
        bgColor = const Color(0xFFE8FDF3);
        textColor = const Color(0xFF065F46);
        icon = Icons.cloud_done_rounded;
        text = 'Online & Synchronized';
        break;
      case SyncStatus.error:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.sync_problem_rounded;
        text = 'Sync failed. Retry when online.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: textColor.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.refresh_rounded, size: 20, color: textColor),
            tooltip: 'Sync Now',
            onPressed: () {
              ref.read(syncEngineProvider).syncAll();
            },
          ),
        ],
      ),
    );
  }
}
