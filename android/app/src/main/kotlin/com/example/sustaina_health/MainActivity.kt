package com.example.sustaina_health

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.sustaina_health/boot"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"launchedFromBoot" -> {
					val launchedFromBoot = intent?.getBooleanExtra("reschedule_on_start", false) == true
					result.success(launchedFromBoot)
				}
				"isExactAlarmPermitted" -> {
					try {
						val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
						val allowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
							alarmManager.canScheduleExactAlarms()
						} else {
							true
						}
						result.success(allowed)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"openExactAlarmSettings" -> {
					try {
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
							val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
						} else {
							// Fallback to app details settings
							val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
							intent.data = Uri.parse("package:$packageName")
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
						}
						result.success(true)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"isIgnoringBatteryOptimizations" -> {
					try {
						val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
						val ignoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							powerManager.isIgnoringBatteryOptimizations(packageName)
						} else {
							true // Assume true for older versions
						}
						result.success(ignoring)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"canScheduleExactAlarms" -> {
					try {
						val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
						val allowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
							alarmManager.canScheduleExactAlarms()
						} else {
							true
						}
						result.success(allowed)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"getPowerManagementStatus" -> {
					try {
						val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
						var status = "normal"

						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
								status = "battery_optimized"
							}
						}

						// Check if app is in whitelist (for some OEMs)
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
								status = "restricted"
							}
						}

						result.success(status)
					} catch (e: Exception) {
						result.success("unknown")
					}
				}
				"isAppWhitelisted" -> {
					try {
						val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
						val whitelisted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							powerManager.isIgnoringBatteryOptimizations(packageName)
						} else {
							true
						}
						result.success(whitelisted)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"openNotificationSettings" -> {
					try {
						val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
						intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
						intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
						startActivity(intent)
						result.success(true)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"openBatteryOptimizationSettings" -> {
					try {
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
						} else {
							// Fallback to app details
							val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
							intent.data = Uri.parse("package:$packageName")
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
						}
						result.success(true)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"requestIgnoreBatteryOptimizations" -> {
					try {
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
							intent.data = Uri.parse("package:$packageName")
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
							result.success(true)
						} else {
							result.success(true) // Not needed for older versions
						}
					} catch (e: Exception) {
						result.success(false)
					}
				}
				"isDoNotDisturbEnabled" -> {
					try {
						val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
						val isDndEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
							val currentInterruptionFilter = notificationManager.currentInterruptionFilter
							currentInterruptionFilter != android.app.NotificationManager.INTERRUPTION_FILTER_ALL
						} else {
							false // Assume false for older versions
						}
						result.success(isDndEnabled)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)

		// If the activity was started from the BootReceiver, include an intent extra
		// that the Flutter side can read via a platform channel or initialRoute parsing.
		val launchIntent: Intent? = intent
		if (launchIntent != null && launchIntent.getBooleanExtra("reschedule_on_start", false)) {
			// Keep minimal; Flutter will query the launchedFromBoot flag via MethodChannel.
		}
	}
}
