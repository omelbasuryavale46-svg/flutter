import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<Map<String, dynamic>> _membersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final list = await ApiService.getMembers();
    if (mounted) {
      setState(() {
        _membersList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Silakan login terlebih dahulu.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F7),
      appBar: AppBar(
        title: const Text('Kelola Anggota Keluarga'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ApiService.membersStream,
        initialData: _membersList,
        builder: (context, snapshot) {
          if (_isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(color: teal),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 70,
                      color: teal,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada anggota keluarga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tekan tombol di bawah untuk menambahkan anggota.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final memberData = data[index];
              final nama = memberData['name']?.toString() ?? 'Tanpa nama';
              final hubungan = memberData['place']?.toString() ?? 'Anggota keluarga';
              final id = memberData['id']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: paleGreen,
                    child: Icon(
                      Icons.person,
                      color: teal,
                    ),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(hubungan),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      final hapus = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Hapus anggota?'),
                            content: Text(
                              'Apakah kamu yakin ingin menghapus $nama?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (hapus == true && id.isNotEmpty) {
                        try {
                          await ApiService.deleteMember(id);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus anggota.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _tambahAnggota(context);
        },
        backgroundColor: teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah Anggota'),
      ),
    );
  }

  void _tambahAnggota(BuildContext context) {
    final namaController = TextEditingController();
    String hubungan = 'Anak';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Anggota Keluarga'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama anggota',
                        hintText: 'Masukkan nama',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: hubungan,
                      decoration: const InputDecoration(
                        labelText: 'Hubungan keluarga',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      items: [
                        'Ayah',
                        'Ibu',
                        'Anak',
                        'Kakak',
                        'Adik',
                        'Pasangan',
                        'Lainnya',
                      ].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            hubungan = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final nama = namaController.text.trim();

                    if (nama.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama anggota harus diisi.'),
                        ),
                      );
                      return;
                    }

                    try {
                      await ApiService.addMember(
                        name: nama,
                        place: hubungan,
                      );

                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan anggota: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      namaController.dispose();
    });
  }
}
