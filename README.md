# Locara App (flutter_application_7)

Aplikasi Flutter dengan Backend PHP & MySQL.

---

## 📖 Panduan Menjalankan API & Flutter
Untuk panduan lengkap langkah-langkah menjalankan Backend PHP, Database MySQL, Flutter di Web / Emulator / HP Fisik, serta hal-hal yang perlu dikonfigurasi ulang, silakan baca:

👉 **[PANDUAN_SETUP.md](file:///d:/test/flutter_application_7/PANDUAN_SETUP.md)**

---

## Ringkasan Perintah Cepat

### 1. Menjalankan Backend PHP (Terminal 1)
```powershell
cd backend_api
php -S 127.0.0.1:6969
# atau untuk akses via HP fisik (WiFi):
# php -S 0.0.0.0:6969
```

### 2. Menjalankan Flutter Web (Terminal 2)
```powershell
flutter run -d chrome
```

### 3. Build APK Android
```powershell
flutter build apk --release
```
