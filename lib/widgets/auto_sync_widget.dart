import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/data_sync_service.dart';

/// Widget that automatically syncs data when user signs in
class AutoSyncWidget extends StatefulWidget {
  final Widget child;
  final bool showProgressIndicator;
  
  const AutoSyncWidget({
    super.key,
    required this.child,
    this.showProgressIndicator = false,
  });

  @override
  State<AutoSyncWidget> createState() => _AutoSyncWidgetState();
}

class _AutoSyncWidgetState extends State<AutoSyncWidget> {
  final DataSyncService _syncService = DataSyncService();
  bool _isSyncing = false;
  String _syncProgress = '';
  bool _hasTriggeredSync = false; // Prevent multiple sync triggers

  @override
  void initState() {
    super.initState();
    _checkAndPerformSync();
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && !_hasTriggeredSync) {
        _checkAndPerformSync();
      }
    });
  }

  Future<void> _checkAndPerformSync() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _isSyncing || _hasTriggeredSync) {
      print('🔄 AutoSync: Skipping sync - user: ${user?.uid}, syncing: $_isSyncing, triggered: $_hasTriggeredSync');
      return;
    }

    try {
      print('🔄 AutoSync: Checking if initial sync needed...');
      // Check if initial sync has been completed
      final bool hasCompleted = await _syncService.hasCompletedInitialSync();
      
      if (!hasCompleted) {
        print('🔄 AutoSync: Starting initial data sync...');
        _hasTriggeredSync = true; // Mark as triggered to prevent duplicates
        
        setState(() {
          _isSyncing = true;
          _syncProgress = 'Performing initial data sync...';
        });

        // Perform background sync
        await _syncService.syncAllDataToCloud(
          onProgress: (String message) {
            print('🔄 AutoSync Progress: $message');
            if (mounted) {
              setState(() {
                _syncProgress = message;
              });
            }
          },
        );

        setState(() {
          _isSyncing = false;
          _syncProgress = '';
        });
        print('🔄 AutoSync: Initial sync completed');
      } else {
        print('🔄 AutoSync: Initial sync already completed, skipping');
      }
    } catch (e) {
      print('💥 Auto-sync failed: $e');
      setState(() {
        _isSyncing = false;
        _syncProgress = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        
        // Show progress indicator if syncing and enabled
        if (_isSyncing && widget.showProgressIndicator)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _syncProgress.isEmpty ? 'Syncing data...' : _syncProgress,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
