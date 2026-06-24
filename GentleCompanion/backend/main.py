# main.py
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, List, Any
import uuid
from datetime import datetime

app = FastAPI(title="GentleCompanion API")

# ============ 内存数据库 ============
users_db = {}
sessions = {}

# 社交数据存储
posts_db = []                # [{id, user_id, username, content, created_at, is_public, likes, comments, pomodoro_session}]
follows_db = {}              # {user_id: set(following_user_id)}
friend_requests_db = []     # [{id, sender_id, sender_username, receiver_id, created_at, status}]
friends_db = {}             # {user_id: set(friend_id)}
conversations_db = []       # [{id, participants: [str,str], unread_count}]
messages_db = []            # [{id, conversation_id, sender_id, receiver_id, content, created_at, is_read}]
leaderboard_db = {}         # 直接查 users_db 即可

# ============ 数据模型 ============
class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str

class CreatePostRequest(BaseModel):
    content: str
    isPublic: bool = True

class SharePomodoroRequest(BaseModel):
    session: dict
    message: Optional[str] = None

class SendFriendRequestReq(BaseModel):
    userId: str

class RespondFriendRequestReq(BaseModel):
    accept: bool

class SendMessageRequest(BaseModel):
    toUserId: str
    content: str

class APIResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None

# ============ 辅助函数 ============

def get_current_user(token: str):
    if token not in sessions:
        return None
    user_id = sessions[token]
    return users_db.get(user_id)

# ============ Auth 接口 ============

@app.post("/api/auth/login", response_model=APIResponse)
def login(request: LoginRequest):
    user = None
    for u in users_db.values():
        if u["email"] == request.email:
            user = u
            break
    
    if not user or user["password"] != request.password:
        return APIResponse(success=False, message="邮箱或密码错误", data=None)
    
    token = str(uuid.uuid4())
    sessions[token] = user["id"]
    user["lastActive"] = datetime.now().isoformat()
    
    return APIResponse(
        success=True, message="登录成功",
        data={
            "id": user["id"], "username": user["username"], "email": user["email"],
            "token": token, "streakDays": user.get("streakDays", 0),
            "totalPomodoros": user.get("totalPomodoros", 0),
            "totalMinutes": user.get("totalMinutes", 0)
        }
    )

@app.post("/api/auth/register", response_model=APIResponse)
def register(request: RegisterRequest):
    for u in users_db.values():
        if u["email"] == request.email:
            return APIResponse(success=False, message="邮箱已被注册", data=None)
    
    user_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    user = {
        "id": user_id, "username": request.username, "email": request.email,
        "password": request.password, "createdAt": now, "lastActive": now,
        "streakDays": 0, "totalPomodoros": 0, "totalMinutes": 0
    }
    users_db[user_id] = user
    
    token = str(uuid.uuid4())
    sessions[token] = user_id
    
    return APIResponse(
        success=True, message="注册成功",
        data={"id": user_id, "username": request.username, "email": request.email, "token": token}
    )

# ============ User 接口 ============

@app.get("/api/user/profile", response_model=APIResponse)
def get_profile(token: str):
    user = get_current_user(token)
    if not user:
        return APIResponse(success=False, message="未登录或token无效", data=None)
    return APIResponse(
        success=True, message="获取成功",
        data={
            "id": user["id"], "username": user["username"], "email": user["email"],
            "createdAt": user["createdAt"], "lastActive": user["lastActive"],
            "streakDays": user["streakDays"], "totalPomodoros": user["totalPomodoros"],
            "totalMinutes": user["totalMinutes"]
        }
    )

@app.put("/api/user/profile", response_model=APIResponse)
def update_profile(token: str, username: Optional[str] = None):
    user = get_current_user(token)
    if not user:
        return APIResponse(success=False, message="未登录或token无效", data=None)
    if username:
        user["username"] = username
    user["lastActive"] = datetime.now().isoformat()
    return APIResponse(
        success=True, message="更新成功",
        data={"id": user["id"], "username": user["username"], "email": user["email"]}
    )

# ============ Social Feed 接口 ============

