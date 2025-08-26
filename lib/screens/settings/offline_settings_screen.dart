import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/offline_provider.dart';
import '../../widgets/offline_status_widget.dart';

class OfflineSettingsScreen extends ConsumerStatefulWidget {
  const OfflineSettingsScreen({super.key});

  @override
  ConsumerState<OfflineSettingsScreen> createState() =>
      _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends ConsumerState<OfflineSettingsScreen> {
  int _cacheExpiryHours = 24;
  bool _autoSync = true;
  bool _wifiOnlySync = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences
    // This would be implemented based on your settings service
  }

  @override
  Widget build(BuildContext context) {
    final offlineState = ref.watch(offlineProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Connection Status
          OfflineStatusWidget(
            showDetails: true,
            onRetry: () {
              ref.read(offlineProvider.notifier).manualSync();
            },
          ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cache Management Section
                _buildSectionHeader(theme, 'Cache Management'),
                const SizedBox(height: 16),

                // Cache Statistics
                _buildCacheStatsCard(theme, offlineState),
                const SizedBox(height: 16),

                // Cache Expiry
                _buildCacheExpirySetting(theme),
                const SizedBox(height: 16),

                // Sync Settings Section
                _buildSectionHeader(theme, 'Sync Settings'),
                const SizedBox(height: 16),

                // Auto Sync
                _buildSwitchTile(
                  theme,
                  'Auto Sync',
                  'Automatically sync data when connection is restored',
                  Icons.sync,
                  _autoSync,
                  (value) {
                    setState(() {
                      _autoSync = value;
                    });
                    // Save setting
                  },
                ),

                // WiFi Only Sync
                _buildSwitchTile(
                  theme,
                  'WiFi Only Sync',
                  'Only sync when connected to WiFi',
                  Icons.wifi,
                  _wifiOnlySync,
                  (value) {
                    setState(() {
                      _wifiOnlySync = value;
                    });
                    // Save setting
                  },
                ),

                const SizedBox(height: 16),

                // Manual Actions Section
                _buildSectionHeader(theme, 'Manual Actions'),
                const SizedBox(height: 16),

                // Sync Now Button
                _buildActionButton(
                  theme,
                  'Sync Now',
                  'Manually sync all data',
                  Icons.sync,
                  offlineState.isSyncing,
                  () {
                    ref.read(offlineProvider.notifier).manualSync();
                  },
                ),

                const SizedBox(height: 8),

                // Clear Cache Button
                _buildActionButton(
                  theme,
                  'Clear Cache',
                  'Remove all cached data',
                  Icons.clear_all,
                  false,
                  () {
                    _showClearCacheDialog(context, theme);
                  },
                ),

                const SizedBox(height: 8),

                // Clear Offline Queue Button
                if (offlineState.pendingOperationsCount > 0)
                  _buildActionButton(
                    theme,
                    'Clear Pending Operations',
                    'Remove ${offlineState.pendingOperationsCount} pending operations',
                    Icons.pending_actions,
                    false,
                    () {
                      _showClearQueueDialog(context, theme);
                    },
                  ),

                const SizedBox(height: 16),

                // Offline Queue Section
                if (offlineState.offlineQueue.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Pending Operations'),
                  const SizedBox(height: 16),
                  _buildOfflineQueueList(theme, offlineState),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildCacheStatsCard(ThemeData theme, OfflineState state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Cache Statistics',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Recipes',
                    '${state.cacheStats['recipes_count'] ?? 0}',
                    Icons.restaurant,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Orders',
                    '${state.cacheStats['orders_count'] ?? 0}',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Favorites',
                    '${state.cacheStats['favorites_count'] ?? 0}',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (state.lastSyncHoursAgo != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Last updated: ${state.lastSyncHoursAgo == 0 ? 'Just now' : '${state.lastSyncHoursAgo} hours ago'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCacheExpirySetting(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Cache Expiry',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cache data for $_cacheExpiryHours hours',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _cacheExpiryHours.toDouble(),
              min: 1,
              max: 168, // 1 week
              divisions: 167,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  _cacheExpiryHours = value.round();
                });
                // Save setting
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 hour', style: theme.textTheme.bodySmall),
                Text('1 week', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Colors.blue),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isLoading ? null : onPressed,
      ),
    );
  }

  Widget _buildOfflineQueueList(ThemeData theme, OfflineState state) {
    return Card(
      elevation: 2,
      child: Column(
        children: state.offlineQueue.asMap().entries.map((entry) {
          final index = entry.key;
          final operation = entry.value;

          return ListTile(
            leading: Icon(
              _getOperationIcon(operation['operation']),
              color: Colors.orange,
            ),
            title: Text(_getOperationTitle(operation['operation'])),
            subtitle: Text(_getOperationDescription(operation)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Remove from queue
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getOperationIcon(String operation) {
    switch (operation) {
      case 'add_to_favorites':
        return Icons.favorite;
      case 'remove_from_favorites':
        return Icons.favorite_border;
      case 'create_order':
        return Icons.shopping_cart;
      case 'update_profile':
        return Icons.person;
      case 'add_review':
        return Icons.rate_review;
      default:
        return Icons.pending_actions;
    }
  }

  String _getOperationTitle(String operation) {
    switch (operation) {
      case 'add_to_favorites':
        return 'Add to Favorites';
      case 'remove_from_favorites':
        return 'Remove from Favorites';
      case 'create_order':
        return 'Create Order';
      case 'update_profile':
        return 'Update Profile';
      case 'add_review':
        return 'Add Review';
      default:
        return 'Unknown Operation';
    }
  }

  String _getOperationDescription(Map<String, dynamic> operation) {
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch(operation['timestamp']);
    return 'Queued ${_getTimeAgo(timestamp)}';
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showClearCacheDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will remove all cached data. You\'ll need to download it again when you\'re online.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(offlineProvider.notifier).clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearQueueDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pending Operations'),
        content: const Text(
            'This will remove all pending operations from the queue. These operations will not be synced.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(offlineProvider.notifier).clearOfflineQueue();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pending operations cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
