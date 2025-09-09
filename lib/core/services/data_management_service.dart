import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManagementService {
  
  /// Export user data to device storage
  static Future<bool> exportUserData() async {
    try {
      // Request storage permission
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          debugPrint('Storage permission denied');
          return false;
        }
      }

      // Get app data
      final prefs = await SharedPreferences.getInstance();
      final allData = prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
        final value = prefs.get(key);
        map[key] = value;
        return map;
      });

      // Add metadata
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'dataType': 'Sustaina Health User Data',
        'userData': allData,
      };

      // Convert to JSON
      final jsonData = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get documents directory
      Directory directory;
      if (kIsWeb) {
        // For web, we'll use download (this is simplified)
        return false; // Web export needs different implementation
      } else if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Use Downloads folder on Android
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'sustaina_health_data_$timestamp.json';
      final file = File('${directory.path}/$filename');

      // Write file
      await file.writeAsString(jsonData);
      
      debugPrint('Data exported to: ${file.path}');
      return true;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return false;
    }
  }

  /// Clear app cache and temporary files
  static Future<bool> clearCache() async {
    try {
      // Clear temporary directory
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      // Clear specific cache keys from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getKeys().where((key) => 
        key.startsWith('cache_') || 
        key.startsWith('temp_') ||
        key.contains('_cache')
      ).toList();

      for (final key in cacheKeys) {
        await prefs.remove(key);
      }

      debugPrint('Cache cleared successfully');
      return true;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }

  /// Reset all app data
  static Future<bool> resetAppData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      if (appDir.existsSync()) {
        final contents = appDir.listSync();
        for (final entity in contents) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            debugPrint('Could not delete ${entity.path}: $e');
          }
        }
      }

      // Clear cache
      await clearCache();

      // Clear app support directory
      try {
        final supportDir = await getApplicationSupportDirectory();
        if (supportDir.existsSync()) {
          final contents = supportDir.listSync();
          for (final entity in contents) {
            try {
              await entity.delete(recursive: true);
            } catch (e) {
              debugPrint('Could not delete ${entity.path}: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error clearing support directory: $e');
      }

      debugPrint('App data reset successfully');
      return true;
    } catch (e) {
      debugPrint('Error resetting app data: $e');
      return false;
    }
  }

  /// Get cache size in MB
  static Future<double> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (!tempDir.existsSync()) return 0.0;

      int totalSize = 0;
      await for (final entity in tempDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (e) {
            // File might be deleted while we're calculating
          }
        }
      }

      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0.0;
    }
  }

  /// Get app data size in MB
  static Future<double> getAppDataSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (!appDir.existsSync()) return 0.0;

      int totalSize = 0;
      await for (final entity in appDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (e) {
            // File might be deleted while we're calculating
          }
        }
      }

      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error calculating app data size: $e');
      return 0.0;
    }
  }

  /// Check if export is supported on current platform
  static bool isExportSupported() {
    return !kIsWeb; // Export not supported on web for now
  }
}
