<?php
declare(strict_types=1);

require_once __DIR__ . '/db.php';

$database = new Database();
$pdo = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$input = getJsonInput();
$userId = $_GET['user_id'] ?? ($input['user_id'] ?? '');

if (empty($userId) && $method !== 'OPTIONS') {
    sendResponse(false, 'Parameter user_id diperlukan', null, 400);
}

switch ($method) {
    case 'GET':
        $stmt = $pdo->prepare('
            SELECT id, user_id, device_key, name, device_code, device_type, subtitle, location, speed, battery, status, time_ago, is_demo, updated_at
            FROM devices
            WHERE user_id = :user_id
            ORDER BY id ASC
        ');
        $stmt->execute([':user_id' => $userId]);
        $devices = $stmt->fetchAll();

        // Jika user belum punya device, tambahkan device default sesuai Figma
        if (empty($devices)) {
            $seed = $pdo->prepare('
                INSERT INTO devices (user_id, device_key, name, device_code, device_type, subtitle, location, speed, battery, status, time_ago, is_demo)
                VALUES 
                (:uid, "dev_car_1", "Mobil Ayah", "B 2841 SJK", "car", "B 2841 SJK", "Cikini, Jakarta Pusat", "32 km/j", 82, "online", "5 detik lalu", 1),
                (:uid, "dev_motor_1", "Motor Kakak", "B 3912 PRT", "motorcycle", "B 3912 PRT", "Gondangdia, Jakarta Pusat", "Berhenti", 64, "online", "12 detik lalu", 1),
                (:uid, "dev_tas_1", "Tas Rani", "LC-RANI", "bag", "Pelacak pribadi", "Tebet, Jakarta Selatan", "Berhenti", 91, "online", "30 detik lalu", 1),
                (:uid, "dev_koper_1", "Koper Ibu", "LC-KOPER", "suitcase", "Pelacak barang", "Manggarai, Jakarta Selatan", "Lokasi terakhir", 18, "offline", "2 jam lalu", 1)
            ');
            $seed->execute([':uid' => $userId]);

            $stmt->execute([':user_id' => $userId]);
            $devices = $stmt->fetchAll();
        }

        $formatted = array_map(function ($d) {
            return [
                'id' => (string)$d['id'],
                'deviceKey' => $d['device_key'],
                'name' => $d['name'],
                'deviceCode' => $d['device_code'],
                'deviceType' => $d['device_type'] ?? 'car',
                'subtitle' => $d['subtitle'] ?? '',
                'location' => $d['location'] ?? 'Cikini, Jakarta Pusat',
                'speed' => $d['speed'] ?? '32 km/j',
                'battery' => (int)$d['battery'],
                'status' => $d['status'],
                'timeAgo' => $d['time_ago'] ?? 'Baru saja',
                'isDemo' => (bool)$d['is_demo'],
                'updatedAt' => $d['updated_at'],
            ];
        }, $devices);

        sendResponse(true, 'Data perangkat berhasil diambil', $formatted);
        break;

    case 'POST':
        $deviceKey = trim($input['deviceKey'] ?? ($input['device_key'] ?? ('dev_' . bin2hex(random_bytes(4)))));
        $name = trim($input['name'] ?? 'Perangkat Baru');
        $deviceCode = trim($input['deviceCode'] ?? ($input['device_code'] ?? 'LC-2190'));
        $deviceType = trim($input['deviceType'] ?? 'car');
        $subtitle = trim($input['subtitle'] ?? $deviceCode);
        $location = trim($input['location'] ?? 'Jakarta Pusat');
        $speed = trim($input['speed'] ?? '0 km/j');
        $battery = (int)($input['battery'] ?? 100);
        $status = trim($input['status'] ?? 'online');
        $timeAgo = 'Baru saja';
        $isDemo = (int)($input['isDemo'] ?? 0);

        $stmt = $pdo->prepare('
            INSERT INTO devices (user_id, device_key, name, device_code, device_type, subtitle, location, speed, battery, status, time_ago, is_demo)
            VALUES (:user_id, :device_key, :name, :device_code, :device_type, :subtitle, :location, :speed, :battery, :status, :time_ago, :is_demo)
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                device_code = VALUES(device_code),
                device_type = VALUES(device_type),
                subtitle = VALUES(subtitle),
                location = VALUES(location),
                speed = VALUES(speed),
                battery = VALUES(battery),
                status = VALUES(status),
                time_ago = VALUES(time_ago),
                is_demo = VALUES(is_demo),
                updated_at = CURRENT_TIMESTAMP
        ');

        $stmt->execute([
            ':user_id' => $userId,
            ':device_key' => $deviceKey,
            ':name' => $name,
            ':device_code' => $deviceCode,
            ':device_type' => $deviceType,
            ':subtitle' => $subtitle,
            ':location' => $location,
            ':speed' => $speed,
            ':battery' => $battery,
            ':status' => $status,
            ':time_ago' => $timeAgo,
            ':is_demo' => $isDemo,
        ]);

        sendResponse(true, 'Perangkat berhasil dipasangkan', [
            'deviceKey' => $deviceKey,
            'name' => $name,
            'deviceCode' => $deviceCode,
            'deviceType' => $deviceType,
            'subtitle' => $subtitle,
            'location' => $location,
            'speed' => $speed,
            'battery' => $battery,
            'status' => $status,
            'timeAgo' => $timeAgo,
            'isDemo' => (bool)$isDemo,
        ]);
        break;

    default:
        sendResponse(false, 'Metode HTTP tidak didukung', null, 405);
}
