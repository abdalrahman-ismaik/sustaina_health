import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_repository_providers.dart';

class SyncStatusIndicator extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;
  
  const SyncStatusIndicator({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, int>> syncStatus = ref.watch(syncStatusProvider);
    final bool isSyncing = ref.watch(isSyncingProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showDetails ? 12 : 8,
          vertical: showDetails ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(showDetails ? 12 : 20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: syncStatus.when(
          data: (Map<String, int> status) {
            final int pending = status['pending'] ?? 0;
            final int total = status['total'] ?? 0;
            final int synced = status['synced'] ?? 0;
            
            Color statusColor;
            IconData statusIcon;
            String statusText;
            
            if (isSyncing) {
              statusColor = colorScheme.secondary;
              statusIcon = Icons.sync;
              statusText = 'Syncing...';
            } else if (pending > 0) {
              statusColor = Colors.orange;
              statusIcon = Icons.cloud_off;
              statusText = '$pending pending';
            } else if (total > 0) {
              statusColor = Colors.green;
              statusIcon = Icons.cloud_done;
              statusText = 'All synced';
            } else {
              statusColor = colorScheme.onSurfaceVariant;
              statusIcon = Icons.cloud_queue;
              statusText = 'No data';
            }
            
            if (showDetails) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sync Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$synced/$total synced',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (pending > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$pending pending',
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isSyncing)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: statusColor,
                      ),
                    )
                  else
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                  if (showDetails || pending > 0) ...<Widget>[
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            }
          },
          loading: () => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
              if (showDetails) ...<Widget>[
                const SizedBox(width: 6),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          error: (Object error, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 14,
                color: colorScheme.error,
              ),
              if (showDetails) ...<Widget>[
                const SizedBox(width: 4),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SyncActionButton extends ConsumerWidget {
  const SyncActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSyncing = ref.watch(isSyncingProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: isSyncing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            )
          : Icon(
              Icons.sync,
              color: colorScheme.primary,
            ),
      onPressed: isSyncing
          ? null
          : () async {
              try {
                await ref.read(syncActionProvider)();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync completed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sync failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      tooltip: isSyncing ? 'Syncing...' : 'Sync data',
    );
  }
}
