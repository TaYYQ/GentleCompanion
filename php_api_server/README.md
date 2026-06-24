# PHP API服务器部署指南

## 项目结构

```
php_api_server/
├── api/                # API接口目录
│   ├── auth/           # 认证相关接口
│   │   ├── login.php   # 登录接口
│   │   └── register.php # 注册接口
│   └── social/         # 社交相关接口
│       ├── feed.php    # 获取社交动态接口
│       └── posts.php   # 发布动态接口
├── config/             # 配置文件目录
│   ├── config.php      # 全局配置
│   └── database.php    # 数据库配置
├── models/             # 模型文件目录
│   ├── Post.php        # 动态模型
│   └── User.php        # 用户模型
├── utils/              # 工具文件目录
│   ├── auth.php        # 认证工具
│   └── response.php    # 响应工具
├── .htaccess           # URL重写配置
├── database.sql        # 数据库表结构和示例数据
├── index.php           # API入口文件
└── README.md           # 部署指南
```

## 部署步骤

### 1. 服务器准备

1. **安装必要的软件**：
   - PHP 7.4+ 
   - MySQL 5.7+ 
   - Apache或Nginx

2. **配置虚拟主机**：
   - 在Apache或Nginx中配置一个虚拟主机，指向此文件夹
   - 确保域名`YOUR_API_DOMAIN`正确解析到服务器IP

### 2. 数据库设置

1. **创建数据库**：
   - 登录MySQL
   - 执行 `database.sql` 文件中的SQL语句：
   ```bash
   mysql -u root -p < database.sql
   ```

2. **配置数据库连接**：
   - 编辑 `config/database.php` 文件，填写您的数据库连接信息：
   ```php
   return [
       'host' => '您的数据库主机',
       'port' => 3306,
       'database' => 'gentle_companion',
       'username' => '您的数据库用户名',
       'password' => '您的数据库密码'
   ];
   ```

### 3. API配置

1. **设置JWT密钥**：
   - 编辑 `config/config.php` 文件，设置一个安全的JWT密钥：
   ```php
   return [
       'jwt_secret' => '您的安全JWT密钥',
       'api_version' => 'v1',
       'allowed_origins' => ['*']
   ];
   ```

2. **权限设置**：
   - 确保PHP文件有正确的执行权限
   - 确保 `config` 目录有适当的读写权限

### 4. 测试API

使用curl或Postman测试API接口：

**测试API状态**：
```bash
curl http://YOUR_API_DOMAIN
```

**测试注册**：
```bash
curl -X POST http://YOUR_API_DOMAIN/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"测试用户","email":"test@example.com","password":"password123"}'
```

**测试登录**：
```bash
curl -X POST http://YOUR_API_DOMAIN/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**测试获取社交动态**：
```bash
curl -X GET http://YOUR_API_DOMAIN/api/social/feed?page=1&limit=20
```

### 5. Swift应用配置

在Swift项目的 `NetworkService.swift` 文件中，将baseURL设置为：

```swift
private let baseURL = "http://YOUR_API_DOMAIN"
```

## 安全性建议

1. **启用HTTPS**：配置SSL证书，使用HTTPS协议
2. **设置强密码**：为数据库用户和JWT密钥设置强密码
3. **限制访问**：配置服务器防火墙，只允许必要的端口访问
4. **定期更新**：定期更新PHP版本和依赖库
5. **监控日志**：设置API访问日志和错误监控

## 故障排除

- **API返回404**：检查.htaccess文件是否正确配置，确保URL重写功能正常
- **数据库连接失败**：检查database.php中的数据库连接信息是否正确
- **认证失败**：检查JWT密钥是否正确设置，确保token格式正确
- **CORS错误**：确保config.php中的allowed_origins设置正确

## 联系信息

如果您在部署过程中遇到任何问题，请随时联系我们获取帮助。