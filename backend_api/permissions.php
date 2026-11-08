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
            SELECT id, user_id, friend_id, friend_name, friend_code, avatar_text, status, sharing_duration, last_accessed, updated_at
            FROM friend_permissions
            WHERE user_id = :user_id
            ORDER BY FIELD(status, "active", "paused", "revoked"), id ASC
        ');
        $stmt->execute([':user_id' => $userId]);
        $permissions = $stmt->fetchAll();

        // Seed data jika belum ada untuk user ini
        if (empty($permissions)) {
            $isBima = str_contains($userId, 'bima') || str_contains($userId, '2841');
            $fName = $isBima ? 'Alina Putri' : 'Bima Saputra';
            $fId = $isBima ? 'usr_1028alinaputri01' : 'usr_2841bimasaputra01';
            $fCode = $isBima ? 'FT-1028' : 'FT-2841';
            $fAvatar = $isBima ? 'AP' : 'BS';

            $seed = $pdo->prepare('
                INSERT INTO friend_permissions (user_id, friend_id, friend_name, friend_code, avatar_text, status, sharing_duration, last_accessed)
                VALUES
                (:uid, :f_id, :f_name, :f_code, :f_avatar, "active", "Selalu aktif", "2 menit lalu"),
                (:uid, "usr_3916mayalestari", "Maya Lestari", "FT-3916", "ML", "paused", "Hanya hari ini", "Kemarin"),
                (:uid, "usr_5702rakapratama", "Raka Pratama", "FT-5702", "RP", "revoked", "Tidak aktif", "3 hari lalu")
            ');
            $seed->execute([
                ':uid' => $userId,
                ':f_id' => $fId,
                ':f_name' => $fName,
                ':f_code' => $fCode,
                ':f_avatar' => $fAvatar,
            ]);

            $stmt->execute([':user_id' => $userId]);
            $permissions = $stmt->fetchAll();
        }

        $activeCount = 0;
        $formatted = array_map(function ($p) use (&$activeCount) {
            if ($p['status'] === 'active') {
                $activeCount++;
            }
            return [
                'id' => (string)$p['id'],
                'friendId' => $p['friend_id'],
                'friendName' => $p['friend_name'],
                'friendCode' => $p['friend_code'],
                'avatarText' => $p['avatar_text'],
                'status' => $p['status'],
                'sharingDuration' => $p['sharing_duration'] ?? 'Selalu aktif',
                'lastAccessed' => $p['last_accessed'] ?? 'Baru saja',
                'updatedAt' => $p['updated_at'],
            ];
        }, $permissions);

        sendResponse(true, 'Daftar izin teman berhasil diambil', [
            'activeCount' => $activeCount,
            'permissions' => $formatted,
        ]);
        break;

    case 'POST':
    case 'PUT':
        $action = $input['action'] ?? ($_GET['action'] ?? 'toggle');
        $permId = (int)($input['id'] ?? ($_GET['id'] ?? 0));

        if ($action === 'toggle') {
            $newStatus = $input['status'] ?? '';
            if (empty($newStatus)) {
                $check = $pdo->prepare('SELECT status FROM friend_permissions WHERE id = :id AND user_id = :uid LIMIT 1');
                $check->execute([':id' => $permId, ':uid' => $userId]);
                $curr = $check->fetch();
                $newStatus = ($curr && $curr['status'] === 'active') ? 'paused' : 'active';
            }

            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET status = :status, updated_at = NOW()
                WHERE id = :id AND user_id = :uid
            ');
            $stmt->execute([
                ':status' => $newStatus,
                ':id' => $permId,
                ':uid' => $userId,
            ]);

            sendResponse(true, 'Status izin teman diperbarui', ['status' => $newStatus]);
        }

        if ($action === 'revoke') {
            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET status = "revoked", updated_at = NOW()
                WHERE id = :id AND user_id = :uid
            ');
            $stmt->execute([':id' => $permId, ':uid' => $userId]);
            sendResponse(true, 'Izin teman berhasil dicabut');
        }

        if ($action === 'activate') {
            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET status = "active", updated_at = NOW()
                WHERE id = :id AND user_id = :uid
            ');
            $stmt->execute([':id' => $permId, ':uid' => $userId]);
            sendResponse(true, 'Izin teman diaktifkan');
        }

        if ($action === 'update_duration') {
            $duration = trim($input['duration'] ?? 'Selalu aktif');
            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET sharing_duration = :duration, updated_at = NOW()
                WHERE id = :id AND user_id = :uid
            ');
            $stmt->execute([
                ':duration' => $duration,
                ':id' => $permId,
                ':uid' => $userId,
            ]);
            sendResponse(true, 'Durasi berbagi diperbarui', ['duration' => $duration]);
        }

        if ($action === 'pause_all') {
            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET status = "paused", updated_at = NOW()
                WHERE user_id = :uid AND status = "active"
            ');
            $stmt->execute([':uid' => $userId]);
            sendResponse(true, 'Semua pelacakan teman telah dijeda');
        }

        if ($action === 'resume_all') {
            $stmt = $pdo->prepare('
                UPDATE friend_permissions
                SET status = "active", updated_at = NOW()
                WHERE user_id = :uid AND status = "paused"
            ');
            $stmt->execute([':uid' => $userId]);
            sendResponse(true, 'Pelacakan teman aktif kembali');
        }

        sendResponse(false, 'Aksi tidak dikenali', null, 400);
        break;

    default:
        sendResponse(false, 'Metode HTTP tidak didukung', null, 405);
}
