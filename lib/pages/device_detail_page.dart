import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class DeviceDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late Map<String, dynamic> _device;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _device = Map<String, dynamic>.from(widget.device);
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    final freshDevices = await ApiService.getDevices();
    final found = freshDevices.firstWhere(
      (d) => d['id'] == _device['id'] || d['name'] == _device['name'],
      orElse: () => _device,
    );
    if (mounted) {
      setState(() {
        _device = Map<String, dynamic>.from(found);
        _isRefreshing = false;
      });
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motor':
      case 'motorcycle':
        return Icons.two_wheeler_rounded;
      case 'tas':
      case 'bag':
        return Icons.backpack_outlined;
      case 'koper':
      case 'luggage':
        return Icons.business_center_outlined;
      case 'mobil':
      case 'car':
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _device['name'] ?? 'Mobil Ayah';
    final subtitle = _device['subtitle'] ?? _device['deviceCode'] ?? 'B 2841 SJK · GPS kendaraan';
    final deviceType = _device['device_type'] ?? 'mobil';
    final isOnline = (_device['status'] ?? 'connected') == 'connected';
    final location = _device['location'] ?? 'Jl. Cikini Raya No. 24, Menteng, Jakarta Pusat, DKI Jakarta';
    final timeAgo = _device['time_ago'] ?? '5 detik lalu';
    final battery = _device['battery'] ?? 82;
    final speed = _device['speed'] ?? (isOnline ? '32 km/j' : '0 km/j');
    final motionStatus = isOnline ? 'Bergerak' : 'Berhenti';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Detail perangkat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Informasi lokasi dan kondisi',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, color: AppTheme.textPrimary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pengaturan untuk $name')),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map illustration container
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFEFF5F2),
              child: Stack(
                children: [
                  // Vector map stylized grid
                  CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: _DetailMapPainter(),
                  ),
                  // Accuracy chip on top-left
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.gps_fixed, size: 14, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Text(
                            'Akurasi ±5 m',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expand button top-right
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.fullscreen, size: 20, color: AppTheme.textPrimary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Layar penuh peta')),
                          );
                        },
                      ),
                    ),
                  ),
                  // Animated radar ripple and center vehicle marker
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.12),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getDeviceIcon(deviceType),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Street captions
                  Positioned(
                    bottom: 10,
                    left: 14,
                    child: Text(
                      '200 m\nJl. Diponegoro',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blueGrey.shade400,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 14,
                    child: Text(
                      'Peta ilustratif',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Detail Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accentMint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getDeviceIcon(deviceType),
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isOnline ? AppTheme.accentMint : const Color(0xFFF1F5F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? AppTheme.primary : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOnline ? AppTheme.primary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location section
                  const Text(
                    'LOKASI SAAT INI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _refresh,
                    child: Row(
                      children: [
                        _isRefreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                size: 15,
                                color: AppTheme.primary,
                              ),
                        const SizedBox(width: 6),
                        Text(
                          'Diperbarui $timeAgo · 09.41 WIB',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3-Column Metrics Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5ECEB)),
                    ),
                    child: Row(
                      children: [
                        // Battery
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.battery_charging_full, size: 18, color: AppTheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                '$battery%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Baterai',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 42, color: const Color(0xFFE5ECEB)),
                        const SizedBox(width: 12),

                        // Speed
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.speed, size: 18, color: AppTheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                speed.toString(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Kecepatan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 42, color: const Color(0xFFE5ECEB)),
                        const SizedBox(width: 12),

                        // Motion status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.navigation_outlined, size: 18, color: AppTheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                motionStatus,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Status gerak',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Safe Zone Tile
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5ECEB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.accentMint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user_outlined, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Zona aman aktif',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Dalam area Jakarta · Radius 15 km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      // Direction button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Membuka petunjuk arah ke $location')),
                            );
                          },
                          icon: const Icon(Icons.navigation, size: 16, color: Colors.white),
                          label: const Text(
                            'Petunjuk arah',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Share location button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tautan lokasi $name disalin ke clipboard')),
                            );
                          },
                          icon: const Icon(Icons.share_outlined, size: 16, color: AppTheme.primary),
                          label: const Text(
                            'Bagikan lokasi',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentMint,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F6F4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()..color = const Color(0xFFE5EDE8);

    // City blocks
    final blocks = [
      Rect.fromLTWH(20, 20, 90, 60),
      Rect.fromLTWH(130, 20, 100, 60),
      Rect.fromLTWH(20, 100, 90, 70),
      Rect.fromLTWH(130, 100, 100, 70),
      Rect.fromLTWH(250, 20, 90, 150),
    ];
    for (final b in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(8)), blockPaint);
    }

    // Green park
    final parkPaint = Paint()..color = const Color(0xFFD6E8DC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(130, 100, 70, 50), const Radius.circular(8)),
      parkPaint,
    );

    // River on right
    final riverPaint = Paint()
      ..color = const Color(0xFFD3E7F0)
      ..strokeWidth = 34
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(size.width - 20, 0);
    riverPath.cubicTo(size.width - 50, 70, size.width - 10, 140, size.width - 40, size.height);
    canvas.drawPath(riverPath, riverPaint);

    // Roads
    final roadPath = Path();
    roadPath.moveTo(0, 90);
    roadPath.lineTo(size.width, 90);
    roadPath.moveTo(120, 0);
    roadPath.lineTo(120, size.height);
    roadPath.moveTo(240, 0);
    roadPath.lineTo(240, size.height);
    canvas.drawPath(roadPath, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
