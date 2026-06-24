<?php
// 发布动态接口
require_once '../../utils/response.php';
require_once '../../config/database.php';
require_once '../../models/Post.php';
require_once '../../utils/auth.php';

// 验证token
$token = get_bearer_token();
if (!$token) {
    response_error(401, 'Authorization token required');
}

$config = require_once '../../config/config.php';
$userId = validate_jwt($token, $config['jwt_secret']);
if (!$userId) {
    response_error(401, 'Invalid or expired token');
}

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['content'])) {
    response_error(400, 'Content is required');
}

$content = $data['content'];
$isPublic = $data['isPublic'] ?? true;

// 连接数据库
$dbConfig = require_once '../../config/database.php';
$pdo = new PDO(
    "mysql:host={$dbConfig['host']};dbname={$dbConfig['database']};port={$dbConfig['port']}",
    $dbConfig['username'],
    $dbConfig['password']
);

// 创建动态
$postModel = new Post($pdo);
$postId = $postModel->create([
    'user_id' => $userId,
    'content' => $content,
    'is_public' => $isPublic
]);

// 获取创建的动态
$post = $postModel->getById($postId);

// 格式化响应数据
$formattedPost = [
    'id' => $post['id'],
    'userId' => $post['user_id'],
    'username' => $post['username'],
    'content' => $post['content'],
    'createdAt' => $post['created_at'],
    'isPublic' => (bool)$post['is_public'],
    'likes' => 0,
    'comments' => 0,
    'isLiked' => false,
    'pomodoroSession' => null
];

response_success($formattedPost, 'Post created successfully');