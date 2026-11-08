import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F7),
      appBar: AppBar(
        title: const Text('Informasi Akun'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<AppUser?>(
        valueListenable: ApiService.currentUserNotifier,
        builder: (context, user, _) {
          if (user == null) {
            return const Center(
              child: Text('Silakan login terlebih dahulu.'),
            );
          }

          final nama = user.name.isNotEmpty ? user.name : 'Pengguna';
          final keluarga = user.familyName.isNotEmpty ? user.familyName : 'Keluarga';
          final email = user.email.isNotEmpty ? user.email : '-';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE7F3EE),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: teal,
                ),
              ),
              const SizedBox(height: 24),

              _infoItem(
                Icons.person_outline,
                'Nama pengguna',
                nama,
              ),
              _infoItem(
                Icons.people_outline,
                'Nama keluarga',
                keluarga,
              ),
              _infoItem(
                Icons.email_outlined,
                'Email',
                email,
              ),
              _infoItem(
                Icons.badge_outlined,
                'ID unik saya',
                user.userCode,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String judul,
    String isi,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Icon(icon, color: teal, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isi,
                  style: const TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
