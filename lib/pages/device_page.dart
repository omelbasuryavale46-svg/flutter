import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'add_device_page.dart';
import 'device_detail_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<Map<String, dynamic>> _devicesList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final list = await ApiService.getDevices();
    if (mounted) {
      setState(() {
        _devicesList = list;
        _isLoading = false;
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ApiService.devicesStream,
      initialData: _devicesList,
      builder: (context, snapshot) {
        final devices = snapshot.data ?? _devicesList;
        final totalCount = devices.length;
        final onlineCount = devices.where((d) => (d['status'] ?? '') == 'connected').length;
        final offlineCount = totalCount - onlineCount;

        // Apply filter and search query
        final filteredDevices = devices.where((d) {
          final isOnline = (d['status'] ?? '') == 'connected';
          if (_selectedFilter == 'Online' && !isOnline) return false;
          if (_selectedFilter == 'Offline' && isOnline) return false;

          if (_searchQuery.isNotEmpty) {
            final name = (d['name'] ?? '').toString().toLowerCase();
            final sub = (d['subtitle'] ?? '').toString().toLowerCase();
            final loc = (d['location'] ?? '').toString().toLowerCase();
            final q = _searchQuery.toLowerCase();
            if (!name.contains(q) && !sub.contains(q) && !loc.contains(q)) {
              return false;
            }
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perangkat',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$totalCount perangkat terhubung dengan Anda',
                          style: const TextStyle(
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
                        icon: const Icon(Icons.add, color: AppTheme.textPrimary, size: 22),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddDevicePage()),
                          );
                          _loadDevices();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EBE9)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama perangkat',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Filter pills: Semua, Online, Offline
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'Semua $totalCount'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Online', 'Online $onlineCount'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Offline', 'Offline $offlineCount'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Device Cards List
                if (_isLoading && devices.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (filteredDevices.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5EDE8)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.search_off, size: 40, color: AppTheme.textSecondary),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada perangkat ditemukan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredDevices.map((device) {
                    final name = device['name'] ?? 'Perangkat';
                    final subtitle = device['subtitle'] ?? device['deviceCode'] ?? '-';
                    final location = device['location'] ?? 'Jakarta Pusat';
                    final battery = device['battery'] ?? 0;
                    final isOnline = (device['status'] ?? '') == 'connected';
                    final deviceType = device['device_type'] ?? 'mobil';
                    final timeAgo = device['time_ago'] ?? (isOnline ? '5 detik lalu' : '2 jam lalu');
                    final motionStatus = isOnline ? (battery > 70 ? 'Bergerak' : 'Berhenti') : 'Lokasi terakhir';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeviceDetailPage(device: device),
                              ),
                            );
                            _loadDevices();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE6EEEC)),
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
                                // Top row: Icon + Names + Status chip + Arrow
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isOnline ? AppTheme.accentMint : const Color(0xFFF1F5F8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getDeviceIcon(deviceType),
                                        color: isOnline ? AppTheme.primary : AppTheme.textSecondary,
                                        size: 24,
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
                                            subtitle,
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
                                        color: isOnline ? AppTheme.accentMint : const Color(0xFFF1F5F8),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isOnline ? AppTheme.primary : AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            isOnline ? 'Online' : 'Offline',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isOnline ? AppTheme.primary : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFFB0BEC5),
                                      size: 18,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Location text
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.textSecondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Battery and time ago
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isOnline ? Icons.battery_charging_full : Icons.battery_alert,
                                          size: 15,
                                          color: !isOnline && battery < 20 ? Colors.orange.shade700 : AppTheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$battery% · $motionStatus',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: !isOnline && battery < 20
                                                ? Colors.orange.shade800
                                                : AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      timeAgo,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 8),

                // Footer security reassurance
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, size: 14, color: AppTheme.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'Lokasi hanya dibagikan kepada Anda',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
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

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE2EBE9),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