@app.get("/api/social/feed", response_model=APIResponse)
def get_feed(page: int = 1, limit: int = 20):
    public_posts = sorted(posts_db, key=lambda p: p["created_at"], reverse=True)
    start = (page - 1) * limit
    end = start + limit
    page_posts = public_posts[start:end]
    formatted = []
    for p in page_posts:
        formatted.append({
            "id": p["id"], "userId": p["user_id"], "username": p["username"],
            "content": p["content"], "createdAt": p["created_at"],
            "isPublic": p["is_public"], "likes": p.get("likes", 0),
            "comments": p.get("comments", 0), "isLiked": False,
            "pomodoroSession": p.get("pomodoro_session")
        })
    return APIResponse(success=True, message="获取成功", data=formatted)

@app.post("/api/social/posts", response_model=APIResponse)
def create_post(request: CreatePostRequest, authorization: Optional[str] = None):
    user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        user = get_current_user(token)
    
    post_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    post = {
        "id": post_id, "user_id": user["id"] if user else "anonymous",
        "username": user["username"] if user else "匿名用户",
        "content": request.content, "created_at": now,
        "is_public": request.isPublic, "likes": 0, "comments": 0,
        "pomodoro_session": None
    }
    posts_db.append(post)
    return APIResponse(success=True, message="发布成功", data={
        "id": post["id"], "userId": post["user_id"], "username": post["username"],
        "content": post["content"], "createdAt": post["created_at"],
        "isPublic": post["is_public"], "likes": 0, "comments": 0,
        "isLiked": False, "pomodoroSession": None
    })

# ============ Like 接口 ============

@app.post("/api/social/posts/{post_id}/like", response_model=APIResponse)
def like_post(post_id: str):
    for p in posts_db:
        if p["id"] == post_id:
            p["likes"] = p.get("likes", 0) + 1
            return APIResponse(success=True, message="点赞成功", data={"likes": p["likes"]})
    return APIResponse(success=False, message="帖子不存在", data=None)

# ============ Pomodoro 分享 ============

@app.post("/api/social/share-pomodoro", response_model=APIResponse)
def share_pomodoro(request: SharePomodoroRequest, authorization: Optional[str] = None):
    user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        user = get_current_user(token)
    
    content = request.message or f"完成了 {request.session.get('duration', 0) // 60} 分钟番茄钟！"
    post_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    post = {
        "id": post_id, "user_id": user["id"] if user else "anonymous",
        "username": user["username"] if user else "匿名用户",
        "content": content, "created_at": now, "is_public": True,
        "likes": 0, "comments": 0, "pomodoro_session": request.session
    }
    posts_db.append(post)
    return APIResponse(success=True, message="分享成功", data={
        "id": post["id"], "userId": post["user_id"], "username": post["username"],
        "content": post["content"], "createdAt": post["created_at"],
        "isPublic": True, "likes": 0, "comments": 0,
        "isLiked": False, "pomodoroSession": request.session
    })

# ============ Follow 接口 ============

