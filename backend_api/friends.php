<?php
declare(strict_types=1);

require_once __DIR__ . '/db.php';

$database = new Database();
$pdo = $database->getConnection();

$action = $_GET['action'] ?? '';
$input = getJsonInput();

switch ($action) {
    case 'search':
        $query = trim($_GET['q'] ?? '');
        if (empty($query)) {
            sendResponse(false, 'Masukkan ID unik teman', null, 400);
        }

        // Check in MySQL users table
        $stmt = $pdo->prepare('SELECT name, uid, email FROM users');
        $stmt->execute();
        $allUsers = $stmt->fetchAll();
        foreach ($allUsers as $u) {
            $uCode = computeUniqueId($u['uid'], $u['name']);
            if (strcasecmp($query, $uCode) === 0 
                || strcasecmp($query, $u['uid']) === 0 
                || strcasecmp($query, $u['email']) === 0
                || str_contains(strtolower($u['name']), strtolower($query))
                || str_contains(strtoupper($uCode), strtoupper($query))) {
                
                $parts = explode(' ', trim($u['name']));
                $initials = count($parts) >= 2 
                    ? strtoupper($parts[0][0] . $parts[1][0]) 
                    : strtoupper(substr($u['name'], 0, 2));

                sendResponse(true, 'Teman ditemukan', [
                    'id' => $u['uid'],
                    'name' => $u['name'],
                    'uniqueId' => $uCode,
                    'user_code' => $uCode,
                    'email' => $u['email'],
                    'avatarText' => $initials,
                    'status' => "Lokasi {$parts[0]} belum dibagikan.",
                    'canRequest' => true,
                ]);
            }
        }

        // Demo fallbacks matching Figma
        $cleanQ = strtoupper($query);
        if ($cleanQ === 'FT-2841' || str_contains($cleanQ, '2841') || str_contains(strtolower($query), 'bima')) {
            sendResponse(true, 'Teman ditemukan', [
                'id' => 'usr_2841bimasaputra01',
                'name' => 'Bima Saputra',
                'uniqueId' => 'FT-2841',
                'user_code' => 'FT-2841',
                'avatarText' => 'BS',
                'status' => 'Lokasi Bima belum dibagikan.',
                'canRequest' => true,
            ]);
        }

        if ($cleanQ === 'FT-1028' || str_contains($cleanQ, '1028') || str_contains(strtolower($query), 'alina')) {
            sendResponse(true, 'Teman ditemukan', [
                'id' => 'usr_1028alinaputri01',
                'name' => 'Alina Putri',
                'uniqueId' => 'FT-1028',
                'user_code' => 'FT-1028',
                'avatarText' => 'AP',
                'status' => 'Lokasi Alina belum dibagikan.',
                'canRequest' => true,
            ]);
        }

        if ($cleanQ === 'FT-3916' || str_contains($cleanQ, '3916') || str_contains(strtolower($query), 'maya')) {
            sendResponse(true, 'Teman ditemukan', [
                'id' => 'usr_3916mayalestari',
                'name' => 'Maya Lestari',
                'uniqueId' => 'FT-3916',
                'user_code' => 'FT-3916',
                'avatarText' => 'ML',
                'status' => 'Lokasi Maya belum dibagikan.',
                'canRequest' => true,
            ]);
        }

        if ($cleanQ === 'FT-5702' || str_contains($cleanQ, '5702') || str_contains(strtolower($query), 'raka')) {
            sendResponse(true, 'Teman ditemukan', [
                'id' => 'usr_5702rakapratama',
                'name' => 'Raka Pratama',
                'uniqueId' => 'FT-5702',
                'user_code' => 'FT-5702',
                'avatarText' => 'RP',
                'status' => 'Lokasi Raka belum dibagikan.',
                'canRequest' => true,
            ]);
        }

        sendResponse(false, 'Teman dengan ID tersebut tidak ditemukan', null, 404);
        break;

    case 'request':
        $userId = $input['userId'] ?? '';
        $targetId = $input['targetId'] ?? '';

        sendResponse(true, 'Permintaan pelacakan berhasil dikirim', [
            'targetId' => $targetId,
            'sentAt' => date('Y-m-d H:i:s'),
        ]);
        break;

    default:
        sendResponse(false, 'Aksi tidak valid', null, 400);
}
