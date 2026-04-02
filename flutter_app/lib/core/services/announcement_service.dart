import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_models.dart';
import 'dart:async';

class AnnouncementService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  StreamSubscription? _announcementsSubscription;

  List<Announcement> get announcements => List.unmodifiable(_announcements);
  bool get isLoading => _isLoading;

  AnnouncementService() {
    _initRealtime();
    fetchAnnouncements();
  }

  void _initRealtime() {
    _announcementsSubscription = _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
      _announcements = data.map((map) => Announcement.fromMap(map)).toList();
      notifyListeners();
    });
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
      _announcements = (response as List).map((map) => Announcement.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _announcementsSubscription?.cancel();
    super.dispose();
  }
}
