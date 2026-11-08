
import 'package:flutter/material.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(
          icon,
          color: teal,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.blueGrey,
        ),
        onTap: onTap,
      ),
    );
  }
}
