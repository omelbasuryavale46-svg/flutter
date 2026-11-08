import 'dart:async';
import 'api_service.dart';

class StatusNotificationService {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  final Map<String, String> _lastStatus = {};
  bool _firstSnapshot = true;

  void start() {
    final user = ApiService.currentUser;
    if (user == null || _subscription != null) return;

    _subscription = ApiService.membersStream.listen((members) async {
      if (_firstSnapshot) {
        for (final member in members) {
          final id = member['id']?.toString() ?? '';
          if (id.isNotEmpty) {
            _lastStatus[id] = (member['status'] ?? 'offline').toString();
          }
        }
        _firstSnapshot = false;
        return;
      }

      for (final member in members) {
        final id = member['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final newStatus = (member['status'] ?? 'offline').toString();
        final oldStatus = _lastStatus[id];
        final name = (member['name'] ?? 'Anggota').toString();

        _lastStatus[id] = newStatus;

        if (oldStatus == null ||
            oldStatus == newStatus ||
            (newStatus != 'online' && newStatus != 'offline')) {
          continue;
        }

        await ApiService.addNotification(
          title: newStatus == 'online'
              ? 'Anggota online'
              : 'Anggota offline',
          message: '$name sekarang $newStatus',
          type: 'status',
          memberId: id,
          status: newStatus,
        );
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _lastStatus.clear();
    _firstSnapshot = true;
  }
}
