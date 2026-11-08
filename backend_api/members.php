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
            SELECT id, user_id, name, place, status, battery, latitude, longitude, created_at
            FROM members
            WHERE user_id = :user_id
            ORDER BY id ASC
        ');
        $stmt->execute([':user_id' => $userId]);
        $members = $stmt->fetchAll();

        // Format data agar sesuai dengan model aplikasi Flutter
        $formatted = array_map(function ($m) {
            return [
                'id' => (string)$m['id'],
                'name' => $m['name'],
                'place' => $m['place'],
                'status' => $m['status'],
                'battery' => (int)$m['battery'],
                'latitude' => (float)$m['latitude'],
                'longitude' => (float)$m['longitude'],
                'createdAt' => $m['created_at'],
            ];
        }, $members);

        sendResponse(true, 'Data anggota berhasil diambil', $formatted);
        break;

    case 'POST':
        $name = trim($input['name'] ?? '');
        $place = trim($input['place'] ?? 'Lokasi belum tersedia');
        $status = trim($input['status'] ?? 'offline');
        $battery = (int)($input['battery'] ?? 0);
        $latitude = (float)($input['latitude'] ?? -7.7956);
        $longitude = (float)($input['longitude'] ?? 110.3695);

        if (empty($name)) {
            sendResponse(false, 'Nama anggota harus diisi', null, 400);
        }

        $stmt = $pdo->prepare('
            INSERT INTO members (user_id, name, place, status, battery, latitude, longitude)
            VALUES (:user_id, :name, :place, :status, :battery, :latitude, :longitude)
        ');
        $stmt->execute([
            ':user_id' => $userId,
            ':name' => $name,
            ':place' => $place,
            ':status' => $status,
            ':battery' => $battery,
            ':latitude' => $latitude,
            ':longitude' => $longitude,
        ]);

        $newId = $pdo->lastInsertId();

        sendResponse(true, 'Anggota keluarga berhasil ditambahkan', [
            'id' => (string)$newId,
            'name' => $name,
            'place' => $place,
            'status' => $status,
            'battery' => $battery,
            'latitude' => $latitude,
            'longitude' => $longitude,
        ], 201);
        break;

    case 'PUT':
        $id = (int)($input['id'] ?? 0);
        if ($id <= 0) {
            sendResponse(false, 'ID anggota tidak valid', null, 400);
        }

        $fields = [];
        $params = [':id' => $id, ':user_id' => $userId];

        if (isset($input['name'])) {
            $fields[] = 'name = :name';
            $params[':name'] = trim((string)$input['name']);
        }
        if (isset($input['place'])) {
            $fields[] = 'place = :place';
            $params[':place'] = trim((string)$input['place']);
        }
        if (isset($input['status'])) {
            $fields[] = 'status = :status';
            $params[':status'] = trim((string)$input['status']);
        }
        if (isset($input['battery'])) {
            $fields[] = 'battery = :battery';
            $params[':battery'] = (int)$input['battery'];
        }
        if (isset($input['latitude'])) {
            $fields[] = 'latitude = :latitude';
            $params[':latitude'] = (float)$input['latitude'];
        }
        if (isset($input['longitude'])) {
            $fields[] = 'longitude = :longitude';
            $params[':longitude'] = (float)$input['longitude'];
        }

        if (empty($fields)) {
            sendResponse(false, 'Tidak ada field yang diperbarui', null, 400);
        }

        $sql = 'UPDATE members SET ' . implode(', ', $fields) . ' WHERE id = :id AND user_id = :user_id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        sendResponse(true, 'Data anggota berhasil diperbarui');
        break;

    case 'DELETE':
        $id = (int)($input['id'] ?? ($_GET['id'] ?? 0));
        if ($id <= 0) {
            sendResponse(false, 'ID anggota tidak valid', null, 400);
        }

        $stmt = $pdo->prepare('DELETE FROM members WHERE id = :id AND user_id = :user_id');
        $stmt->execute([':id' => $id, ':user_id' => $userId]);

        sendResponse(true, 'Anggota keluarga berhasil dihapus');
        break;

    default:
        sendResponse(false, 'Metode HTTP tidak didukung', null, 405);
}
