<?php
// 登录接口
require_once '../../utils/response.php';
require_once '../../config/database.php';
require_once '../../models/User.php';

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['password'])) {
    response_error(400, 'Email and password are required');
}

$email = $data['email'];
$password = $data['password'];

// 连接数据库
$dbConfig = require_once '../../config/database.php';
$pdo = new PDO(
    "mysql:host={$dbConfig['host']};dbname={$dbConfig['database']};port={$dbConfig['port']}",
    $dbConfig['username'],
    $dbConfig['password']
);

// 验证用户
$userModel = new User($pdo);
$user = $userModel->getByEmail($email);

if (!$user || !password_verify($password, $user['password'])) {
    response_error(401, 'Invalid email or password');
}

// 生成JWT token
$config = require_once '../../config/config.php';
$token = generate_jwt($user['id'], $config['jwt_secret']);

// 返回用户信息和token
response_success([
    'id' => $user['id'],
    'username' => $user['username'],
    'email' => $user['email'],
    'token' => $token
], 'Login successful');

function generate_jwt($userId, $secret) {
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    $payload = json_encode([
        'sub' => $userId,
        'iat' => time(),
        'exp' => time() + 86400 // 24小时过期
    ]);
    
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    $signature = hash_hmac('sha256', "$base64UrlHeader.$base64UrlPayload", $secret, true);
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    
    return "$base64UrlHeader.$base64UrlPayload.$base64UrlSignature";
}