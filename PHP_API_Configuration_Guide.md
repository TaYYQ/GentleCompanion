# PHP项目API配置指南

## 项目结构

### 基本目录结构
```
YOUR_API_DOMAIN/
├── index.php          # API入口文件
├── .htaccess          # URL重写配置
├── config/
│   ├── database.php   # 数据库配置
│   └── config.php     # 全局配置
├── api/
│   ├── auth/
│   │   ├── login.php  # 登录接口
│   │   └── register.php # 注册接口
│   └── social/
│       ├── feed.php    # 社交动态接口
│       └── posts.php   # 发布动态接口
├── models/
│   ├── User.php       # 用户模型
│   └── Post.php       # 动态模型
└── utils/
    ├── response.php   # 响应工具
    └── auth.php       # 认证工具
```

## 1. 基础配置

### 1.1 .htaccess 配置
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^api/(.*)$ index.php?path=$1 [QSA,L]
```

### 1.2 数据库配置 (config/database.php)
```php
<?php
// 数据库配置
return [
    'host' => '阿里云ECS服务器IP',
    'port' => 3306,
    'database' => '数据库名称',
    'username' => '数据库用户名',
    'password' => '数据库密码'
];
```

### 1.3 全局配置 (config/config.php)
```php
<?php
// 全局配置
return [
    'jwt_secret' => 'your_jwt_secret_key',
    'api_version' => 'v1',
    'allowed_origins' => ['*'] // 允许的跨域来源
];
```

## 2. API入口文件 (index.php)

```php
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
$path = $_GET['path'] ?? '';
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
            response_error(404, 'API endpoint not found');
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
```

## 3. 响应工具 (utils/response.php)

```php
<?php
// 响应工具函数

function response_success($data = null, $message = 'Success') {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => $message,
        'data' => $data
    ]);
    exit;
}

function response_error($code, $message) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'message' => $message,
        'data' => null
    ]);
    exit;
}
```

## 4. 认证接口

### 4.1 登录接口 (api/auth/login.php)

```php
<?php
// 登录接口
require_once 'utils/response.php';
require_once 'config/database.php';
require_once 'models/User.php';

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['password'])) {
    response_error(400, 'Email and password are required');
}

$email = $data['email'];
$password = $data['password'];

// 连接数据库
$dbConfig = require_once 'config/database.php';
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
$config = require_once 'config/config.php';
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
```

### 4.2 注册接口 (api/auth/register.php)

```php
<?php
// 注册接口
require_once 'utils/response.php';
require_once 'config/database.php';
require_once 'models/User.php';

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['username']) || !isset($data['email']) || !isset($data['password'])) {
    response_error(400, 'Username, email and password are required');
}

$username = $data['username'];
$email = $data['email'];
$password = $data['password'];

// 连接数据库
$dbConfig = require_once 'config/database.php';
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
$config = require_once 'config/config.php';
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
```

## 5. 社交动态接口

### 5.1 获取社交动态 (api/social/feed.php)

```php
<?php
// 获取社交动态接口
require_once 'utils/response.php';
require_once 'config/database.php';
require_once 'models/Post.php';

// 获取分页参数
$page = $_GET['page'] ?? 1;
$limit = $_GET['limit'] ?? 20;

// 连接数据库
$dbConfig = require_once 'config/database.php';
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
```

### 5.2 发布动态 (api/social/posts.php)

```php
<?php
// 发布动态接口
require_once 'utils/response.php';
require_once 'config/database.php';
require_once 'models/Post.php';
require_once 'utils/auth.php';

// 验证token
$token = get_bearer_token();
if (!$token) {
    response_error(401, 'Authorization token required');
}