@app.post("/api/social/follow/{user_id}", response_model=APIResponse)
def follow_user(user_id: str, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    if current_user["id"] not in follows_db:
        follows_db[current_user["id"]] = set()
    follows_db[current_user["id"]].add(user_id)
    return APIResponse(success=True, message="关注成功", data=True)

@app.post("/api/social/unfollow/{user_id}", response_model=APIResponse)
def unfollow_user(user_id: str, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    if current_user["id"] in follows_db:
        follows_db[current_user["id"]].discard(user_id)
    return APIResponse(success=True, message="取消关注成功", data=True)

@app.get("/api/social/followers", response_model=APIResponse)
def get_followers(authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    followers_list = []
    for uid, following_set in follows_db.items():
        if current_user["id"] in following_set and uid in users_db:
            u = users_db[uid]
            followers_list.append({
                "id": u["id"], "username": u["username"], "email": u["email"],
                "streakDays": u.get("streakDays", 0),
                "totalPomodoros": u.get("totalPomodoros", 0),
                "totalMinutes": u.get("totalMinutes", 0)
            })
    return APIResponse(success=True, message="获取成功", data=followers_list)

@app.get("/api/social/following", response_model=APIResponse)
def get_following(authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    following_list = []
    if current_user["id"] in follows_db:
        for uid in follows_db[current_user["id"]]:
            if uid in users_db:
                u = users_db[uid]
                following_list.append({
                    "id": u["id"], "username": u["username"], "email": u["email"],
                    "streakDays": u.get("streakDays", 0),
                    "totalPomodoros": u.get("totalPomodoros", 0),
                    "totalMinutes": u.get("totalMinutes", 0)
                })
    return APIResponse(success=True, message="获取成功", data=following_list)

# ============ Friend Requests 接口 ============

@app.post("/api/social/friend-requests", response_model=APIResponse)
def send_friend_request(request: SendFriendRequestReq, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    fr_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    friend_requests_db.append({
        "id": fr_id, "senderId": current_user["id"],
        "senderUsername": current_user["username"],
        "receiverId": request.userId, "createdAt": now, "status": "pending"
    })
    return APIResponse(success=True, message="好友请求已发送", data=True)

@app.get("/api/social/friend-requests", response_model=APIResponse)
def get_friend_requests(authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    my_requests = [
        r for r in friend_requests_db
        if r["receiverId"] == current_user["id"] and r.get("status") == "pending"
    ]
    return APIResponse(success=True, message="获取成功", data=my_requests)

@app.post("/api/social/friend-requests/{request_id}/respond", response_model=APIResponse)
def respond_friend_request(request_id: str, req: RespondFriendRequestReq, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    for r in friend_requests_db:
        if r["id"] == request_id and r["receiverId"] == current_user["id"]:
            r["status"] = "accepted" if req.accept else "rejected"
            if req.accept:
                # 双向添加好友
                if r["senderId"] not in friends_db:
                    friends_db[r["senderId"]] = set()
                if current_user["id"] not in friends_db:
                    friends_db[current_user["id"]] = set()
                friends_db[r["senderId"]].add(current_user["id"])
                friends_db[current_user["id"]].add(r["senderId"])
            return APIResponse(success=True, message="处理成功", data=True)
    return APIResponse(success=False, message="好友请求不存在", data=None)

# ============ Friends 接口 ============

@app.get("/api/social/friends", response_model=APIResponse)
def get_friends(authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    friends_list = []
    if current_user["id"] in friends_db:
        for fid in friends_db[current_user["id"]]:
            if fid in users_db:
                u = users_db[fid]
                friends_list.append({
                    "id": u["id"], "userId": u["id"], "username": u["username"],
                    "avatar": None, "lastSeen": u.get("lastActive"),
                    "mutualFriends": 0
                })
    return APIResponse(success=True, message="获取成功", data=friends_list)

@app.delete("/api/social/friends/{user_id}", response_model=APIResponse)
def remove_friend(user_id: str, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    if current_user["id"] in friends_db:
        friends_db[current_user["id"]].discard(user_id)
    if user_id in friends_db:
        friends_db[user_id].discard(current_user["id"])
    return APIResponse(success=True, message="已删除好友", data=True)

# ============ Messages 接口 ============

@app.get("/api/social/conversations", response_model=APIResponse)
def get_conversations(authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    my_convs = [c for c in conversations_db if current_user["id"] in c["participants"]]
    result = []
    for c in my_convs:
        last_msg = None
        conv_msgs = [m for m in messages_db if m["conversation_id"] == c["id"]]
        if conv_msgs:
            lm = sorted(conv_msgs, key=lambda x: x["created_at"], reverse=True)[0]
            last_msg = {
                "id": lm["id"], "conversationId": lm["conversation_id"],
                "senderId": lm["sender_id"], "receiverId": lm["receiver_id"],
                "content": lm["content"], "createdAt": lm["created_at"], "isRead": lm.get("is_read", False)
            }
        unread = sum(1 for m in conv_msgs if not m.get("is_read", False) and m["sender_id"] != current_user["id"])
        result.append({
            "id": c["id"], "participants": c["participants"],
            "lastMessage": last_msg, "unreadCount": unread,
            "updatedAt": last_msg["createdAt"] if last_msg else datetime.now().isoformat()
        })
    return APIResponse(success=True, message="获取成功", data=result)

@app.get("/api/social/conversations/{conversation_id}/messages", response_model=APIResponse)
def get_messages(conversation_id: str, page: int = 1, limit: int = 50, authorization: Optional[str] = None):
    conv_msgs = [m for m in messages_db if m["conversation_id"] == conversation_id]
    conv_msgs = sorted(conv_msgs, key=lambda x: x["created_at"])
    start = (page - 1) * limit
    end = start + limit
    page_msgs = conv_msgs[start:end]
    result = []
    for m in page_msgs:
        result.append({
            "id": m["id"], "conversationId": m["conversation_id"],
            "senderId": m["sender_id"], "receiverId": m["receiver_id"],
            "content": m["content"], "createdAt": m["created_at"],
            "isRead": m.get("is_read", False)
        })
    return APIResponse(success=True, message="获取成功", data=result)

@app.post("/api/social/messages", response_model=APIResponse)
def send_message(request: SendMessageRequest, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    
    # 查找或创建会话
    conv = None
    for c in conversations_db:
        if current_user["id"] in c["participants"] and request.toUserId in c["participants"]:
            conv = c
            break
    if not conv:
        conv = {
            "id": str(uuid.uuid4()),
            "participants": [current_user["id"], request.toUserId],
            "unread_count": 0
        }
        conversations_db.append(conv)
    
    msg = {
        "id": str(uuid.uuid4()),
        "conversation_id": conv["id"],
        "sender_id": current_user["id"],
        "receiver_id": request.toUserId,
        "content": request.content,
        "created_at": datetime.now().isoformat(),
        "is_read": False
    }
    messages_db.append(msg)
    return APIResponse(success=True, message="发送成功", data={
        "id": msg["id"], "conversationId": msg["conversation_id"],
        "senderId": msg["sender_id"], "receiverId": msg["receiver_id"],
        "content": msg["content"], "createdAt": msg["created_at"],
        "isRead": msg["is_read"]
    })

@app.post("/api/social/conversations/{conversation_id}/mark-read", response_model=APIResponse)
def mark_read(conversation_id: str, authorization: Optional[str] = None):
    current_user = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        current_user = get_current_user(token)
    if not current_user:
        return APIResponse(success=False, message="未登录", data=None)
    for m in messages_db:
        if m["conversation_id"] == conversation_id and m["receiver_id"] == current_user["id"]:
            m["is_read"] = True
    return APIResponse(success=True, message="已标记已读", data=True)

# ============ Leaderboard 接口 ============

@app.get("/api/social/leaderboard", response_model=APIResponse)
def get_leaderboard(category: str = "streak", period: str = "all_time"):
    all_users = list(users_db.values())
    if category == "streak" or category == "streakDays":
        all_users.sort(key=lambda u: u.get("streakDays", 0), reverse=True)
    elif category == "totalPomodoros" or category == "total_pomodoros":
        all_users.sort(key=lambda u: u.get("totalPomodoros", 0), reverse=True)
    elif category == "totalMinutes" or category == "total_minutes":
        all_users.sort(key=lambda u: u.get("totalMinutes", 0), reverse=True)
    elif category == "focusScore" or category == "focus_score":
        all_users.sort(key=lambda u: u.get("totalMinutes", 0), reverse=True)
    
    entries = []
    for rank, u in enumerate(all_users[:50], 1):
        entries.append({
            "id": u["id"], "userId": u["id"], "username": u["username"],
            "score": u.get("totalPomodoros", 0) * 10 + u.get("streakDays", 0) * 5,
            "rank": rank,
            "streakDays": u.get("streakDays", 0),
            "totalPomodoros": u.get("totalPomodoros", 0),
            "totalMinutes": u.get("totalMinutes", 0)
        })
    return APIResponse(success=True, message="获取成功", data=entries)

# ============ Health ============

@app.get("/")
def health():
    return {"status": "ok", "service": "GentleCompanion API", "version": "1.0.0"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
