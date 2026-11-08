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
            SELECT id, user_id, title, message, type, avatar_text, sender_name, request_status, subtitle, is_read, created_at
            FROM notifications
            WHERE user_id = :user_id
            ORDER BY id ASC
        ');
        $stmt->execute([':user_id' => $userId]);
        $notifs = $stmt->fetchAll();

        // Jika user belum punya notifikasi, seed sesuai Figma
        if (empty($notifs)) {
            $isBima = str_contains($userId, 'bima') || str_contains($userId, '2841');
            $reqSenderName = $isBima ? 'Alina Putri' : 'Bima Saputra';
            $reqAvatar = $isBima ? 'AP' : 'BS';
            $reqSubtitle = $isBima ? 'FT-1028 · 2 menit lalu' : 'FT-2841 · 2 menit lalu';
            $reqMsg = $isBima 
                ? 'Alina ingin melacak lokasi kamu. Lokasimu belum dibagikan; menunggu persetujuanmu.'
                : 'Bima ingin melacak lokasi kamu. Lokasimu belum dibagikan; menunggu persetujuanmu.';

            $seed = $pdo->prepare('
                INSERT INTO notifications (user_id, title, message, type, avatar_text, sender_name, request_status, subtitle)
                VALUES
                (:uid, "Permintaan Masuk", :req_msg, "request", :req_avatar, :req_sender, "Menunggu", :req_sub),
                (:uid, "Izin Disetujui", "Kamu menyetujui permintaan Maya. Izin telah kamu hentikan; lokasi tidak lagi dibagikan.", "history", "ML", "Maya Lestari", "Disetujui", "FT-3916 · Kemarin"),
                (:uid, "Izin Ditolak", "Kamu menolak permintaan Raka. Raka tidak dapat melihat lokasi kamu.", "history", "RP", "Raka Pratama", "Ditolak", "FT-5702 · Kemarin")
            ');
            $seed->execute([
                ':uid' => $userId,
                ':req_msg' => $reqMsg,
                ':req_avatar' => $reqAvatar,
                ':req_sender' => $reqSenderName,
                ':req_sub' => $reqSubtitle,
            ]);

            $stmt->execute([':user_id' => $userId]);
            $notifs = $stmt->fetchAll();
        }

        $formatted = array_map(function ($n) {
            return [
                'id' => (string)$n['id'],
                'title' => $n['title'],
                'message' => $n['message'],
                'type' => $n['type'],
                'avatarText' => $n['avatar_text'] ?? 'BS',
                'senderName' => $n['sender_name'] ?? 'Teman',
                'requestStatus' => $n['request_status'] ?? 'Menunggu',
                'subtitle' => $n['subtitle'] ?? '',
                'isRead' => (bool)$n['is_read'],
                'createdAt' => $n['created_at'],
            ];
        }, $notifs);

        sendResponse(true, 'Data notifikasi berhasil diambil', $formatted);
        break;

    case 'PUT':
    case 'PATCH':
        $action = $input['action'] ?? ($_GET['action'] ?? '');
        $id = (int)($input['id'] ?? ($_GET['id'] ?? 0));

        if ($action === 'respond_request') {
            $rawStatus = strtolower($input['status'] ?? 'approved');
            $isApproved = ($rawStatus === 'approved' || $rawStatus === 'disetujui');
            $finalStatus = $isApproved ? 'Disetujui' : 'Ditolak';
            $msg = $isApproved
                ? 'Kamu telah menyetujui permintaan pelacakan ini.'
                : 'Kamu telah menolak permintaan pelacakan ini.';

            // Ambil info notifikasi untuk sinkronisasi izin teman
            $getNotif = $pdo->prepare('SELECT sender_name, avatar_text, subtitle FROM notifications WHERE id = :id AND user_id = :uid LIMIT 1');
            $getNotif->execute([':id' => $id, ':uid' => $userId]);
            $nData = $getNotif->fetch();

            $stmt = $pdo->prepare('
                UPDATE notifications 
                SET request_status = :status,
                    message = :msg
                WHERE id = :id AND user_id = :user_id
            ');
            $stmt->execute([
                ':status' => $finalStatus,
                ':msg' => $msg,
                ':id' => $id,
                ':user_id' => $userId,
            ]);

            // Sinkronkan ke tabel friend_permissions
            if ($nData) {
                $fName = $nData['sender_name'] ?? 'Teman';
                $fAvatar = $nData['avatar_text'] ?? 'TM';
                preg_match('/FT-\d+/', $nData['subtitle'] ?? '', $matches);
                $fCode = $matches[0] ?? (str_contains(strtolower($fName), 'bima') ? 'FT-2841' : 'FT-1028');
                $permStatus = $isApproved ? 'active' : 'revoked';

                $checkP = $pdo->prepare('SELECT id FROM friend_permissions WHERE user_id = :uid AND friend_name = :fname LIMIT 1');
                $checkP->execute([':uid' => $userId, ':fname' => $fName]);
                $existingP = $checkP->fetch();

                if ($existingP) {
                    $upP = $pdo->prepare('UPDATE friend_permissions SET status = :status, updated_at = NOW() WHERE id = :pid');
                    $upP->execute([':status' => $permStatus, ':pid' => $existingP['id']]);
                } else {
                    $insP = $pdo->prepare('
                        INSERT INTO friend_permissions (user_id, friend_id, friend_name, friend_code, avatar_text, status, sharing_duration, last_accessed)
                        VALUES (:uid, :fid, :fname, :fcode, :favatar, :status, "Selalu aktif", "Baru saja")
                    ');
                    $insP->execute([
                        ':uid' => $userId,
                        ':fid' => 'usr_' . strtolower(substr($fCode, 3)),
                        ':fname' => $fName,
                        ':fcode' => $fCode,
                        ':favatar' => $fAvatar,
                        ':status' => $permStatus,
                    ]);
                }
            }

            sendResponse(true, 'Permintaan telah ditanggapi (' . $finalStatus . ')');
        } else {
            $stmt = $pdo->prepare('UPDATE notifications SET is_read = 1 WHERE user_id = :user_id');
            $stmt->execute([':user_id' => $userId]);
            sendResponse(true, 'Semua notifikasi ditandai dibaca');
        }
        break;

    default:
        sendResponse(false, 'Metode HTTP tidak didukung', null, 405);
}
