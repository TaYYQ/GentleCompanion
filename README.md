# GentleCompanion · 温柔点

> A gentle mental wellness companion for modern city dwellers.  
> 为都市人打造的心理健康陪伴应用——用温柔的话语、舒缓的界面、实用的工具，帮你缓解压力、找回内心的节奏。

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014.0%2B%20%7C%20iOS%2017.0%2B-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Swift">
  <img src="https://img.shields.io/badge/UI-SwiftUI-blue" alt="SwiftUI">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/stars-⭐%20star%20to%20support-brightgreen" alt="Stars">
</p>

## 📸 应用截图

### iOS 端

| 陪伴首页 | 番茄钟 | 悄悄话 |
|:---:|:---:|:---:|
| ![home](screenshots/ios-home.png) | ![pomodoro](screenshots/ios-pomodoro.png) | ![message](screenshots/ios-message.png) |
| **温柔墙** | **我的** | **社区动态** |
| ![wall](screenshots/ios-wall.png) | ![profile](screenshots/ios-profile.png) | ![social](screenshots/ios-social.png) |

### macOS 端

| 情绪陪伴 | 呼吸练习 | 小游戏 |
|:---:|:---:|:---:|
| ![emotion](screenshots/emotion.png) | ![breathing](screenshots/breathing.png) | ![garden](screenshots/garden.png) |

---

## 功能特性

### 🌟 启动体验（iOS）
- **电影级启动动画**：6 阶段渐进式动画（心形淡入 → 心跳脉动 → 色彩演变 → 柔光极光 → 标题逐字浮现 → 优雅渐隐）
- 首次启动流程引导：启动动画 → 服务器配置 → 激活/注册 → 主界面

### 🏠 情绪陪伴
- **时间感知问候**：早上好/下午好/晚上好/夜深了
- **7 种情绪识别**：丧/空、疲惫、焦虑、孤独、复杂开心、压抑愤怒、其他
- 每种情绪配有 8+ 条温柔治愈文案（共 50+ 条）
- 情绪历史追踪，回顾心情变化轨迹
- 天气联动情绪文案（WeatherKit）

### ⏱️ 番茄钟
- **5 种预设时长**：15 / 25 / 30 / 45 / 60 分钟
- 专注意图设置，完成后的番茄钟分享
- Liquid Glass 液态玻璃风格面板，呼吸光晕 + 进度环
- **灵动岛（Live Activity）**：后台实时显示剩余时间和进度
- 浮动粒子动画，会话计数器

### 🌬️ 呼吸练习
- **4-7-8 呼吸法**（iOS）：吸气 4s → 屏息 7s → 呼气 8s
- **4-4-6-2 呼吸法**（macOS）：吸气 4s → 屏息 4s → 呼气 6s → 屏息 2s
- 暗色氛围背景 + 粒子动画引导

### 💬 悄悄话（iOS 私信聊天）
- 微信风格气泡式聊天界面
- 会话列表：最后消息预览、未读角标、时间显示
- 新建会话：输入对方用户 ID 发起对话
- 本地持久化（UserDefaults）+ 远程同步
- 进入聊天自动隐藏底部导航

### 🧱 温柔墙
- 匿名发布心情消息
- **6 种情绪标签**：温暖、鼓励、希望、感恩、坚强、温柔
- 点赞功能和漂浮背景粒子动画
- 空状态引导首次使用

### 👥 社区动态
- 发布心情动态，选择情绪标签
- 点赞/取消点赞
- 预置种子数据，本地存储

### 🎮 放松小游戏（macOS）
- **泡泡解压 (BubblePop)**：点击泡泡释放压力，连击系统
- **花园物语 (Garden)**：12 格花园养成，8 种花卉图鉴
- **律动圆环 (Rhythm)**：节奏踩点游戏，combo 连击

### 👤 个人中心（iOS）
- 个人资料卡片：头像、昵称、性别、简介
- **30 种 Emoji 头像** + 本地照片上传
- 多主题切换预览
- 每日提醒开关、用户协议、隐私政策

### 🔐 账号系统
- 本地账号注册/登录（PBKDF2-SHA256）
- Apple 登录、游客模式
- 激活流程 + 欢迎动画

### ⚙️ 设置（macOS）
- 背景音效：雨声 / 风声 / 海浪 / 壁炉
- 沉浸全屏 / 悬浮窗模式
- 服务器连接配置与诊断
- 情绪分析：概览 / 分布 / 趋势

### 🌐 gentle-landing 品牌官网
- Next.js 14 + React 18 + Tailwind CSS + TypeScript
- 11 个 Section 单页 Landing Page
- 下载页（macOS Intel / Apple Silicon）
- 中英双语国际化（i18n）

