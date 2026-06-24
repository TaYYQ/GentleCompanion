<?php
// API入口文件
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// 处理OPTIONS请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 加载配置
$config = require_once 'config/config.php';

// 解析API路径
// 支持两种方式：
// 1. ?path=auth/login (nginx rewrite)
// 2. 直接从 REQUEST_URI 解析 /api/auth/login
$path = $_GET['path'] ?? '';
if (empty($path)) {
    $requestUri = $_SERVER['REQUEST_URI'] ?? '';
    // 去掉查询字符串
    $requestUri = strtok($requestUri, '?');
    // 去掉开头的 /
    $path = trim($requestUri, '/');
    // 去掉 api/ 前缀（如果有）
    if (strpos($path, 'api/') === 0) {
        $path = substr($path, 4);
    }
}
$parts = explode('/', $path);

// 路由处理
try {
    if (count($parts) >= 2) {
        $controller = $parts[0];
        $action = $parts[1];
        
        $file = "api/{$controller}/{$action}.php";
        
        if (file_exists($file)) {
            require_once $file;
        } else {
            require_once 'utils/response.php';
            response_error(404, 'API endpoint not found: ' . $path);
        }
    } else {
        require_once 'utils/response.php';
        response_success([
            'message' => 'Gentle Companion API',
            'version' => $config['api_version'],
            'status' => 'running'
        ]);
    }
} catch (Exception $e) {
    require_once 'utils/response.php';
    response_error(500, 'Internal server error: ' . $e->getMessage());
}