import 'package:flutter/material.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);
const Color pageColor = Color(0xFFF6F9F7);

class NoticeTile extends StatelessWidget {
  final IconData icon;
  final String title, detail, time;
  const NoticeTile({super.key, required this.icon, required this.title, required this.detail, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE1EAE5))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: const Color(0xFFFFF0D8), child: Icon(icon, color: teal, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen)),
          const SizedBox(height: 5),
          Text(detail, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.4)),
          const SizedBox(height: 7),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
        ])),
      ]),
    );
  }
}