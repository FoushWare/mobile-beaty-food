import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_provider.dart';

class OfflineStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onRetry;

  const OfflineStatusWidget({
    super.key,
    this.showDetails = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final theme = Theme.of(context);

    if (offlineState.isConnected) {
      return _buildConnectedStatus(context, theme, offlineState);
    } else {
      return _buildOfflineStatus(context, theme, offlineState);
    }
  }

  Widget _buildConnectedStatus(
      BuildContext context, ThemeData theme, OfflineState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Online',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.isSyncing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Syncing...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
              ),
            ),
          ],
          if (showDetails) ...[
            const Spacer(),
            if (state.pendingOperationsCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.pendingOperationsCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineStatus(
      BuildContext context, ThemeData theme, OfflineState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'You\'re offline',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 8),
            Text(
              'Some features may be limited. Your changes will be synced when you\'re back online.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            if (state.pendingOperationsCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.pendingOperationsCount} pending operations',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
            if (state.cacheStats.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildCacheInfo(context, theme, state),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCacheInfo(
      BuildContext context, ThemeData theme, OfflineState state) {
    return Row(
      children: [
        Icon(
          Icons.storage,
          color: Colors.grey[600],
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          'Cached: ${state.cacheStats['recipes_count'] ?? 0} recipes, ${state.cacheStats['orders_count'] ?? 0} orders',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (state.lastSyncHoursAgo != null && state.lastSyncHoursAgo! > 0) ...[
          const SizedBox(width: 8),
          Text(
            '• Updated ${state.lastSyncHoursAgo} hours ago',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  final bool showBanner;

  const OfflineBanner({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    if (!showBanner || !isOffline) {
      return child;
    }

    return Column(
      children: [
        OfflineStatusWidget(
          showDetails: true,
          onRetry: () {
            ref.read(offlineProvider.notifier).manualSync();
          },
        ),
        Expanded(child: child),
      ],
    );
  }
}

class ConnectionIndicator extends ConsumerWidget {
  final double size;
  final Color? color;

  const ConnectionIndicator({
    super.key,
    this.size = 12.0,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider);
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? (color ?? Colors.green) : (color ?? Colors.red),
      ),
      child: isConnected
          ? Icon(
              Icons.wifi,
              size: size * 0.6,
              color: Colors.white,
            )
          : Icon(
              Icons.wifi_off,
              size: size * 0.6,
              color: Colors.white,
            ),
    );
  }
}
