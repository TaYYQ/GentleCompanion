<?php
// 注册接口
require_once '../../utils/response.php';
require_once '../../config/database.php';
require_once '../../models/User.php';

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['username']) || !isset($data['email']) || !isset($data['password'])) {
    response_error(400, 'Username, email and password are required');
}

$username = $data['username'];
$email = $data['email'];
$password = $data['password'];

// 连接数据库
$dbConfig = require_once '../../config/database.php';
$pdo = new PDO(
    "mysql:host={$dbConfig['host']};dbname={$dbConfig['database']};port={$dbConfig['port']}",
    $dbConfig['username'],
    $dbConfig['password']
);

// 检查邮箱是否已存在
$userModel = new User($pdo);
if ($userModel->getByEmail($email)) {
    response_error(400, 'Email already exists');
}

// 创建新用户
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
$userId = $userModel->create([
    'username' => $username,
    'email' => $email,
    'password' => $hashedPassword
]);

// 生成JWT token
$config = require_once '../../config/config.php';
$token = generate_jwt($userId, $config['jwt_secret']);

// 返回用户信息和token
response_success([
    'id' => $userId,
    'username' => $username,
    'email' => $email,
    'token' => $token
], 'Registration successful');

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