---

## 技术架构

```
APP 2/
├── GentleCompanion/                      # iOS + macOS 双端 SwiftUI 应用
│   ├── GentiOSApp.swift                  # iOS @main 入口
│   ├── GentleCompanionApp.swift          # macOS @main 入口
│   ├── ContentView.swift                 # 内容入口
│   ├── Design.swift                      # 集中式设计系统 (Token)
│   ├── Package.swift                     # SPM 包定义
│   ├── Models/                           # 数据层
│   │   ├── Emotion.swift                 # 情绪模型 + 文案
│   │   ├── AccountManager.swift          # 本地账号系统
│   │   ├── AppMode.swift                 # 三模式系统
│   │   ├── NetworkService.swift          # HTTP 客户端
│   │   ├── SocialService.swift           # 社交服务
│   │   └── ...
│   ├── Views/                            # UI 层 (SwiftUI，34 个视图文件)
│   │   ├── iOS 端视图
│   │   │   ├── GentiOSMainView.swift     # 5 Tab 主界面 (Liquid Glass)
│   │   │   ├── GentiOSHomeView.swift     # 陪伴首页 + 情绪记录
│   │   │   ├── PomodoroiOSView.swift     # 番茄钟 + 灵动岛
│   │   │   ├── BreathingiOSView.swift    # 4-7-8 呼吸引导
│   │   │   ├── GentiOSMessageView.swift  # 悄悄话私信
│   │   │   ├── GentiOSWallView.swift     # 温柔墙
│   │   │   ├── GentiOSSocialView.swift   # 社区动态
│   │   │   ├── GentiOSProfileView.swift  # 个人中心
│   │   │   ├── ActivationView.swift      # 注册/登录/激活
│   │   │   ├── WelcomeView.swift         # 欢迎动画
│   │   │   └── ...
│   │   ├── macOS 端视图
│   │   │   ├── GentleMainView.swift      # 主页面
│   │   │   ├── PomodoroView.swift        # 番茄钟
│   │   │   ├── BreathingView.swift       # 呼吸引导
│   │   │   ├── SocialFeedView.swift      # 社交动态
│   │   │   ├── GentleWallView.swift      # 温柔墙
│   │   │   ├── AuthView.swift            # 登录/注册
│   │   │   ├── SettingsView.swift        # 设置
│   │   │   ├── BubblePopGame.swift       # 泡泡解压
│   │   │   ├── GardenGame.swift          # 花园物语
│   │   │   ├── RhythmGame.swift          # 律动圆环
│   │   │   └── ...
│   │   └── 共享组件
│   ├── PomodoroWidget/                   # iOS Widget Extension (灵动岛)
│   ├── Assets.xcassets/                  # 资源文件
│   └── GentleCompanion.entitlements      # 权限配置
│
├── gentle-landing/                       # Next.js 品牌官网
│   ├── src/
│   │   ├── app/                          # App Router 页面
│   │   │   ├── page.tsx                  # 首页 (11 Section 组件)
│   │   │   └── download/page.tsx         # 下载页
│   │   ├── components/                   # 组件
│   │   │   ├── Hero.tsx                  # 主标题 + 下载入口
│   │   │   ├── Features.tsx              # 6 大功能卡片
│   │   │   ├── Weather.tsx               # 天气心情联动
│   │   │   ├── Pomodoro.tsx              # 番茄钟介绍
│   │   │   ├── Breathing.tsx             # 呼吸法介绍
│   │   │   ├── GentleWall.tsx            # 温柔墙展示
│   │   │   ├── Story.tsx                 # 品牌故事
│   │   │   ├── Developer.tsx             # 开发者介绍
│   │   │   ├── Download.tsx              # 下载号召
│   │   │   └── Footer.tsx
│   │   ├── contexts/LangContext.tsx      # 中英双语切换
│   │   └── locales/                      # i18n 翻译文件
│   ├── public/                           # 静态资源
│   ├── next.config.js
│   ├── tailwind.config.ts
│   └── package.json
│
└── backend/
    ├── main.py                           # FastAPI Python 后端
    └── requirements.txt
```

### 技术栈

| 层级 | 技术 |
|------|------|
| **移动端 UI** | SwiftUI (iOS 17+ / macOS 14+) |
| **灵动岛** | ActivityKit + Widget Extension |
| **设计** | 集中式 Design Token 系统 + Liquid Glass 液态玻璃风格 |
| **状态管理** | Combine (@StateObject, @ObservedObject, @Published) |
| **网络** | async/await + URLSession |
| **认证** | CryptoKit + CommonCrypto (PBKDF2) |
| **Apple 服务** | AuthenticationServices, WeatherKit, CoreLocation, UserNotifications |
| **官网** | Next.js 14 + React 18 + TypeScript + Tailwind CSS |
| **后端** | FastAPI (Python 3.11+) + PHP 7.4+ |
| **数据库** | 内存数据库 (开发) / MySQL (生产) |
| **部署** | Docker + Nginx 反向代理 |

