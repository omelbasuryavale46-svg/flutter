import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'add_friend_page.dart';

class ManagePermissionsPage extends StatefulWidget {
  const ManagePermissionsPage({super.key});

  @override
  State<ManagePermissionsPage> createState() => _ManagePermissionsPageState();
}

class _ManagePermissionsPageState extends State<ManagePermissionsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _permissions = [];
  String _activeFilter = 'Semua'; // 'Semua', 'Aktif', 'Dihentikan'

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getFriendPermissions();
    if (mounted) {
      setState(() {
        _permissions = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePermission(String id, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'paused' : 'active';
    try {
      await ApiService.toggleFriendPermission(id, newStatus);
      _loadPermissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'active'
                ? 'Izin berbagi lokasi diaktifkan'
                : 'Izin berbagi lokasi dihentikan sementara'),
            duration: const Duration(seconds: 2),
            backgroundColor: newStatus == 'active' ? AppTheme.primary : const Color(0xFFD97706),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah izin: $e')),
        );
      }
    }
  }

  Future<void> _revokePermission(String id, String friendName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cabut Izin Pelacakan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Apakah kamu yakin ingin mencabut izin untuk $friendName? Teman tidak akan lagi dapat melihat lokasimu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cabut Izin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.revokeFriendPermission(id);
        _loadPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Izin untuk $friendName berhasil dicabut')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mencabut izin: $e')),
          );
        }
      }
    }
  }

  Future<void> _changeDuration(String id, String currentDuration) async {
    final durations = ['Selalu aktif', 'Hingga akhir hari', '24 Jam', '1 Jam'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Durasi Berbagi Lokasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...durations.map((d) {
                  final isSelected = d == currentDuration;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    title: Text(
                      d,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, d),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != currentDuration) {
      try {
        await ApiService.updateFriendPermissionDuration(id, selected);
        _loadPermissions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui durasi: $e')),
          );
        }
      }
    }
  }

  Future<void> _togglePauseAll(bool currentAllPaused) async {
    try {
      if (currentAllPaused) {
        await ApiService.resumeAllFriendPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berbagi lokasi aktif kembali'), backgroundColor: AppTheme.primary),
          );
        }
      } else {
        await ApiService.pauseAllFriendPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua pelacakan teman telah dijeda'), backgroundColor: Color(0xFFD97706)),
          );
        }
      }
      _loadPermissions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _permissions.where((p) => p['status'] == 'active').length;
    final allPaused = _permissions.isNotEmpty && activeCount == 0;

    final filtered = _permissions.where((p) {
      if (_activeFilter == 'Aktif') return p['status'] == 'active';
      if (_activeFilter == 'Dihentikan') return p['status'] != 'active';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kelola izin teman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Daftar teman yang dapat melacak lokasimu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined, color: AppTheme.primary),
                    tooltip: 'Tambah Teman',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddFriendPage()),
                      );
                      _loadPermissions();
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : RefreshIndicator(
                      onRefresh: _loadPermissions,
                      color: AppTheme.primary,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        children: [
                          // Active Summary Hero Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                      child: const Icon(
                                        Icons.verified_user_outlined,
                                        color: AppTheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$activeCount Teman Aktif Melacak',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            activeCount > 0
                                                ? 'Lokasi hanya dibagikan saat izin aktif'
                                                : 'Tidak ada teman yang sedang melacak lokasimu',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: Color(0xFFEEF3F0), height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.pause_circle_outline, size: 18, color: AppTheme.textSecondary),
                                        SizedBox(width: 8),
                                        Text(
                                          'Jeda semua pelacakan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: allPaused,
                                      activeThumbColor: const Color(0xFFD97706),
                                      activeTrackColor: const Color(0xFFFDE68A),
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: const Color(0xFFD1DCD6),
                                      onChanged: (val) => _togglePauseAll(allPaused),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Filter Chips
                          Row(
                            children: ['Semua', 'Aktif', 'Dihentikan'].map((f) {
                              final isSelected = _activeFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(f),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setState(() => _activeFilter = f);
                                  },
                                  selectedColor: AppTheme.primary,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primary : const Color(0xFFE5EDE8),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 14),

                          // Friend Permissions List
                          if (filtered.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE5EDE8)),
                              ),
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(Icons.shield_outlined, size: 40, color: AppTheme.textSecondary),
                                    SizedBox(height: 10),
                                    Text(
                                      'Tidak ada izin dengan filter ini',
                                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filtered.map((perm) {
                              final id = perm['id']?.toString() ?? '';
                              final name = perm['friendName'] ?? 'Teman';
                              final code = perm['friendCode'] ?? 'FT-0000';
                              final avatar = perm['avatarText'] ?? 'TM';
                              final status = perm['status'] ?? 'active';
                              final duration = perm['sharingDuration'] ?? 'Selalu aktif';
                              final lastSeen = perm['lastAccessed'] ?? 'Baru saja';
                              final isActive = status == 'active';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isActive
                                        ? const Color(0xFFCCE8DB)
                                        : const Color(0xFFE5EDE8),
                                  ),
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
                                    // Row 1: Avatar, Name, Code, and Status Badge
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isActive ? AppTheme.accentMint : const Color(0xFFF1F5F3),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            avatar,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
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
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                code,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStatusBadge(status),
                                      ],
                                    ),

                                    const SizedBox(height: 14),
                                    const Divider(color: Color(0xFFF4F7F5), height: 1),
                                    const SizedBox(height: 10),

                                    // Row 2: Sharing duration and last accessed
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: isActive ? () => _changeDuration(id, duration) : null,
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                                                const SizedBox(width: 6),
                                                Text(
                                                  duration,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                                                  ),
                                                ),
                                                if (isActive) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primary),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.history, size: 14, color: AppTheme.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Akses: $lastSeen',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Row 3: Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _togglePermission(id, status),
                                            icon: Icon(
                                              isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                              size: 16,
                                              color: isActive ? AppTheme.primary : Colors.white,
                                            ),
                                            label: Text(
                                              isActive ? 'Hentikan Akses' : 'Aktifkan Kembali',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? AppTheme.primary : Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isActive ? AppTheme.accentMint : AppTheme.primary,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 20),
                                          tooltip: 'Cabut Izin',
                                          onPressed: () => _revokePermission(id, name),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const SizedBox(height: 12),

                          // Privacy Notice Info Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.accentMint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(Icons.lock_outline, size: 18, color: AppTheme.primary),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Privasi terkendali penuh: Teman tidak akan dapat melihat lokasimu jika izin berstatus dihentikan atau dicabut.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textPrimary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'active') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF2E7D32)),
            SizedBox(width: 6),
            Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'paused') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(radius: 3.5, backgroundColor: Color(0xFFD97706)),
            SizedBox(width: 6),
            Text(
              'Dijeda',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: const Text(
          'Dicabut',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC62828),
          ),
        ),
      );
    }
  }
}
