import 'package:flutter/material.dart';
import '../../../../services/data_sync_service.dart';

class DataSyncPage extends StatefulWidget {
  const DataSyncPage({super.key});

  @override
  State<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends State<DataSyncPage> {
  final DataSyncService _syncService = DataSyncService();
  
  bool _isSyncing = false;
  String _syncStatus = '';
  List<String> _progressLogs = <String>[];
  Map<String, dynamic>? _syncStats;
  SyncResult? _lastSyncResult;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    try {
      final Map<String, dynamic> stats = await _syncService.getSyncStatistics();
      setState(() {
        _syncStats = stats;
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Error loading sync stats: $e';
      });
    }
  }

  Future<void> _performSync({bool forceSync = false}) async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Starting sync...';
      _progressLogs.clear();
      _lastSyncResult = null;
    });

    try {
      final SyncResult result = await _syncService.syncAllDataToCloud(
        forceSync: forceSync,
        onProgress: (String message) {
          setState(() {
            _syncStatus = message;
            _progressLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
          });
          // Keep only last 20 log entries
          if (_progressLogs.length > 20) {
            _progressLogs.removeAt(0);
          }
        },
      );

      setState(() {
        _lastSyncResult = result;
        _syncStatus = result.message;
      });

      // Reload stats after sync
      await _loadSyncStats();

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Sync Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            _isSyncing ? Icons.sync : Icons.cloud_sync,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sync Status',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isSyncing)
                        const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        _syncStatus.isEmpty ? 'Ready to sync' : _syncStatus,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (_lastSyncResult != null && _lastSyncResult!.errors.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Errors (${_lastSyncResult!.errors.length}):',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...(_lastSyncResult!.errors.map((String error) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            '• $error',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ))),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sync Statistics Card
              if (_syncStats != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.analytics,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Local Data Summary',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_syncStats!['hasCompletedInitialSync'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.check_circle, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Initial sync completed',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.warning, size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  'Initial sync pending',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (_syncStats!['lastSyncTime'] != null)
                          Text(
                            'Last sync: ${DateTime.parse(_syncStats!['lastSyncTime']).toString().substring(0, 19)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        const SizedBox(height: 8),
                        if (_syncStats!['localDataCounts'] != null) ...<Widget>[
                          Text(
                            'Local Data Counts:',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...(_syncStats!['localDataCounts'] as Map<String, dynamic>).entries.map(
                            (MapEntry<String, dynamic> entry) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Row(
                                children: <Widget>[
                                  Text('• ${entry.key}: ', style: theme.textTheme.bodySmall),
                                  Text(
                                    '${entry.value}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : () => _performSync(forceSync: false),
                      icon: Icon(_isSyncing ? Icons.hourglass_empty : Icons.cloud_upload),
                      label: Text(_isSyncing ? 'Syncing...' : 'Smart Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : () => _performSync(forceSync: true),
                      icon: Icon(_isSyncing ? Icons.hourglass_empty : Icons.refresh),
                      label: Text(_isSyncing ? 'Syncing...' : 'Force Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Refresh Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadSyncStats,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Statistics'),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Logs
              if (_progressLogs.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.list,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sync Progress Log',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _progressLogs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String log = _progressLogs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.0),
                                child: Text(
                                  log,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Help Text
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.help_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sync Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Smart Sync: Only syncs data that hasn\'t been uploaded yet\n'
                        '• Force Sync: Re-uploads all local data to ensure cloud backup\n'
                        '• Data is organized in cloud by: Exercise, Nutrition, Sleep, Profile\n'
                        '• All data is saved locally first, then synced to cloud when online',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
