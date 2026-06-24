<?php
// 获取社交动态接口
require_once '../../utils/response.php';
require_once '../../config/database.php';
require_once '../../models/Post.php';

// 获取分页参数
$page = $_GET['page'] ?? 1;
$limit = $_GET['limit'] ?? 20;

// 连接数据库
$dbConfig = require_once '../../config/database.php';
$pdo = new PDO(
    "mysql:host={$dbConfig['host']};dbname={$dbConfig['database']};port={$dbConfig['port']}",
    $dbConfig['username'],
    $dbConfig['password']
);

// 获取动态列表
$postModel = new Post($pdo);
$posts = $postModel->getFeed($page, $limit);

// 格式化响应数据
$formattedPosts = array_map(function($post) {
    return [
        'id' => $post['id'],
        'userId' => $post['user_id'],
        'username' => $post['username'],
        'content' => $post['content'],
        'createdAt' => $post['created_at'],
        'isPublic' => (bool)$post['is_public'],
        'likes' => (int)$post['likes'],
        'comments' => (int)$post['comments'],
        'isLiked' => false, // 需要根据当前用户状态判断
        'pomodoroSession' => $post['pomodoro_session'] ? json_decode($post['pomodoro_session'], true) : null
    ];
}, $posts);

response_success($formattedPosts, 'Social feed retrieved successfully');