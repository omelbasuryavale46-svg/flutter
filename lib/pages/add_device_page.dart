import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);
const Color pageColor = Color(0xFFF6F9F7);

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    final list = await ApiService.getDevices();
    if (mounted) {
      setState(() {
        _devices = list;
      });
    }
  }

  Future<void> pasangkanPerangkat(BuildContext context) async {
    final user = ApiService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    try {
      await ApiService.pairDemoDevice();
      await _fetchDevices();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perangkat simulasi berhasil dipasangkan'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perangkat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah perangkat')),
        body: const Center(
          child: Text('Silakan login terlebih dahulu'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah perangkat'),
        backgroundColor: pageColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const LinearProgressIndicator(
            value: .66,
            color: teal,
            backgroundColor: paleGreen,
          ),
          const SizedBox(height: 28),
          const Text(
            'Hubungkan liontin Anda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ini adalah perangkat simulasi untuk mencoba fitur Locara '
            'tanpa alat fisik.',
            style: TextStyle(color: Colors.blueGrey, height: 1.5),
          ),
          const SizedBox(height: 22),
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: paleGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.watch,
                  size: 60,
                  color: teal,
                ),
                SizedBox(height: 12),
                Text(
                  'Liontin Locara LC-2190',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mode simulasi aktif',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ApiService.devicesStream,
            initialData: _devices,
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final demoDevice = list.cast<Map<String, dynamic>?>().firstWhere(
                (d) => d?['deviceKey'] == 'liontin_demo',
                orElse: () => null,
              );

              final connected = demoDevice != null && demoDevice['status'] == 'connected';
              final battery = demoDevice?['battery'] ?? 96;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: teal),
                ),
                child: Row(
                  children: [
                    Icon(
                      connected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth,
                      color: teal,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liontin Locara',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                          Text(
                            'LC-2190 · Baterai $battery%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            connected
                                ? 'Perangkat simulasi aktif'
                                : 'Belum dipasangkan',
                            style: const TextStyle(
                              fontSize: 11,
                              color: teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      connected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: teal,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: teal,
              ),
              onPressed: () => pasangkanPerangkat(context),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Pasangkan perangkat simulasi'),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Tidak memerlukan alat Bluetooth asli',
              style: TextStyle(color: teal, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
