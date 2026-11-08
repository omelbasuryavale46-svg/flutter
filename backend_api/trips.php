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
            SELECT id, user_id, device_id, time_range, route_name, distance, duration, detail, trip_date, created_at
            FROM trips
            WHERE user_id = :user_id
            ORDER BY id ASC
        ');
        $stmt->execute([':user_id' => $userId]);
        $trips = $stmt->fetchAll();

        // Jika user belum punya trips, seed data default sesuai Figma
        if (empty($trips)) {
            $seed = $pdo->prepare('
                INSERT INTO trips (user_id, time_range, route_name, distance, duration, detail, trip_date)
                VALUES
                (:uid, "08.15 – 08.47", "Rumah → Kantor", "8,4 km", "32 menit", "Setiabudi → Jl. Cikini Raya, Menteng", "Hari ini, 5 Oktober 2026"),
                (:uid, "07.02 – 07.20", "Sarapan → Rumah", "6,2 km", "18 menit", "Jl. Sabang → Setiabudi", "Hari ini, 5 Oktober 2026"),
                (:uid, "06.20 – 06.48", "Rumah → Sarapan", "10 km", "28 menit", "Setiabudi → Jl. Sabang", "Hari ini, 5 Oktober 2026")
            ');
            $seed->execute([':uid' => $userId]);

            $stmt->execute([':user_id' => $userId]);
            $trips = $stmt->fetchAll();
        }

        $formatted = array_map(function ($t) {
            return [
                'id' => (string)$t['id'],
                'timeRange' => $t['time_range'],
                'routeName' => $t['route_name'],
                'distance' => $t['distance'],
                'duration' => $t['duration'],
                'detail' => $t['detail'],
                'tripDate' => $t['trip_date'],
                'createdAt' => $t['created_at'],
            ];
        }, $trips);

        sendResponse(true, 'Data riwayat perjalanan berhasil diambil', [
            'summary' => [
                'totalDistance' => '24,6 km',
                'movingTime' => '1 j 18 m',
                'tripCount' => count($formatted),
            ],
            'trips' => $formatted,
        ]);
        break;

    default:
        sendResponse(false, 'Metode HTTP tidak didukung', null, 405);
}