### 设计系统

所有颜色、字体、间距、圆角、阴影通过 `Design.swift` 集中管理。iOS 端采用 **Liquid Glass 液态玻璃**设计语言，macOS 端支持多主题自动检测。

---

## 快速开始

### 前置要求

- **macOS 14.0+**
- **Xcode 16+**
- **Swift 6.0**
- **iOS 17.0+**（移动端）
- **Node.js 18+**（官网项目）

### 构建运行

```bash
# 克隆仓库
git clone https://github.com/TaYYQ/GentleCompanion.git
cd "APP 2"

# === iOS 端 ===
# 在 Xcode 中打开项目，选择 GentiOSApp scheme + 真机/模拟器
open GentleCompanion/GentleCompanion.xcodeproj
# 选择 GentiOSApp target，⌘R 运行

# === macOS 端 ===
# 选择 GentleCompanion target，⌘R 运行
# 或命令行构建：
cd GentleCompanion
swift build

# === 品牌官网 ===
cd gentle-landing
npm install
npm run dev          # 开发模式 http://localhost:3000
npm run build        # 生产构建

### 连接你的服务器

1. 部署后端 API 服务（详见下方 [部署指南](#部署指南)）
2. 打开 App → 点击右上角 **设置** ⚙️
3. 在「服务器连接」中输入你的 **IP 地址**和**端口**
4. 点击 **重新检测**，绿灯亮起即连接成功

> 💡 默认地址为 `127.0.0.1:80`，适用于本机部署。连接远程服务器请输入公网 IP。

---

## API 接口

所有 API 位于 `/api/` 路径下：

| 分类 | 端点 | 说明 |
|------|------|------|
| **Auth** | `POST /api/auth/register` | 注册 |
| | `POST /api/auth/login` | 登录 |
| **User** | `GET /api/user/profile` | 获取个人资料 |
| | `PUT /api/user/profile` | 更新个人资料 |
| **Social** | `GET /api/social/feed` | 动态列表 |
| | `POST /api/social/posts` | 发布动态 |
| | `POST /api/social/posts/{id}/like` | 点赞 |
| | `POST /api/social/share-pomodoro` | 番茄钟分享 |
| **Follow** | `POST /api/social/follow/{userId}` | 关注用户 |
| | `POST /api/social/unfollow/{userId}` | 取关 |
| | `GET /api/social/followers` | 粉丝列表 |
| | `GET /api/social/following` | 关注列表 |
| **Friends** | `GET /api/social/friends` | 好友列表 |
| | `POST /api/social/friend-requests` | 发送好友请求 |
| | `POST /api/social/friend-requests/{id}/respond` | 处理好友请求 |
| **Messages** | `GET /api/social/conversations` | 会话列表 |
| | `POST /api/social/messages` | 发送消息 |
| **Leaderboard** | `GET /api/social/leaderboard` | 排行榜 |

---

## 部署指南

### 使用 Docker

```bash
cd GentleCompanion
docker compose up -d --build
```

服务架构：
```
nginx (:80) → /api/* → FastAPI (:8000)
            → *.php  → PHP-FPM (:9000) → MySQL (:3306)
```

### 手动部署（宝塔面板）

1. 将 `backend/main.py` 上传至你的服务器
2. 安装 Python 3.11+ 及依赖：`pip install fastapi uvicorn pydantic`
3. 启动服务：`nohup python3 main.py &`
4. 配置 Nginx 反向代理 `127.0.0.1:8000`

---

## 项目计划

- [x] 情绪陪伴系统
- [x] 番茄钟专注
- [x] 呼吸练习
- [x] 小游戏（macOS）
- [x] 温柔墙
- [x] 社交网络
- [x] 账号系统
- [x] 天气集成
- [x] iOS 端适配（5 Tab 主界面 + 34 视图）
- [x] 灵动岛（Live Activity）
- [x] 悄悄话私信聊天
- [x] 品牌官网（gentle-landing）
- [ ] 数据持久化（SQLite / CoreData）
- [ ] 单元测试覆盖
- [ ] CI/CD 自动构建

---

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feat/amazing-feature`
3. 提交更改：`git commit -m 'feat: add amazing feature'`
4. 推送分支：`git push origin feat/amazing-feature`
5. 发起 Pull Request

---

## 开源协议

本项目采用 [MIT License](LICENSE) 开源。
