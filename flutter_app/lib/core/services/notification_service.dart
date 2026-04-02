import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final DateTime sentAt;
  bool delivered;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    required this.sentAt,
    this.delivered = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type']?.toString(),
      sentAt: DateTime.parse(map['sent_at'] ?? DateTime.now().toIso8601String()),
      delivered: map['delivered'] ?? false,
    );
  }
}

class NotificationService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;
  bool _isLoading = false;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.delivered).length;
  bool get isLoading => _isLoading;

  NotificationService() {
    _initRealtime();
  }

  void _initRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _subscription?.cancel();
    _subscription = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('sent_at', ascending: false)
        .listen((data) {
          _notifications = data.map((n) => NotificationModel.fromMap(n)).toList();
          notifyListeners();
        });
  }

  Future<void> fetchNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('sent_at', ascending: false);
      
      _notifications = (response as List).map((n) => NotificationModel.fromMap(n)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'delivered': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void logEvent(String role, String event, String details) {
    debugPrint('EVENT LOG [$role]: $event - $details');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
