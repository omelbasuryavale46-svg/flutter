<?php
declare(strict_types=1);

require_once __DIR__ . '/db.php';

$database = new Database();
$pdo = $database->getConnection();

$action = $_GET['action'] ?? '';
$input = getJsonInput();

switch ($action) {
    case 'register':
        $name = trim($input['name'] ?? '');
        $email = trim($input['email'] ?? '');
        $password = $input['password'] ?? '';

        if (empty($name) || empty($email) || empty($password)) {
            sendResponse(false, 'Lengkapi semua field (nama, email, kata sandi)', null, 400);
        }

        if (strlen($password) < 6) {
            sendResponse(false, 'Kata sandi minimal 6 karakter', null, 400);
        }

        // Cek apakah email sudah terdaftar
        $stmt = $pdo->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $email]);
        if ($stmt->fetch()) {
            sendResponse(false, 'Email sudah digunakan', null, 409);
        }

        $uid = 'usr_' . bin2hex(random_bytes(10));
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
        $familyName = 'Keluarga ' . $name;

        $insert = $pdo->prepare('
            INSERT INTO users (uid, name, family_name, email, password)
            VALUES (:uid, :name, :family_name, :email, :password)
        ');
        $insert->execute([
            ':uid' => $uid,
            ':name' => $name,
            ':family_name' => $familyName,
            ':email' => $email,
            ':password' => $hashedPassword,
        ]);

        $uniqueId = computeUniqueId($uid, $name);
        sendResponse(true, 'Registrasi berhasil', [
            'uid' => $uid,
            'name' => $name,
            'familyName' => $familyName,
            'email' => $email,
            'uniqueId' => $uniqueId,
            'userCode' => $uniqueId,
        ], 201);
        break;

    case 'login':
        $email = trim($input['email'] ?? '');
        $password = $input['password'] ?? '';

        if (empty($email) || empty($password)) {
            sendResponse(false, 'Email dan kata sandi wajib diisi', null, 400);
        }

        $stmt = $pdo->prepare('SELECT uid, name, family_name, email, password FROM users WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password'])) {
            sendResponse(false, 'Email atau kata sandi salah', null, 401);
        }

        $uniqueId = computeUniqueId($user['uid'], $user['name']);

        sendResponse(true, 'Login berhasil', [
            'uid' => $user['uid'],
            'name' => $user['name'],
            'familyName' => $user['family_name'],
            'email' => $user['email'],
            'uniqueId' => $uniqueId,
            'userCode' => $uniqueId,
        ]);
        break;

    case 'profile':
        $uid = $_GET['uid'] ?? ($input['uid'] ?? '');
        if (empty($uid)) {
            sendResponse(false, 'UID pengguna diperlukan', null, 400);
        }

        $stmt = $pdo->prepare('SELECT uid, name, family_name, email, created_at FROM users WHERE uid = :uid LIMIT 1');
        $stmt->execute([':uid' => $uid]);
        $user = $stmt->fetch();

        if (!$user) {
            sendResponse(false, 'Pengguna tidak ditemukan', null, 404);
        }

        $uniqueId = computeUniqueId($user['uid'], $user['name']);

        sendResponse(true, 'Profil ditemukan', [
            'uid' => $user['uid'],
            'name' => $user['name'],
            'familyName' => $user['family_name'],
            'email' => $user['email'],
            'uniqueId' => $uniqueId,
            'userCode' => $uniqueId,
            'createdAt' => $user['created_at'],
        ]);
        break;

    case 'update_profile':
        $uid = $input['uid'] ?? '';
        $name = trim($input['name'] ?? '');
        $familyName = trim($input['familyName'] ?? '');

        if (empty($uid)) {
            sendResponse(false, 'UID pengguna diperlukan', null, 400);
        }

        $stmt = $pdo->prepare('
            UPDATE users 
            SET name = COALESCE(NULLIF(:name, ""), name),
                family_name = COALESCE(NULLIF(:family_name, ""), family_name)
            WHERE uid = :uid
        ');
        $stmt->execute([
            ':name' => $name,
            ':family_name' => $familyName,
            ':uid' => $uid,
        ]);

        sendResponse(true, 'Profil berhasil diperbarui');
        break;

    default:
        sendResponse(false, 'Aksi tidak valid', null, 400);
}
