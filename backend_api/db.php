<?php
declare(strict_types=1);

// Set header CORS agar Flutter Web bisa mengakses API ini
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');
} else {
    header('Access-Control-Allow-Origin: *');
}

header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
header('Access-Control-Allow-Private-Network: true');
header('Content-Type: application/json; charset=UTF-8');

if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'])) {
    header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
} else {
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept, Access-Control-Request-Method, Access-Control-Request-Headers');
}

// Tangani uncaught exception agar selalu mengembalikan JSON dan header CORS tetap utuh
set_exception_handler(function (Throwable $e) {
    sendResponse(false, 'Database Error: ' . $e->getMessage(), null, 500);
});

// Handle preflight request dari browser
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

class Database {
    private string $host = '127.0.0.1';
    private string $db_name = 'locara_db';
    private string $username = 'root';
    private string $password = '';
    private int $port = 3306;
    private ?PDO $conn = null;

    public function getConnection(): PDO {
        if ($this->conn === null) {
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => true,
            ];
            $dsn = "mysql:host={$this->host};port={$this->port};dbname={$this->db_name};charset=utf8mb4";
            try {
                $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            } catch (PDOException $e) {
                // If database doesn't exist, create it automatically
                if ($e->getCode() == 1049 || str_contains($e->getMessage(), 'Unknown database')) {
                    $rootDsn = "mysql:host={$this->host};port={$this->port};charset=utf8mb4";
                    $rootPdo = new PDO($rootDsn, $this->username, $this->password, $options);
                    $rootPdo->exec("CREATE DATABASE IF NOT EXISTS `{$this->db_name}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                    $this->conn = new PDO($dsn, $this->username, $this->password, $options);
                } else {
                    throw $e;
                }
            }

            // Ensure tables are initialized from locara_db.sql
            $sqlFile = __DIR__ . '/locara_db.sql';
            if (file_exists($sqlFile)) {
                $check = $this->conn->query("SHOW TABLES LIKE 'users'")->fetch();
                if (!$check) {
                    $sql = file_get_contents($sqlFile);
                    $this->conn->exec($sql);
                }
            }
        }
        return $this->conn;
    }
}

function sendResponse(bool $success, string $message, mixed $data = null, int $statusCode = 200): void {
    http_response_code($statusCode);
    echo json_encode([
        'status' => $success ? 'success' : 'error',
        'message' => $message,
        'data' => $data,
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit();
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        return $_POST;
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}

function computeUniqueId(string $uid, string $name = ''): string {
    $cleanName = strtolower($name);
    if (str_contains($cleanName, 'alina') || str_contains($uid, '1028')) return 'FT-1028';
    if (str_contains($cleanName, 'bima') || str_contains($uid, '2841')) return 'FT-2841';
    if (str_contains($cleanName, 'maya') || str_contains($uid, '3916')) return 'FT-3916';
    if (str_contains($cleanName, 'raka') || str_contains($uid, '5702')) return 'FT-5702';

    if (str_starts_with($uid, 'usr_')) {
        $hexPart = preg_replace('/[^0-9a-f]/i', '', substr($uid, 4));
        if (strlen($hexPart) >= 4) {
            return 'FT-' . strtoupper(substr($hexPart, 0, 4));
        }
    }

    $cleanUid = preg_replace('/[^0-9a-f]/i', '', $uid);
    if (strlen($cleanUid) >= 4) {
        return 'FT-' . strtoupper(substr($cleanUid, 0, 4));
    }
    return 'FT-' . strtoupper(substr(md5($uid . $name), 0, 4));
}
