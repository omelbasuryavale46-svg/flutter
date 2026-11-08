import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppUser {
  final String uid;
  final String name;
  final String familyName;
  final String email;
  final String uniqueId;

  AppUser({
    required this.uid,
    required this.name,
    required this.familyName,
    required this.email,
    String? uniqueId,
  }) : uniqueId = uniqueId ?? _computeUniqueId(uid, name);

  static String _computeUniqueId(String uid, String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('alina') || uid.contains('1028')) return 'FT-1028';
    if (lowerName.contains('bima') || uid.contains('2841')) return 'FT-2841';
    if (lowerName.contains('maya') || uid.contains('3916')) return 'FT-3916';
    if (lowerName.contains('raka') || uid.contains('5702')) return 'FT-5702';

    if (uid.startsWith('usr_')) {
      final hexPart = uid.substring(4).replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
      if (hexPart.length >= 4) {
        return 'FT-${hexPart.substring(0, 4).toUpperCase()}';
      }
    }

    final clean = uid.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (clean.length >= 4) {
      return 'FT-${clean.substring(0, 4).toUpperCase()}';
    }
    final hash = (name.hashCode.abs() % 9000 + 1000).toString();
    return 'FT-$hash';
  }

  String get userCode => uniqueId;

  static int min(int a, int b) => a < b ? a : b;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
    return 'AP';
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final uid = json['uid']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Alina Putri';
    final parsedUniqueId = json['uniqueId']?.toString() ??
        json['userCode']?.toString() ??
        json['unique_id']?.toString();

    return AppUser(
      uid: uid,
      name: name,
      familyName: json['familyName']?.toString() ?? 'Keluarga $name',
      email: json['email']?.toString() ?? 'alina.putri@email.com',
      uniqueId: parsedUniqueId,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'familyName': familyName,
    'email': email,
    'uniqueId': uniqueId,
  };
}

