import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'manage_permissions_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await ApiService.getNotifications();
    if (mounted) {
      setState(() {
        _notifsList = list;
        _isLoading = false;
      });
    }
  }

  void _showApprovalDialog(Map<String, dynamic> notif) {
    final friendName = notif['senderName'] ?? notif['friend_name'] ?? 'Teman';
    final subtitle = notif['subtitle']?.toString() ?? '';
    final codeMatch = RegExp(r'FT-\d+').firstMatch(subtitle);
    final friendId = notif['friend_code'] ?? codeMatch?.group(0) ?? (friendName.toString().toLowerCase().contains('bima') ? 'FT-2841' : 'FT-1028');
    final notifId = notif['id']?.toString() ?? '1';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header with Icon
                Row(
                  children: [
                    Image.asset(
                      'assets/locara_map.png',
                      width: 38,
                      height: 38,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'FriendTreking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Question headline
                Text(
                  'Izinkan $friendName melacak lokasimu?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tinjau siapa yang meminta akses sebelum kamu membagikan lokasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 16),

                // Target requester user card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5EDE8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accentMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          friendName.isNotEmpty
                              ? friendName.split(' ').map((e) => e[0]).take(2).join()
                              : 'BS',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friendName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              friendId,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Menunggu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Info Pin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi Alina Putri (FT-1028) hanya dibagikan kepada Bima setelah kamu memilih Setuju.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lock warning
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 16, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Saat ini lokasimu belum dibagikan.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons: Tidak setuju & Setuju
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await ApiService.respondNotificationRequest(notifId, 'rejected');
                          await ApiService.getFriendPermissions();
                          _loadNotifications();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Permintaan dari $friendName ditolak')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentMint,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tidak setuju',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await ApiService.respondNotificationRequest(notifId, 'approved');
                          await ApiService.getFriendPermissions();
                          _loadNotifications();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Permintaan dari $friendName disetujui!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Setuju',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Note footer
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManagePermissionsPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shield_outlined, size: 13, color: AppTheme.primary),
                          SizedBox(width: 5),
                          Text(
                            'Izin dapat dihentikan kapan saja: Profil → Kelola izin teman',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ApiService.notificationsStream,
      initialData: _notifsList,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? _notifsList;

        // Pending requests
        final pendingRequests = notifications.where((n) {
          final s = (n['status'] ?? '').toString().toLowerCase();
          return s == 'pending' || s == 'menunggu';
        }).toList();

        // History items
        final historyItems = notifications.where((n) {
          final s = (n['status'] ?? '').toString().toLowerCase();
          return s != 'pending' && s != 'menunggu';
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: _isLoading && notifications.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Header
                      Row(
                        children: [
                          if (Navigator.of(context).canPop())
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          if (Navigator.of(context).canPop()) const SizedBox(width: 12),
                          const Icon(Icons.notifications_none, size: 26, color: AppTheme.textPrimary),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Notifikasi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Semua permintaan izin, di satu tempat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Section: Permintaan masuk
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Permintaan masuk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (pendingRequests.isNotEmpty)
                            Text(
                              '${pendingRequests.length} perlu ditinjau',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (pendingRequests.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5EDE8)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle_outline, color: AppTheme.primary, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Tidak ada permintaan izin baru.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...pendingRequests.map((req) {
                          final friendName = req['senderName'] ?? req['friend_name'] ?? 'Teman';
                          final sub = req['subtitle']?.toString() ?? '';
                          final match = RegExp(r'FT-\d+').firstMatch(sub);
                          final friendId = req['friend_code'] ?? match?.group(0) ?? (friendName.toString().toLowerCase().contains('bima') ? 'FT-2841' : 'FT-1028');
                          final time = req['time_ago'] ?? (sub.contains('·') ? sub.split('·').last.trim() : 'Baru saja');
                          final desc = req['message'] ??
                              '$friendName ingin melacak lokasi kamu. Lokasimu belum dibagikan; menunggu persetujuanmu.';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE5EDE8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentMint,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        friendName.isNotEmpty
                                            ? friendName.split(' ').map((e) => e[0]).take(2).join()
                                            : 'BS',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friendName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$friendId · $time',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Menunggu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  desc,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showApprovalDialog(req),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Tinjau permintaan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 16),

                      // Section: Riwayat izin
                      const Text(
                        'Riwayat izin',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (historyItems.isEmpty) ...[
                        // Default demo history if none in DB
                        _buildHistoryCard(
                          name: 'Maya Lestari',
                          code: 'FT-3916',
                          time: 'Kemarin',
                          status: 'Disetujui',
                          desc: 'Kamu menyetujui permintaan Maya. Izin telah kamu hentikan; lokasi tidak lagi dibagikan.',
                          isApproved: true,
                        ),
                        _buildHistoryCard(
                          name: 'Raka Pratama',
                          code: 'FT-5702',
                          time: 'Kemarin',
                          status: 'Ditolak',
                          desc: 'Kamu menolak permintaan Raka. Raka tidak dapat melihat lokasi kamu.',
                          isApproved: false,
                        ),
                      ] else
                        ...historyItems.map((item) {
                          final name = item['friend_name'] ?? 'Teman';
                          final code = item['friend_code'] ?? 'FT-0000';
                          final time = item['time_ago'] ?? 'Kemarin';
                          final status = (item['status'] ?? '').toString();
                          final isApproved = status.toLowerCase() == 'approved' || status.toLowerCase() == 'disetujui';
                          final desc = item['message'] ??
                              (isApproved
                                  ? 'Kamu menyetujui permintaan $name. Izin telah kamu hentikan; lokasi tidak lagi dibagikan.'
                                  : 'Kamu menolak permintaan $name. $name tidak dapat melihat lokasi kamu.');

                          return _buildHistoryCard(
                            name: name,
                            code: code,
                            time: time,
                            status: isApproved ? 'Disetujui' : 'Ditolak',
                            desc: desc,
                            isApproved: isApproved,
                          );
                        }),

                      const SizedBox(height: 14),

                      // Tip box: Kamu yang menentukan
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.accentMint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Kamu yang menentukan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Izin hanya berlaku untuk teman yang disetujui dan dapat dihentikan kapan saja.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard({
    required String name,
    required String code,
    required String time,
    required String status,
    required String desc,
    required bool isApproved,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isApproved ? AppTheme.accentMint : const Color(0xFFF1F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join() : 'ML',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isApproved ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$code · $time',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved ? AppTheme.accentMint : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isApproved ? AppTheme.primary : const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
