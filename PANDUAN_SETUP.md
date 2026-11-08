# 📖 Panduan Lengkap Menjalankan Backend API & Flutter (Locara App)

Dokumen ini menjelaskan langkah-langkah untuk menyiapkan database, menjalankan backend API PHP, menjalankan aplikasi Flutter di berbagai platform (Web, Android Emulator, dan HP Fisik), serta daftar konfigurasi yang perlu disesuaikan.

---

## 📋 Daftar Isi
1. [Prasyarat Sistem](#1-prasyarat-sistem)
2. [Menjalankan Backend API (PHP & MySQL)](#2-menjalankan-backend-api-php--mysql)
3. [Menjalankan Aplikasi Flutter](#3-menjalankan-aplikasi-flutter)
4. [Hal yang Perlu Dikonfigurasi Ulang (Checklist Konfigurasi)](#4-hal-yang-perlu-dikonfigurasi-ulang-checklist-konfigurasi)
5. [Troubleshooting & Solusi Error Umum](#5-troubleshooting--solusi-error-umum)

---

## 1. Prasyarat Sistem
Pastikan komponen berikut sudah terinstal di komputer/laptop:
- **PHP** (minimal versi 8.0, ekstensi `pdo_mysql` aktif).
- **MySQL / MariaDB Server** (bisa menggunakan **XAMPP**, **Laragon**, atau MySQL Service bawaan).
- **Flutter SDK** (Channel Stable).
- **Google Chrome** (untuk menjalankan versi Web).
- **Android Studio & Android SDK** (jika ingin menjalankan di Emulator Android atau build file APK).

---

## 2. Menjalankan Backend API (PHP & MySQL)

### Langkah 1: Pastikan MySQL Aktif
- Jika menggunakan **XAMPP**: Buka *XAMPP Control Panel* dan klik **Start** pada modul **MySQL**.
- Jika menggunakan **Laragon**: Klik tombol **Start All**.

> **Info Otomatis Database:**
> File [`backend_api/db.php`](file:///d:/test/flutter_application_7/backend_api/db.php) sudah memiliki fitur otomatis: database `locara_db` dan tabel-tabel dari [`locara_db.sql`](file:///d:/test/flutter_application_7/backend_api/locara_db.sql) akan dibuat secara otomatis saat API pertama kali dipanggil. Anda tidak wajib import manual via phpMyAdmin.

### Langkah 2: Jalankan PHP Built-in Server
Buka terminal baru di folder proyek, lalu jalankan:

#### A. Untuk Testing di Web atau Android Emulator:
```powershell
cd d:\test\flutter_application_7\backend_api
php -S 127.0.0.1:6969
```

#### B. Untuk Testing di HP Fisik (via Wi-Fi yang sama):
Gunakan `0.0.0.0` agar server PHP dapat diakses oleh perangkat lain di jaringan LAN/Wi-Fi:
```powershell
cd d:\test\flutter_application_7\backend_api
php -S 0.0.0.0:6969
```

API sekarang berjalan di port `6969`.

---

## 3. Menjalankan Aplikasi Flutter

Buka terminal kedua di root project (`d:\test\flutter_application_7`).

### A. Menjalankan di Browser (Chrome / Web)
```powershell
flutter run -d chrome
```

### B. Menjalankan di Android Emulator
1. Buka Android Studio > Device Manager > Jalankan salah satu Virtual Device (AVD).
2. Di terminal jalankan:
   ```powershell
   flutter run
   ```

### C. Menjalankan di HP Fisik Android (USB Debugging / Wi-Fi)
1. Aktifkan **Developer Options** & **USB Debugging** di HP Anda.
2. Sambungkan HP ke laptop dengan kabel data.
3. Pastikan HP terdeteksi dengan perintah:
   ```powershell
   flutter devices
   ```
4. Jalankan aplikasi:
   ```powershell
   flutter run -d <device_id>
   ```

### D. Build File APK (Release)
```powershell
flutter build apk --release
```
Hasil file APK tersimpan di:
`build\app\outputs\flutter-apk\app-release.apk`

---

## 4. Hal yang Perlu Dikonfigurasi Ulang (Checklist Konfigurasi)

Berikut adalah komponen yang perlu disesuaikan sesuai kondisi lingkungan laptop/jaringan Anda:

### 1. Konfigurasi Database ([`backend_api/db.php`](file:///d:/test/flutter_application_7/backend_api/db.php))
Lokasi: Baris 16–22
```php
class Database {
    private string $host = '127.0.0.1';
    private string $db_name = 'locara_db';
    private string $username = 'root';
    private string $password = ''; // Ganti jika MySQL Anda memiliki password
    private int $port = 3306;      // Ganti jika port MySQL Anda bukan 3306
    ...
```
* **Kapan perlu diubah?** Jika MySQL Anda menggunakan password (bukan default kosong) atau port MySQL diubah (misalnya port 3307).

---

### 2. URL API BaseUrl Flutter ([`lib/services/api_service.dart`](file:///d:/test/flutter_application_7/lib/services/api_service.dart))
Lokasi: Baris 82–90
```dart
class ApiService { 
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:6969';
    }
    // Untuk Android Emulator bawaan:
    return 'http://10.0.2.2:6969';
    
    // Jika menggunakan HP Fisik (satu Wi-Fi):
    // return 'http://192.168.1.XX:6969';
  }
```

| Platform | URL API yang Digunakan | Keterangan |
| :--- | :--- | :--- |
| **Flutter Web (Chrome)** | `http://127.0.0.1:6969` | Otomatis terdeteksi via `kIsWeb`. |
| **Android Emulator** | `http://10.0.2.2:6969` | `10.0.2.2` adalah IP alias dari emulator untuk mengakses `localhost` host PC. |
| **HP Fisik Android** | `http://<IP_LAPTOP>:6969` | Contoh: `http://192.168.1.15:6969`. Lihat cara cek IP di bawah. |

#### Cara Mengetahui IP Laptop (untuk HP Fisik):
1. Buka PowerShell / CMD, ketik:
   ```powershell
   ipconfig
   ```
2. Cari baris **IPv4 Address** pada adaptor Wi-Fi Anda (misal: `192.168.1.25`).
3. Ubah `baseUrl` di `lib/services/api_service.dart` ke `http://192.168.1.25:6969`.
4. Pastikan PHP dijalankan dengan `php -S 0.0.0.0:6969`.

---

### 3. Izin Android ([`android/app/src/main/AndroidManifest.xml`](file:///d:/test/flutter_application_7/android/app/src/main/AndroidManifest.xml))
*(Catatan: Bagian ini sudah diperbarui dan diperbaiki di file proyek)*:
- Izin Internet: `<uses-permission android:name="android.permission.INTERNET"/>`
- Izin HTTP Cleartext: `android:usesCleartextTraffic="true"` (wajib agar Android 9+ mengizinkan koneksi `http://` lokal).

---

## 5. Troubleshooting & Solusi Error Umum

### ❌ `[!] No Android SDK found` saat build APK
* **Penyebab:** Android SDK belum terpasang atau path belum didaftarkan di Flutter.
* **Solusi:**
  1. Pasang Android Studio & buka SDK Manager untuk install SDK Build-Tools.
  2. Sambungkan SDK ke Flutter dengan perintah:
     ```powershell
     flutter config --android-sdk "C:\Users\LENOVO\AppData\Local\Android\Sdk"
     flutter doctor --android-licenses
     ```

### ❌ API Connection Refused di Android Emulator
* Pastikan server PHP aktif di port `6969`.
* Pastikan URL Flutter tidak menggunakan `127.0.0.1` di Android, melainkan `10.0.2.2:6969`.

### ❌ API Gagal Konek di HP Fisik
* Pastikan HP dan Laptop terhubung ke **jaringan Wi-Fi yang sama**.
* Pastikan server PHP dijalankan dengan `php -S 0.0.0.0:6969` (bukan `127.0.0.1:6969`).
* Pastikan **Windows Defender Firewall** tidak memblokir port `6969`.
