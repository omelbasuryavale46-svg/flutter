import 'package:flutter/material.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);
const Color pageColor = Color(0xFFF6F9F7);

class DeviceTile extends StatelessWidget {
  final String name, code, owner, battery;
  final bool online;
  final IconData icon;
  const DeviceTile({super.key, required this.name, required this.code, required this.owner, required this.battery, required this.online, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE1EAE5))),
      child: Column(children: [
        Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: pageColor, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: teal, size: 30)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen)),
            const SizedBox(height: 4),
            Text(code, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
            Text(owner, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ])),
          const Icon(Icons.battery_5_bar, color: teal, size: 17),
          Text(battery, style: const TextStyle(fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: online ? paleGreen : const Color(0xFFFFF0D8), borderRadius: BorderRadius.circular(12)),
            child: Text(online ? '● Online' : '● Offline', style: TextStyle(fontSize: 10, color: online ? teal : Colors.orange[800]))),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.blueGrey),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: int.parse(battery.replaceAll('%', '')) / 100, minHeight: 4, backgroundColor: const Color(0xFFE5ECE8), color: teal)),
      ]),
    );
  }
}