import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_models.dart';
import '../../../../core/services/firebase_notification_service.dart';

class FirebaseNotificationDataService {
  static const String _notificationsCollection = 'notifications';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();
  
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();
  
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  static final FirebaseNotificationDataService _instance = FirebaseNotificationDataService._internal();
  factory FirebaseNotificationDataService() => _instance;
  FirebaseNotificationDataService._internal();

  Future<void> initialize() async {
    try {
      print('🔔 Starting Firebase notification service initialization...');
      
      // Check if user is authenticated
      final user = _auth.currentUser;
      print('🔔 Current user: ${user?.email ?? 'No user authenticated'}');
      
      if (user == null) {
        print('🔔 No user authenticated, creating sample notifications for testing');
        _createSampleNotifications();
        return;
      }

      // Initialize Firebase notification service first
      await _notificationService.initialize();
      print('🔔 Firebase notification service core initialized');
      
      // Set up FCM message handlers for real-time notifications
      await _setupFCMHandlers();
      print('🔔 FCM handlers set up');
      
      // Load existing notifications from Firestore
      await _loadNotificationsFromFirestore();
      print('🔔 Notifications loaded from Firestore');
      
      // Listen to Firestore changes for real-time updates
      _listenToFirestoreChanges();
      print('🔔 Firestore listener started');
      
      debugPrint('Firebase notification data service initialized');
    } catch (e) {
      debugPrint('Error initializing Firebase notification data service: $e');
      // Create sample notifications as fallback
      _createSampleNotifications();
    }
  }

