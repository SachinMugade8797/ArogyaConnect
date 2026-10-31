import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';

class ActiveProfileBar extends ConsumerWidget {
  const ActiveProfileBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return profilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) return const SizedBox.shrink();
        final active = profiles.firstWhere((p) => p.id == activeId, orElse: () => profiles.first);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary100,
                child: Text(
                  active.name.isNotEmpty ? active.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.primary700,
                    fontWeight: FontWeight.bold,
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
                        Flexible(
                          child: Text(
                            active.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary200),
                          ),
                          child: Text(
                            active.relation,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Blood Group: ${active.bloodGroup ?? "N/A"} • ${active.gender ?? "Patient"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary600),
                tooltip: 'Switch Family Member',
                onSelected: (id) {
                  ref.read(activeProfileIdProvider.notifier).state = id;
                },
                itemBuilder: (context) {
                  return profiles.map((p) {
                    return PopupMenuItem<String>(
                      value: p.id,
                      child: Row(
                        children: [
                          Icon(
                            p.id == activeId ? Icons.check_circle : Icons.circle_outlined,
                            size: 18,
                            color: p.id == activeId ? AppColors.primary600 : AppColors.slate400,
                          ),
                          const SizedBox(width: 8),
                          Text('${p.name} (${p.relation})'),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (e, stack) => const SizedBox.shrink(),
    );
  }
}
