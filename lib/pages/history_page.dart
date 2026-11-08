import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, dynamic>? _tripsData;
  bool _isLoading = true;
  String _selectedDevice = 'Mobil Ayah';
  DateTime _selectedDate = DateTime(2026, 10, 5);
  int _expandedIndex = 0; // First trip expanded by default like in Figma

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final data = await ApiService.getTrips();
    if (mounted) {
      setState(() {
        _tripsData = data;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return 'Hari ini, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _tripsData?['summary'] as Map<String, dynamic>? ?? {
      'totalDistance': '24,6 km',
      'movingTime': '1 j 18 m',
      'tripCount': 3,
    };

    final tripsList = _tripsData?['trips'] as List<dynamic>? ?? [
      {
        'time_range': '08.15 – 08.47',
        'title': 'Rumah → Kantor',
        'distance': '8,4 km',
        'duration': '32 menit',
        'route_detail': 'Setiabudi → Jl. Cikini Raya, Menteng',
      },
      {
        'time_range': '07.02 – 07.20',
        'title': 'Sarapan → Rumah',
        'distance': '6,2 km',
        'duration': '18 menit',
        'route_detail': 'Menteng → Setiabudi',
      },
      {
        'time_range': '06.20 – 06.48',
        'title': 'Rumah → Sarapan',
        'distance': '10 km',
        'duration': '28 menit',
        'route_detail': 'Setiabudi → Menteng',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading && _tripsData == null
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Riwayat perjalanan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Setiap perjalanan, tercatat rapi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.download_outlined, color: AppTheme.textPrimary, size: 22),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mengekspor riwayat perjalanan...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Device selector dropdown row
                  Row(
                    children: [
                      const Icon(Icons.directions_car_filled, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDevice,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDevice = val);
                          },
                          items: const [
                            DropdownMenuItem(value: 'Mobil Ayah', child: Text('Mobil Ayah')),
                            DropdownMenuItem(value: 'Motor Kakak', child: Text('Motor Kakak')),
                            DropdownMenuItem(value: 'Tas Rani', child: Text('Tas Rani')),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Date navigator row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Route polyline map illustration
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 190,
                      color: const Color(0xFFEFF5F2),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 190),
                            painter: _RouteMapPainter(),
                          ),
                          // Route chip on top left
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Rute 08.15 – 08.47',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Captions
                          Positioned(
                            bottom: 8,
                            left: 12,
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
                            bottom: 8,
                            right: 12,
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
                  ),

                  const SizedBox(height: 18),

                  // 3-Metric Summary
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5ECEB)),
                    ),
                    child: Row(
                      children: [
                        // Distance
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.alt_route, size: 20, color: AppTheme.primary),
                              const SizedBox(height: 6),
                              Text(
                                summary['totalDistance']?.toString() ?? '24,6 km',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Total jarak',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 38, color: const Color(0xFFE5ECEB)),
                        const SizedBox(width: 14),

                        // Moving time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.access_time, size: 20, color: AppTheme.primary),
                              const SizedBox(height: 6),
                              Text(
                                summary['movingTime']?.toString() ?? '1 j 18 m',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Waktu bergerak',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 38, color: const Color(0xFFE5ECEB)),
                        const SizedBox(width: 14),

                        // Trip count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.navigation_outlined, size: 20, color: AppTheme.primary),
                              const SizedBox(height: 6),
                              Text(
                                summary['tripCount']?.toString() ?? '3',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Perjalanan',
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

                  const SizedBox(height: 20),

                  // List section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Perjalanan hari ini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Waktu WIB',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Trip items
                  ...tripsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trip = entry.value as Map<String, dynamic>;
                    final isExpanded = _expandedIndex == index;

                    final timeRange = trip['time_range'] ?? '08.15 – 08.47';
                    final title = trip['title'] ?? 'Rumah → Kantor';
                    final distance = trip['distance'] ?? '8,4 km';
                    final duration = trip['duration'] ?? '32 menit';
                    final routeDetail = trip['route_detail'] ?? 'Setiabudi → Jl. Cikini Raya, Menteng';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isExpanded ? const Color(0xFFF0FAF8) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded ? AppTheme.primary.withOpacity(0.5) : const Color(0xFFE5EDE8),
                              width: isExpanded ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dot indicator
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isExpanded ? AppTheme.primary : Colors.blueGrey.shade300,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          timeRange,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        distance,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        duration,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.chevron_right,
                                    color: isExpanded ? AppTheme.primary : AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                const Divider(color: Color(0xFFD6EAE6), height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        routeDetail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F6F4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()..color = const Color(0xFFE5EDE8);

    // City blocks
    final blocks = [
      Rect.fromLTWH(20, 20, 80, 50),
      Rect.fromLTWH(120, 20, 90, 50),
      Rect.fromLTWH(20, 90, 80, 60),
      Rect.fromLTWH(120, 90, 90, 60),
      Rect.fromLTWH(230, 20, 90, 130),
    ];
    for (final b in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(8)), blockPaint);
    }

    // River on right
    final riverPaint = Paint()
      ..color = const Color(0xFFD3E7F0)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(size.width - 20, 0);
    riverPath.cubicTo(size.width - 45, 60, size.width - 15, 120, size.width - 35, size.height);
    canvas.drawPath(riverPath, riverPaint);

    // Roads
    final roadPath = Path();
    roadPath.moveTo(0, 80);
    roadPath.lineTo(size.width, 80);
    roadPath.moveTo(110, 0);
    roadPath.lineTo(110, size.height);
    roadPath.moveTo(220, 0);
    roadPath.lineTo(220, size.height);
    canvas.drawPath(roadPath, roadPaint);

    // Cyan Route polyline matching Figma
    final routePaint = Paint()
      ..color = const Color(0xFF0097A7)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(90, 140);
    routePath.lineTo(90, 80);
    routePath.lineTo(180, 80);
    routePath.lineTo(180, 150);
    routePath.lineTo(260, 150);
    routePath.lineTo(260, 50);
    canvas.drawPath(routePath, routePaint);

    // Start circle dot
    final startPaint = Paint()..color = const Color(0xFF0097A7);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(90, 140), 6, startPaint);
    canvas.drawCircle(const Offset(90, 140), 3, whitePaint);

    // End circle dot
    canvas.drawCircle(const Offset(260, 50), 6, startPaint);

    // Vehicle icon pin at middle of path (180, 100)
    canvas.drawCircle(
      const Offset(180, 100),
      18,
      Paint()
        ..color = const Color(0xFF00838F)
        ..style = PaintingStyle.fill,
    );
    // Draw small white car glyph
    final iconPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(180, 100), width: 14, height: 10),
        const Radius.circular(2),
      ),
      iconPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