  Future<void> _setupFCMHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground FCM message: ${message.notification?.title}');
      _handleFCMMessage(message);
    });

    // Handle background messages when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from FCM message: ${message.notification?.title}');
      _handleFCMMessage(message, fromBackground: true);
    });

    // Handle notification when app is terminated and opened
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via FCM: ${initialMessage.notification?.title}');
      _handleFCMMessage(initialMessage, fromTerminated: true);
    }
  }

  void _handleFCMMessage(RemoteMessage message, {bool fromBackground = false, bool fromTerminated = false}) {
    try {
      final notification = _convertFCMToAppNotification(message);
      if (notification != null) {
        // Save to Firestore for persistence
        _saveNotificationToFirestore(notification);
        
        // Add to local list
        _addNotificationToList(notification);
      }
    } catch (e) {
      debugPrint('Error handling FCM message: $e');
    }
  }

  AppNotification? _convertFCMToAppNotification(RemoteMessage message) {
    try {
      final notification = message.notification;
      final data = message.data;
      
      if (notification == null) return null;

      // Determine notification type from data
      NotificationType type = NotificationType.system;
      if (data.containsKey('type')) {
        try {
          type = NotificationType.values.firstWhere(
            (t) => t.toString().split('.').last == data['type'],
            orElse: () => NotificationType.system,
          );
        } catch (e) {
          type = NotificationType.system;
        }
      }

      // Determine priority
      NotificationPriority priority = NotificationPriority.normal;
      if (data.containsKey('priority')) {
        try {
          priority = NotificationPriority.values.firstWhere(
            (p) => p.toString().split('.').last == data['priority'],
            orElse: () => NotificationPriority.normal,
          );
        } catch (e) {
          priority = NotificationPriority.normal;
        }
      }

      return AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'Notification',
        message: notification.body ?? '',
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        actionRoute: data['route'],
        metadata: data.isNotEmpty ? data : null,
      );
    } catch (e) {
      debugPrint('Error converting FCM message to AppNotification: $e');
      return null;
    }
  }

  Future<void> _loadNotificationsFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('🔔 No authenticated user, skipping Firestore notification load');
        return;
      }

      print('🔔 Loading notifications from Firestore for user: ${user.email}');

      // Try simple query first (without ordering to avoid index requirement)
      final QuerySnapshot snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => _firestoreDocToAppNotification(doc))
          .where((notification) => notification != null)
          .cast<AppNotification>()
          .toList();

      // Sort locally instead of in Firestore
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('🔔 Loaded ${_notifications.length} notifications from Firestore');
      _notificationsController.add(_notifications);
    } catch (e) {
      print('🔔 Error loading notifications from Firestore: $e');
      print('🔔 Creating sample notifications instead...');
      _createSampleNotifications();
    }
  }

  void _listenToFirestoreChanges() {
    final user = _auth.currentUser;
    if (user == null) {
      print('🔔 No user for Firestore listener, skipping');
      return;
    }

    print('🔔 Setting up Firestore listener for user: ${user.email}');

    try {
      _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .limit(50)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        try {
          _notifications = snapshot.docs
              .map((doc) => _firestoreDocToAppNotification(doc))
              .where((notification) => notification != null)
              .cast<AppNotification>()
              .toList();

          // Sort locally instead of in Firestore
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          print('🔔 Firestore listener: received ${_notifications.length} notifications');
          _notificationsController.add(_notifications);
        } catch (e) {
          print('🔔 Error processing Firestore snapshot: $e');
        }
      }, onError: (error) {
        print('🔔 Firestore listener error: $error');
        // Don't fail, just use sample notifications
        if (_notifications.isEmpty) {
          _createSampleNotifications();
        }
      });
    } catch (e) {
      print('🔔 Error setting up Firestore listener: $e');
      // Use sample notifications as fallback
      _createSampleNotifications();
    }
  }

  AppNotification? _firestoreDocToAppNotification(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      return AppNotification(
        id: doc.id,
        title: data['title'] ?? 'Notification',
        message: data['message'] ?? '',
        type: NotificationType.values.firstWhere(
          (t) => t.toString().split('.').last == data['type'],
          orElse: () => NotificationType.system,
        ),
        priority: NotificationPriority.values.firstWhere(
          (p) => p.toString().split('.').last == data['priority'],
          orElse: () => NotificationPriority.normal,
        ),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        isRead: data['isRead'] ?? false,
        actionRoute: data['actionRoute'],
        metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
      );
    } catch (e) {
      debugPrint('Error converting Firestore doc to AppNotification: $e');
      return null;
    }
  }

  Future<void> _saveNotificationToFirestore(AppNotification notification) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(_notificationsCollection).doc(notification.id).set({
        'userId': user.uid,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type.toString().split('.').last,
        'priority': notification.priority.toString().split('.').last,
        'createdAt': Timestamp.fromDate(notification.createdAt),
        'isRead': notification.isRead,
        'actionRoute': notification.actionRoute,
        'metadata': notification.metadata,
      });
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  void _addNotificationToList(AppNotification notification) {
    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }
    
    _notificationsController.add(_notifications);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update Firestore
      await _firestore.collection(_notificationsCollection).doc(notificationId).update({
        'isRead': true,
      });

      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notificationsController.add(_notifications);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get all unread notifications
      final unreadDocs = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Update all to read
      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Update local list
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _notificationsController.add(_notifications);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete from Firestore
      await _firestore.collection(_notificationsCollection).doc(notificationId).delete();

      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      _notificationsController.add(_notifications);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get all user notifications
      final userDocs = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Delete all
      final batch = _firestore.batch();
      for (final doc in userDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear local list
      _notifications.clear();
      _notificationsController.add(_notifications);
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionRoute,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        actionRoute: actionRoute,
        metadata: metadata,
      );

      await _saveNotificationToFirestore(notification);
      _addNotificationToList(notification);
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  void _createSampleNotifications() {
    print('🔔 Creating sample notifications for testing...');
    
    final sampleNotifications = [
      AppNotification(
        id: '1',
        title: 'Welcome to Sustaina Health!',
        message: 'Start your sustainable health journey today with personalized workouts and nutrition.',
        type: NotificationType.system,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        actionRoute: '/home',
      ),
      AppNotification(
        id: '2',
        title: 'Workout Reminder',
        message: 'Time for your daily workout! Let\'s stay active and healthy.',
        type: NotificationType.workout,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        actionRoute: '/workout',
      ),
      AppNotification(
        id: '3',
        title: 'Nutrition Tip',
        message: 'Remember to drink water! Stay hydrated for better health.',
        type: NotificationType.nutrition,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        actionRoute: '/nutrition',
      ),
      AppNotification(
        id: '4',
        title: 'Sleep Schedule',
        message: 'It\'s time to wind down. Good sleep is essential for recovery.',
        type: NotificationType.sleep,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        actionRoute: '/sleep',
      ),
      AppNotification(
        id: '5',
        title: 'Achievement Unlocked!',
        message: 'Congratulations! You completed 7 days of consistent workouts.',
        type: NotificationType.achievement,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        actionRoute: '/achievements',
      ),
    ];
    
    _notifications = sampleNotifications;
    _notificationsController.add(_notifications);
    print('🔔 Added ${_notifications.length} sample notifications');
  }

  void dispose() {
    _notificationsController.close();
  }
}
