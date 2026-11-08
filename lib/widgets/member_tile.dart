import 'package:flutter/material.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);
const Color pageColor = Color(0xFFF6F9F7);

class MemberTile extends StatelessWidget {
  final String name, place, status, battery;
  final IconData icon;
  const MemberTile({super.key, required this.name, required this.place, required this.status, required this.battery, required this.icon});

  @override
  Widget build(BuildContext context) {
    final online = status == 'Online';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(backgroundColor: paleGreen, child: Icon(icon, color: teal)),
      title: Row(children: [
        Flexible(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen))),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: online ? paleGreen : const Color(0xFFFFF0D8), borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(fontSize: 10, color: online ? teal : Colors.orange[800]))),
      ]),
      subtitle: Text('$place\nLokasi diperbarui 1 mnt lalu', style: const TextStyle(fontSize: 11, height: 1.5)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.battery_5_bar, size: 18, color: Colors.blueGrey),
        Text(battery, style: const TextStyle(fontSize: 10)),
      ]),
    );
  }
}