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