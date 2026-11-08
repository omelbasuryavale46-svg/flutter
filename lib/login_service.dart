import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  // CATATAN PENTING MENGENAI URL:
  // - Jika pakai Emulator Android bawaan: gunakan "http://10.0.2.2/api_flutter/login.php"
  // - Jika pakai HP fisik (terhubung WiFi sama): gunakan IP Laptop (contoh: "http://192.168.1.5/api_flutter/login.php")
  final String url = "http://10.0.2.2/api_flutter/login.php";

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print("Login Berhasil: ${data['data']['name']}");
        } else {
          print("Gagal: ${data['message']}");
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }
}