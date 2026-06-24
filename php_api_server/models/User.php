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