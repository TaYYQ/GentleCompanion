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