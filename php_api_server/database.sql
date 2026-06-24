-- 创建数据库
CREATE DATABASE IF NOT EXISTS gentle_companion;

-- 使用数据库
USE gentle_companion;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
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

-- 创建动态表
CREATE TABLE IF NOT EXISTS posts (
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

-- 插入示例数据
INSERT INTO users (username, email, password, created_at, last_active) VALUES
('测试用户', 'test@example.com', '$2y$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', NOW(), NOW()),
('张三', 'zhangsan@example.com', '$2y$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', NOW(), NOW());

-- 插入示例动态
INSERT INTO posts (user_id, content, is_public, created_at) VALUES
(1, '今天完成了3个番茄钟，感觉效率很高！', 1, NOW()),
(2, '分享一个提高专注度的小技巧：番茄工作法真的很有效', 1, NOW());

-- 查看数据
SELECT * FROM users;
SELECT * FROM posts;