class ApiService { 
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:6969';
    }
    // Android Emulator menggunakan 10.0.2.2 untuk mengakses localhost PC.
    // Jika menggunakan HP Fisik via WiFi, ganti dengan IP laptop Anda (contoh: 'http://192.168.1.10:6969')
    return 'http://10.0.2.2:6969';
  }

  static final ValueNotifier<AppUser?> currentUserNotifier = ValueNotifier<AppUser?>(
    AppUser(
      uid: 'usr_6b02f57c50d0a57a7e77',
      name: 'Alina Putri',
      familyName: 'Keluarga Alina',
      email: 'alina.putri@email.com',
      uniqueId: 'FT-1028',
    ),
  );

  static AppUser? get currentUser => currentUserNotifier.value;
  static set currentUser(AppUser? user) => currentUserNotifier.value = user;

  static final StreamController<List<Map<String, dynamic>>> _devicesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  static Stream<List<Map<String, dynamic>>> get devicesStream => _devicesController.stream;

  static final StreamController<List<Map<String, dynamic>>> _notifsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  static Stream<List<Map<String, dynamic>>> get notificationsStream => _notifsController.stream;

  static final StreamController<Map<String, dynamic>> _tripsController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get tripsStream => _tripsController.stream;

  static Stream<List<Map<String, dynamic>>> get membersStream => devicesStream;

  static Future<void> addNotification({
    required String title,
    required String message,
    String type = 'info',
    String? memberId,
    String? status,
  }) async {
    final list = await getNotifications();
    list.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'status': status ?? 'info',
      'createdAt': 'Baru saja',
    });
    _notifsController.add(list);
  }

  static Future<List<Map<String, dynamic>>> getMembers() async {
    return getDevices();
  }

  static Future<void> deleteMember(String id) async {
    await getDevices();
  }

  static Future<void> addMember({
    required String name,
    String? place,
    String? role,
    String? relationship,
  }) async {
    await addDevice(
      name: name,
      deviceCode: 'MBR-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
  }

  // === AUTHENTICATION ===

  static Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth.php?action=register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['status'] == 'success') {
      final user = AppUser.fromJson(data['data']);
      currentUser = user;
      await refreshAll();
      return user;
    } else {
      throw Exception(data['message'] ?? 'Gagal mendaftar');
    }
  }

  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth.php?action=login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      final user = AppUser.fromJson(data['data']);
      currentUser = user;
      await refreshAll();
      return user;
    } else {
      throw Exception(data['message'] ?? 'Email atau kata sandi salah');
    }
  }

  static void logout() {
    currentUser = null;
    _devicesController.add([]);
    _notifsController.add([]);
  }

  // === DEVICES ===

  static Future<List<Map<String, dynamic>>> getDevices() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/devices.php?user_id=$uid');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final list = List<Map<String, dynamic>>.from(data['data']);
          _devicesController.add(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error getDevices: $e');
    }
    return [];
  }

  static Future<void> addDevice({
    required String name,
    required String deviceCode,
    String deviceType = 'car',
    String subtitle = '',
    String location = 'Jakarta Pusat',
    int battery = 100,
  }) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/devices.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'deviceCode': deviceCode,
        'deviceType': deviceType,
        'subtitle': subtitle.isNotEmpty ? subtitle : deviceCode,
        'location': location,
        'battery': battery,
        'status': 'online',
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getDevices();
    } else {
      throw Exception(data['message'] ?? 'Gagal menambahkan perangkat');
    }
  }

  static Future<void> pairDemoDevice() async {
    await addDevice(
      name: 'Gelang Anak',
      deviceCode: 'TRK-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
  }

  // === TRIPS (RIWAYAT) ===

  static Future<Map<String, dynamic>> getTrips() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/trips.php?user_id=$uid');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final map = Map<String, dynamic>.from(data['data']);
          _tripsController.add(map);
          return map;
        }
      }
    } catch (e) {
      debugPrint('Error getTrips: $e');
    }
    return {
      'summary': {'totalDistance': '24,6 km', 'movingTime': '1 j 18 m', 'tripCount': 3},
      'trips': []
    };
  }

  // === NOTIFICATIONS ===

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/notifications.php?user_id=$uid');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final list = List<Map<String, dynamic>>.from(data['data']);
          _notifsController.add(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error getNotifications: $e');
    }
    return [];
  }

  static Future<void> respondNotificationRequest(String notifId, String status) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/notifications.php?user_id=$uid');
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'action': 'respond_request',
        'id': notifId,
        'status': status,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getNotifications();
    } else {
      throw Exception(data['message'] ?? 'Gagal menanggapi izin');
    }
  }

  // === FRIENDS SEARCH ===

  static Future<Map<String, dynamic>> searchFriend(String query) async {
    final url = Uri.parse('$baseUrl/friends.php?action=search&q=${Uri.encodeComponent(query)}');
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      return Map<String, dynamic>.from(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Teman tidak ditemukan');
    }
  }

  static Future<void> sendTrackingRequest(String targetId) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/friends.php?action=request');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'userId': uid,
        'targetId': targetId,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 || data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Gagal mengirim permintaan');
    }
  }

  // === KELOLA IZIN TEMAN (FRIEND PERMISSIONS) ===

  static final ValueNotifier<int> activePermissionsNotifier = ValueNotifier<int>(1);

  static Future<List<Map<String, dynamic>>> getFriendPermissions() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success' && body['data'] != null) {
          final count = body['data']['activeCount'] as int? ?? 0;
          activePermissionsNotifier.value = count;
          final list = (body['data']['permissions'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [];
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error getFriendPermissions: $e');
    }
    return [];
  }

  static Future<void> toggleFriendPermission(String permissionId, String newStatus) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'action': 'toggle',
        'id': permissionId,
        'status': newStatus,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getFriendPermissions();
    } else {
      throw Exception(data['message'] ?? 'Gagal mengubah status izin');
    }
  }

  static Future<void> revokeFriendPermission(String permissionId) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'action': 'revoke',
        'id': permissionId,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getFriendPermissions();
    } else {
      throw Exception(data['message'] ?? 'Gagal mencabut izin');
    }
  }

  static Future<void> updateFriendPermissionDuration(String permissionId, String duration) async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'action': 'update_duration',
        'id': permissionId,
        'duration': duration,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getFriendPermissions();
    } else {
      throw Exception(data['message'] ?? 'Gagal memperbarui durasi');
    }
  }

  static Future<void> pauseAllFriendPermissions() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'action': 'pause_all'}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getFriendPermissions();
    } else {
      throw Exception(data['message'] ?? 'Gagal menjeda izin');
    }
  }

  static Future<void> resumeAllFriendPermissions() async {
    final user = currentUser;
    final uid = user?.uid ?? 'usr_6b02f57c50d0a57a7e77';

    final url = Uri.parse('$baseUrl/permissions.php?user_id=$uid');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'action': 'resume_all'}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      await getFriendPermissions();
    } else {
      throw Exception(data['message'] ?? 'Gagal mengaktifkan izin');
    }
  }

  static Future<void> refreshAll() async {
    await Future.wait([
      getDevices(),
      getTrips(),
      getNotifications(),
      getFriendPermissions(),
    ]);
  }
}