$config = require_once 'config/config.php';
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
$dbConfig = require_once 'config/database.php';
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
```

## 6. 模型类

### 6.1 用户模型 (models/User.php)

```php
<?php
// 用户模型
class User {
    private $pdo;
    
    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }
    
    public function getByEmail($email) {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    public function create($data) {
        $stmt = $this->pdo->prepare('INSERT INTO users (username, email, password, created_at, last_active) VALUES (?, ?, ?, NOW(), NOW())');
        $stmt->execute([
            $data['username'],
            $data['email'],
            $data['password']
        ]);
        return $this->pdo->lastInsertId();
    }
    
    public function getById($id) {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
```

### 6.2 动态模型 (models/Post.php)

```php
<?php
// 动态模型
class Post {
    private $pdo;
    
    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }
    
    public function getFeed($page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        $stmt = $this->pdo->prepare('SELECT p.*, u.username FROM posts p JOIN users u ON p.user_id = u.id WHERE p.is_public = 1 ORDER BY p.created_at DESC LIMIT ? OFFSET ?');
        $stmt->execute([$limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function create($data) {
        $stmt = $this->pdo->prepare('INSERT INTO posts (user_id, content, is_public, created_at) VALUES (?, ?, ?, NOW())');
        $stmt->execute([
            $data['user_id'],
            $data['content'],
            $data['is_public'] ? 1 : 0
        ]);
        return $this->pdo->lastInsertId();
    }
    
    public function getById($id) {
        $stmt = $this->pdo->prepare('SELECT p.*, u.username FROM posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
```

## 7. 认证工具 (utils/auth.php)

```php
<?php
// 认证工具函数

function get_bearer_token() {
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        if (preg_match('/Bearer\s+(\S+)/', $authHeader, $matches)) {
            return $matches[1];
        }
    }
    return null;
}

function validate_jwt($token, $secret) {
    try {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }
        
        $header = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[0])), true);
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1])), true);
        $signature = $parts[2];
        
        // 验证过期时间
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }
        
        // 验证签名
        $expectedSignature = hash_hmac('sha256', "{$parts[0]}.{$parts[1]}", $secret, true);
        $expectedSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($expectedSignature));
        
        if ($signature !== $expectedSignature) {
            return false;
        }
        
        return $payload['sub'] ?? false;
    } catch (Exception $e) {
        return false;
    }
}
```

## 8. 数据库表结构

### 8.1 users表
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    last_active DATETIME NOT NULL,
    streak_days INT DEFAULT 0,
    total_pomodoros INT DEFAULT 0,
    total_minutes INT DEFAULT 0
);
```

### 8.2 posts表
```sql
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    is_public TINYINT(1) DEFAULT 1,
    likes INT DEFAULT 0,
    comments INT DEFAULT 0,
    pomodoro_session JSON NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## 9. 部署步骤

### 9.1 服务器配置
1. **安装PHP和MySQL**：确保服务器安装了PHP 7.4+和MySQL 5.7+
2. **配置虚拟主机**：在Nginx或Apache中配置YOUR_API_DOMAIN域名
3. **设置文件权限**：确保PHP文件有正确的执行权限

### 9.2 数据库设置
1. **创建数据库**：在MySQL中创建应用数据库
2. **导入表结构**：执行上述SQL语句创建必要的表
3. **创建数据库用户**：创建具有适当权限的数据库用户

### 9.3 代码部署
1. **上传代码**：将PHP项目文件上传到服务器
2. **配置文件**：修改config目录下的配置文件，填写真实的数据库信息
3. **测试API**：使用curl或Postman测试API接口

## 10. 测试API

### 10.1 测试登录
```bash
curl -X POST http://YOUR_API_DOMAIN/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### 10.2 测试注册
```bash
curl -X POST http://YOUR_API_DOMAIN/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"测试用户","email":"test@example.com","password":"password123"}'
```

### 10.3 测试获取社交动态
```bash
curl -X GET http://YOUR_API_DOMAIN/api/social/feed?page=1&limit=20
```

## 11. 安全性建议

1. **HTTPS配置**：启用SSL证书，使用HTTPS协议
2. **输入验证**：对所有用户输入进行严格验证
3. **密码安全**：使用bcrypt加密存储密码
4. **API限流**：实现API请求限流，防止滥用
5. **错误处理**：不要在生产环境中暴露详细错误信息
6. **CORS配置**：正确配置跨域资源共享

## 12. 监控和维护

1. **日志记录**：实现API访问日志
2. **错误监控**：设置错误监控和告警
3. **定期备份**：定期备份数据库
4. **性能优化**：优化数据库查询和API响应时间

## 总结

通过以上配置，PHP项目将能够为Swift项目提供完整的API服务，包括用户认证、社交动态等功能。同时，PHP项目作为中间层，能够与阿里云ECS服务器进行通信，处理数据存储和业务逻辑。

当PHP项目部署完成后，Swift项目将能够通过 `http://YOUR_API_DOMAIN` 访问这些API接口，实现完整的应用功能。
