# LocketBetaFrontend

A comprehensive Flutter-based social messaging and photo-sharing application that enables users to connect with friends, share moments through photos, and communicate in real-time. LocketBetaFrontend is a full-featured mobile application designed for iOS, Android, Web, Windows, macOS, and Linux platforms.

---

## Table of Contents

- [Features and Modules](#features-and-modules)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Main Screens and Navigation Flow](#main-screens-and-navigation-flow)
- [API Integration](#api-integration)
- [Team Members](#team-members)
- [License](#license)

---

## Features and Modules

### 1. Authentication Module (Login & Signup)
The authentication system provides secure user registration and login capabilities. Users can create new accounts with email/username validation and authenticate securely. The module handles session management and credential verification through backend APIs.

### 2. Landing and Navigation
The landing screen serves as the entry point for the application. It manages the initial navigation flow, determining whether users should be directed to login, signup, or the main application dashboard based on their authentication status.

### 3. Home Module
The home screen displays the main dashboard with an overview of user activities. It provides quick access to all primary features including friends list, photo feed, messages, and recommendations. This module aggregates key information and provides navigation to other sections.

### 4. Photo Module
A comprehensive photo management system allowing users to capture, upload, and manage photos. Features include:
- Real-time camera access and photo capture
- Image compression for optimized storage
- Photo upload to backend servers
- Photo gallery browsing and management
- Caption support for photos
- Photo sharing capabilities

### 5. Friends Module
Complete friend management functionality including:
- Friend list display with status indicators
- Friend search and discovery
- Friend recommendation engine based on user preferences
- Friend request management (send, receive, accept, decline)
- Friend profile viewing
- Mutual friend identification

### 6. Messenger Module
Real-time communication system with:
- Chat interface for messaging with friends
- Real-time message synchronization via WebSocket
- Message history retrieval
- User typing indicators
- Online/offline status tracking
- Message notifications

### 7. History Module
Maintains a comprehensive activity log including:
- Message history
- Photo upload history
- Friend activity timeline
- Action timestamps and details

### 8. Profile Module
User profile management and customization:
- Profile information display and editing
- User avatar management
- Bio and status updates
- Profile statistics (friends count, photos count)
- Privacy settings
- Account information

### 9. Settings Module
Application configuration and preferences:
- Notification settings
- Privacy preferences
- Account security options
- App preferences and display settings
- Data management options

### 10. Camera Module
Advanced camera functionality powered by the camera package:
- Multiple camera support (front and rear)
- Real-time preview
- Photo capture capability
- Camera initialization and management

### 11. Logout Module
Secure session termination:
- Graceful logout process
- Session cleanup
- Credential removal
- Return to authentication flow

---

## Project Structure

```
locket_beta/
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── api/                               # API integration layer
│   │   ├── photo_api.dart                # Photo CRUD operations
│   │   └── friends/
│   │       ├── friend_api.dart           # Friend management APIs
│   │       ├── friendRequest_api.dart    # Friend request operations
│   │       └── recommendation_api.dart   # Friend recommendations
│   ├── model/                             # Data models
│   │   ├── user_model.dart               # User data structure
│   │   ├── photo_model.dart              # Photo data structure
│   │   ├── message_model.dart            # Message data structure
│   │   ├── chat_model.dart               # Chat data structure
│   │   ├── friend_model.dart             # Friend data structure
│   │   ├── friend_request_model.dart     # Friend request structure
│   │   ├── profile_model.dart            # Profile data structure
│   │   ├── signup_model.dart             # Signup request structure
│   │   ├── login_model.dart              # Login request structure
│   │   └── user_settings_model.dart      # User settings structure
│   ├── camera/                            # Camera module
│   │   └── cubit/
│   │       └── camera_cubit.dart         # Camera state management
│   ├── photo/                             # Photo module
│   │   └── cubit/
│   │       └── photo_cubit.dart          # Photo state management
│   ├── friends/                           # Friends module
│   │   └── cubit/
│   │       └── friend_cubit.dart         # Friend state management
│   ├── messenger/                         # Messaging module
│   │   ├── chat/
│   │   │   └── chat.dart                 # Chat UI and logic
│   │   ├── message/                      # Message handling
│   │   └── imagPicker/                   # Image selection for messages
│   ├── home/                              # Home screen module
│   ├── landing/                           # Landing/splash screen
│   │   └── views/
│   │       └── landing_ui.dart           # Landing UI component
│   ├── login/                             # Login module
│   ├── signup/                            # Signup module
│   │   └── cubit/
│   │       └── signup_cubit.dart         # Signup state management
│   ├── profile/                           # User profile module
│   ├── settings/                          # Settings module
│   ├── history/                           # Activity history module
│   ├── logout/                            # Logout functionality
│   │   └── views/
│   │       └── logout_ui.dart            # Logout UI component
│   └── utils/                             # Utility functions and helpers
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── web/                                   # Web platform code
├── windows/                               # Windows platform code
├── macos/                                 # macOS platform code
├── linux/                                 # Linux platform code
├── assets/
│   └── images/                            # Application images and assets
├── pubspec.yaml                           # Flutter dependencies
├── analysis_options.yaml                  # Dart analysis configuration
├── devtools_options.yaml                  # DevTools configuration
└── README.md                              # This file
```

---

## Installation

### Prerequisites

- Flutter SDK 3.2.3 or higher
- Dart 3.2.3 or higher
- Android SDK (API level 21 or higher) for Android development
- Xcode 13 or higher for iOS development
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)
- Git for version control

### Step 1: Install Flutter SDK

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract the Flutter SDK to a desired location
3. Add Flutter to your PATH environment variable:
   - On Windows: Add `C:\path\to\flutter\bin` to your PATH
   - On macOS/Linux: Add `export PATH="$PATH:/path/to/flutter/bin"` to your shell profile
4. Verify installation:
   ```bash
   flutter doctor
   ```

### Step 2: Clone the Repository

```bash
git clone https://github.com/sangoonthego/locket-beta.git
cd locket-beta
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

This command will install all required packages specified in `pubspec.yaml`:
- **flutter_bloc** (9.1.1): State management
- **intl** (0.18.1): Internationalization
- **equatable** (2.0.5): Value equality
- **path_provider** (2.1.4): File system access
- **dio** (5.9.0): HTTP client
- **cupertino_icons** (1.0.2): iOS-style icons
- **camera** (0.10.5+7): Camera functionality
- **image_picker** (0.8.7+6): Image selection
- **flutter_image_compress** (2.4.0): Image compression
- **web_socket_channel** (2.4.0): WebSocket communication
- **shared_preferences** (2.5.3): Local storage

### Step 4: Platform-Specific Setup

#### For Android:
```bash
cd android
gradlew assemble
cd ..
```

#### For iOS:
```bash
cd ios
pod install
cd ..
```

#### For Web:
```bash
flutter config --enable-web
```

#### For Windows, macOS, or Linux:
```bash
flutter config --enable-windows
flutter config --enable-macos
flutter config --enable-linux
```

---

## Running the Application

### On Android Emulator

1. Start the Android emulator:
   ```bash
   emulator -avd <your_emulator_name>
   ```

2. Verify device connection:
   ```bash
   flutter devices
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### On iOS Simulator

1. Start the iOS simulator:
   ```bash
   open -a Simulator
   ```

2. Run the application:
   ```bash
   flutter run
   ```

### On Physical Device

1. Connect your device via USB and enable Developer Mode
2. Verify device connection:
   ```bash
   flutter devices
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### On Web

```bash
flutter run -d chrome
```

### On Windows, macOS, or Linux

```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### Development Mode with Hot Reload

For faster development, use hot reload:
```bash
flutter run
```

Press `r` to hot reload, `R` to hot restart, and `q` to quit.

---

## Main Screens and Navigation Flow

### Application Flow Diagram

```
Landing Screen
    ↓
┌───────────────────┐
│ Authentication?   │
├───────────────────┤
│ No → Login/Signup │
│ Yes → Home        │
└───────────────────┘
    ↓
┌─────────────────────────────────────────┐
│          Home Screen (Dashboard)        │
├─────────────────────────────────────────┤
│ ├─ Photo Feed                           │
│ ├─ Friends List                         │
│ ├─ Messages/Chat                        │
│ ├─ Recommendations                      │
│ └─ Navigation Menu                      │
└─────────────────────────────────────────┘
    ↓ (User Navigation)
    ├─ Photo Module
    │  ├─ Camera Capture
    │  ├─ Image Selection
    │  └─ Photo Upload
    ├─ Friends Module
    │  ├─ Friends List
    │  ├─ Friend Requests
    │  ├─ Recommendations
    │  └─ Friend Search
    ├─ Messenger Module
    │  ├─ Chat List
    │  ├─ Chat Screen
    │  └─ Message History
    ├─ Profile Module
    │  ├─ View Profile
    │  └─ Edit Profile
    ├─ Settings Module
    │  ├─ Notification Settings
    │  ├─ Privacy Settings
    │  └─ Account Settings
    ├─ History Module
    │  └─ Activity Timeline
    └─ Logout
       └─ Return to Authentication
```

### Main Screens

**Landing Screen**: Initial entry point displaying branding and determining user navigation path based on authentication status.

**Login Screen**: Secure user authentication with email/username and password credentials, error handling, and forgot password options.

**Signup Screen**: New user registration with form validation, email verification, and account creation.

**Home/Dashboard Screen**: Central hub displaying user's photo feed, friend list summary, message count, and quick action buttons for main features.

**Photo Screen**: Gallery view of user's photos with upload capabilities, photo details, and sharing options.

**Chat/Messenger Screen**: Real-time chat interface with message history, typing indicators, and online status tracking.

**Friends Screen**: Complete friend management interface with friend list, friend requests, and recommendation engine.

**Profile Screen**: User profile display and editing capabilities including avatar, bio, statistics, and privacy settings.

**Settings Screen**: Application configuration including notifications, privacy, security, and general preferences.

**History Screen**: Activity timeline showing recent photos, messages, and friend activities with timestamps.

---

## API Integration

The application communicates with a backend REST API server (running on `http://10.0.2.2:8000/api` for emulator testing). All API communications use JSON format with proper error handling and timeout management.

### Base Configuration

```
API Base URL: http://10.0.2.2:8000/api
Connection Timeout: 15 seconds
Receive Timeout: 10 seconds
Content Type: application/json
```

### Main API Endpoints

#### Photo Endpoints
- **POST** `/photos` - Upload a new photo
  - Request: `{ userId, imageUrl, caption }`
  - Response: `{ photo: PhotoModel }`

- **GET** `/photos` - Fetch photos with pagination
  - Query: `?page=1&limit=10&userId=optional`
  - Response: `{ photos: [PhotoModel] }`

- **GET** `/photos/:id` - Get specific photo details
  - Response: `PhotoModel`

- **PUT** `/photos/:id` - Update photo metadata
  - Request: `{ imageUrl, caption }`
  - Response: `{ photo: PhotoModel }`

- **DELETE** `/photos/:id` - Delete a photo
  - Response: `{ success: boolean }`

#### Friend Endpoints
- **GET** `/friends` - Get user's friends list
  - Response: `{ friends: [FriendModel] }`

- **GET** `/friends/recommendations` - Get friend recommendations
  - Response: `{ recommendations: [UserModel] }`

- **POST** `/friend-requests` - Send friend request
  - Request: `{ recipientId }`
  - Response: `{ request: FriendRequestModel }`

- **GET** `/friend-requests` - Get pending friend requests
  - Response: `{ requests: [FriendRequestModel] }`

- **PUT** `/friend-requests/:id/accept` - Accept friend request
  - Response: `{ success: boolean }`

- **PUT** `/friend-requests/:id/decline` - Decline friend request
  - Response: `{ success: boolean }`

#### User Endpoints
- **GET** `/users/:id` - Get user profile
  - Response: `UserModel`

- **PUT** `/users/:id` - Update user profile
  - Request: `{ bio, avatar, status }`
  - Response: `UserModel`

- **POST** `/auth/signup` - Register new user
  - Request: `SignupModel`
  - Response: `{ user: UserModel, token: string }`

- **POST** `/auth/login` - User login
  - Request: `{ email/username, password }`
  - Response: `{ user: UserModel, token: string }`

#### Message Endpoints
- **GET** `/messages` - Get message history
  - Query: `?chatId=value&limit=50`
  - Response: `{ messages: [MessageModel] }`

- **WebSocket** `ws://10.0.2.2:8000/socket` - Real-time messaging
  - Enables live chat with instant message delivery and typing indicators

### API Communication

All API requests are handled through specialized service classes:
- `PhotoApi`: Manages photo CRUD operations
- `FriendApi`: Handles friend management
- `FriendRequestApi`: Manages friend requests
- `RecommendationApi`: Provides friend recommendations

### Error Handling

The application implements comprehensive error handling:
- Network timeout management
- HTTP error code handling
- Graceful error messages to users
- Automatic retry mechanisms for transient failures
- Detailed logging for debugging

### WebSocket Integration

Real-time messaging uses WebSocket connections for:
- Instant message delivery
- Typing indicators
- Online status updates
- Connection persistence with automatic reconnection

---

## Team Members

- **Le Duong Huy** - Lead Developer
- **Tran Quoc Dat** - Full Stack Developer
- **Tang Ngoc Hau** - UI/UX Developer
- **Nguyen Tuan Ngoc** - Backend Integration Developer

---

## License

This project is proprietary and confidential. All rights reserved.

---

# LocketBetaFrontend (日本語版)

ユーザーが友達と繋がり、写真を通じて瞬間を共有し、リアルタイムで通信できる包括的なFlutterベースのソーシャルメッセージング・写真共有アプリケーションです。LocketBetaFrontendはiOS、Android、Web、Windows、macOS、Linuxプラットフォーム対応の完全機能付きモバイルアプリケーションです。

---

## 目次

- [機能とモジュール](#機能とモジュール)
- [プロジェクト構造](#プロジェクト構造)
- [インストール](#インストール)
- [アプリケーションの実行](#アプリケーションの実行)
- [メイン画面とナビゲーションフロー](#メイン画面とナビゲーションフロー)
- [API統合](#api統合)
- [チームメンバー](#チームメンバー)
- [ライセンス](#ライセンス)

---

## 機能とモジュール

### 1. 認証モジュール(ログイン・サインアップ)
安全なユーザー登録とログイン機能を提供します。ユーザーはメール/ユーザー名の検証と共に新規アカウントを作成し、安全に認証できます。このモジュールはセッション管理と認証情報の検証をバックエンドAPIを通じて処理します。

### 2. ランディングおよびナビゲーション
ランディング画面はアプリケーションのエントリーポイントとして機能します。認証ステータスに基づいて、ユーザーがログイン、サインアップ、またはメインアプリケーションダッシュボードへ遷移するかを判定します。

### 3. ホームモジュール
ユーザーアクティビティの概要を表示するメインダッシュボードです。友達リスト、写真フィード、メッセージ、推奨事項など、すべての主要機能への迅速なアクセスを提供します。

### 4. 写真モジュール
写真の取得、アップロード、管理を可能にする包括的なシステムです:
- リアルタイムカメラアクセスおよび写真撮影
- ストレージ最適化のための画像圧縮
- バックエンドサーバーへの写真アップロード
- 写真ギャラリーの閲覧・管理
- キャプション機能
- 写真共有機能

### 5. 友達モジュール
完全な友達管理機能を含みます:
- ステータスインジケーター付き友達リスト表示
- 友達検索と発見
- ユーザー設定に基づいた友達推奨エンジン
- 友達リクエスト管理(送信、受取、受諾、拒否)
- 友達プロフィール表示
- 相互友達の識別

### 6. メッセンジャーモジュール
リアルタイム通信システム:
- 友達とのチャットインターフェース
- WebSocketを通じたリアルタイムメッセージ同期
- メッセージ履歴の取得
- ユーザータイピング表示
- オンライン/オフラインステータス追跡
- メッセージ通知

### 7. 履歴モジュール
包括的なアクティビティログを保持:
- メッセージ履歴
- 写真アップロード履歴
- 友達アクティビティタイムライン
- アクションのタイムスタンプと詳細

### 8. プロフィールモジュール
ユーザープロフィール管理とカスタマイズ:
- プロフィール情報の表示と編集
- ユーザーアバター管理
- プロフィール説明とステータス更新
- プロフィール統計(友達数、写真数)
- プライバシー設定
- アカウント情報

### 9. 設定モジュール
アプリケーション設定と環境設定:
- 通知設定
- プライバシー設定
- アカウントセキュリティオプション
- アプリ設定と表示オプション
- データ管理オプション

### 10. カメラモジュール
カメラパッケージによるハイレベルなカメラ機能:
- 複数カメラ対応(前後カメラ)
- リアルタイムプレビュー
- 写真撮影機能
- カメラの初期化と管理

### 11. ログアウトモジュール
安全なセッション終了:
- グレースフルなログアウトプロセス
- セッションクリーンアップ
- 認証情報削除
- 認証フローへの返却

---

## プロジェクト構造

```
locket_beta/
├── lib/
│   ├── main.dart                          # アプリケーションエントリーポイント
│   ├── api/                               # API統合レイヤー
│   │   ├── photo_api.dart                # 写真CRUD操作
│   │   └── friends/
│   │       ├── friend_api.dart           # 友達管理API
│   │       ├── friendRequest_api.dart    # 友達リクエスト操作
│   │       └── recommendation_api.dart   # 友達推奨事項
│   ├── model/                             # データモデル
│   │   ├── user_model.dart               # ユーザーデータ構造
│   │   ├── photo_model.dart              # 写真データ構造
│   │   ├── message_model.dart            # メッセージデータ構造
│   │   ├── chat_model.dart               # チャットデータ構造
│   │   ├── friend_model.dart             # 友達データ構造
│   │   ├── friend_request_model.dart     # 友達リクエスト構造
│   │   ├── profile_model.dart            # プロフィールデータ構造
│   │   ├── signup_model.dart             # サインアップリクエスト構造
│   │   ├── login_model.dart              # ログインリクエスト構造
│   │   └── user_settings_model.dart      # ユーザー設定構造
│   ├── camera/                            # カメラモジュール
│   │   └── cubit/
│   │       └── camera_cubit.dart         # カメラ状態管理
│   ├── photo/                             # 写真モジュール
│   │   └── cubit/
│   │       └── photo_cubit.dart          # 写真状態管理
│   ├── friends/                           # 友達モジュール
│   │   └── cubit/
│   │       └── friend_cubit.dart         # 友達状態管理
│   ├── messenger/                         # メッセージングモジュール
│   │   ├── chat/
│   │   │   └── chat.dart                 # チャットUIおよび処理
│   │   ├── message/                      # メッセージ処理
│   │   └── imagPicker/                   # メッセージの画像選択
│   ├── home/                              # ホーム画面モジュール
│   ├── landing/                           # ランディング/スプラッシュ画面
│   │   └── views/
│   │       └── landing_ui.dart           # ランディングUIコンポーネント
│   ├── login/                             # ログインモジュール
│   ├── signup/                            # サインアップモジュール
│   │   └── cubit/
│   │       └── signup_cubit.dart         # サインアップ状態管理
│   ├── profile/                           # ユーザープロフィールモジュール
│   ├── settings/                          # 設定モジュール
│   ├── history/                           # アクティビティ履歴モジュール
│   ├── logout/                            # ログアウト機能
│   │   └── views/
│   │       └── logout_ui.dart            # ログアウトUIコンポーネント
│   └── utils/                             # ユーティリティ関数ヘルパー
├── android/                               # Android ネイティブコード
├── ios/                                   # iOS ネイティブコード
├── web/                                   # Webプラットフォームコード
├── windows/                               # Windowsプラットフォームコード
├── macos/                                 # macOSプラットフォームコード
├── linux/                                 # Linuxプラットフォームコード
├── assets/
│   └── images/                            # アプリケーション画像とアセット
├── pubspec.yaml                           # Flutter依存関係
├── analysis_options.yaml                  # Dart分析設定
├── devtools_options.yaml                  # DevTools設定
└── README.md                              # このファイル
```

---

## インストール

### 前提条件

- Flutter SDK 3.2.3以上
- Dart 3.2.3以上
- Android SDK (API レベル 21以上)
- Xcode 13以上
- コードエディター(VS Code、Android Studio、IntelliJ IDEA)
- Gitバージョン管理

### ステップ1: Flutter SDKのインストール

1. [flutter.dev](https://flutter.dev/docs/get-started/install)からFlutterをダウンロード
2. 希望のロケーションにFlutter SDKを抽出
3. PATHにFlutterを追加:
   - Windows: `C:\path\to\flutter\bin`をPATHに追加
   - macOS/Linux: シェルプロファイルに`export PATH="$PATH:/path/to/flutter/bin"`を追加
4. インストール確認:
   ```bash
   flutter doctor
   ```

### ステップ2: リポジトリのクローン

```bash
git clone https://github.com/sangoonthego/locket-beta.git
cd locket-beta
```

### ステップ3: 依存関係のインストール

```bash
flutter pub get
```

このコマンドは`pubspec.yaml`で指定されたすべての必要なパッケージをインストール:
- **flutter_bloc** (9.1.1): 状態管理
- **intl** (0.18.1): 国際化
- **equatable** (2.0.5): 値の等価性
- **path_provider** (2.1.4): ファイルシステムアクセス
- **dio** (5.9.0): HTTPクライアント
- **cupertino_icons** (1.0.2): iOSスタイルアイコン
- **camera** (0.10.5+7): カメラ機能
- **image_picker** (0.8.7+6): 画像選択
- **flutter_image_compress** (2.4.0): 画像圧縮
- **web_socket_channel** (2.4.0): WebSocket通信
- **shared_preferences** (2.5.3): ローカルストレージ

### ステップ4: プラットフォーム固有のセットアップ

#### Android用:
```bash
cd android
gradlew assemble
cd ..
```

#### iOS用:
```bash
cd ios
pod install
cd ..
```

#### Web用:
```bash
flutter config --enable-web
```

#### Windows、macOS、Linux用:
```bash
flutter config --enable-windows
flutter config --enable-macos
flutter config --enable-linux
```

---

## アプリケーションの実行

### Androidエミュレーターで実行

1. Androidエミュレーターを起動:
   ```bash
   emulator -avd <your_emulator_name>
   ```

2. デバイス接続確認:
   ```bash
   flutter devices
   ```

3. アプリケーション実行:
   ```bash
   flutter run
   ```

### iOSシミュレーターで実行

1. iOSシミュレーターを起動:
   ```bash
   open -a Simulator
   ```

2. アプリケーション実行:
   ```bash
   flutter run
   ```

### 物理デバイスで実行

1. デバイスをUSBで接続し、開発者モードを有効化
2. デバイス接続確認:
   ```bash
   flutter devices
   ```

3. アプリケーション実行:
   ```bash
   flutter run
   ```

### Webで実行

```bash
flutter run -d chrome
```

### Windows、macOS、Linuxで実行

```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### ホットリロード付き開発モード

より高速な開発のためホットリロードを使用:
```bash
flutter run
```

`r`を押してホットリロード、`R`を押してホットリスタート、`q`を押して終了。

---

## メイン画面とナビゲーションフロー

### アプリケーションフロー図

```
ランディング画面
    ↓
┌───────────────────┐
│ 認証済みか?        │
├───────────────────┤
│ いいえ → ログイン  │
│ はい → ホーム      │
└───────────────────┘
    ↓
┌─────────────────────────────────────────┐
│          ホーム画面(ダッシュボード)     │
├─────────────────────────────────────────┤
│ ├─ 写真フィード                         │
│ ├─ 友達リスト                           │
│ ├─ メッセージ/チャット                  │
│ ├─ 推奨事項                             │
│ └─ ナビゲーションメニュー               │
└─────────────────────────────────────────┘
    ↓ (ユーザーナビゲーション)
    ├─ 写真モジュール
    │  ├─ カメラ撮影
    │  ├─ 画像選択
    │  └─ 写真アップロード
    ├─ 友達モジュール
    │  ├─ 友達リスト
    │  ├─ 友達リクエスト
    │  ├─ 推奨事項
    │  └─ 友達検索
    ├─ メッセンジャーモジュール
    │  ├─ チャットリスト
    │  ├─ チャット画面
    │  └─ メッセージ履歴
    ├─ プロフィールモジュール
    │  ├─ プロフィール表示
    │  └─ プロフィール編集
    ├─ 設定モジュール
    │  ├─ 通知設定
    │  ├─ プライバシー設定
    │  └─ アカウント設定
    ├─ 履歴モジュール
    │  └─ アクティビティタイムライン
    └─ ログアウト
       └─ 認証フローに返却
```

### メイン画面

**ランディング画面**: 認証ステータスに基づいてユーザーのナビゲーションパスを決定するブランディング表示のエントリーポイント。

**ログイン画面**: メール/ユーザー名とパスワード認証情報での安全なユーザー認証、エラー処理、およびパスワード忘却オプション。

**サインアップ画面**: フォーム検証、メール認証、およびアカウント作成を伴う新規ユーザー登録。

**ホーム/ダッシュボード画面**: ユーザーの写真フィード、友達リスト概要、メッセージ数、および主要機能への迅速なアクションボタンを表示する中央ハブ。

**写真画面**: ユーザーの写真のギャラリービュー、アップロード機能、写真詳細、および共有オプション。

**チャット/メッセンジャー画面**: メッセージ履歴、タイピングインジケーター、およびオンラインステータストラッキング機能を備えたリアルタイムチャットインターフェース。

**友達画面**: 友達リスト、友達リクエスト、および推奨エンジンを伴う完全な友達管理インターフェース。

**プロフィール画面**: プロフィール表示およびアバター、プロフィール説明、統計、およびプライバシー設定を含む編集機能。

**設定画面**: 通知、プライバシー、セキュリティ、および一般環境設定を含むアプリケーション設定。

**履歴画面**: タイムスタンプ付きの最近の写真、メッセージ、および友達アクティビティを表示するアクティビティタイムライン。

---

## API統合

アプリケーションはバックエンドRESTサーバー(`http://10.0.2.2:8000/api`でエミュレーターテスト用)と通信します。すべてのAPI通信はJSON形式を使用し、適切なエラーハンドリングとタイムアウト管理を実装します。

### ベース設定

```
API ベースURL: http://10.0.2.2:8000/api
接続タイムアウト: 15秒
受信タイムアウト: 10秒
コンテンツタイプ: application/json
```

### メインAPIエンドポイント

#### 写真エンドポイント
- **POST** `/photos` - 新規写真のアップロード
  - リクエスト: `{ userId, imageUrl, caption }`
  - レスポンス: `{ photo: PhotoModel }`

- **GET** `/photos` - ページネーション付き写真取得
  - クエリ: `?page=1&limit=10&userId=optional`
  - レスポンス: `{ photos: [PhotoModel] }`

- **GET** `/photos/:id` - 特定写真詳細取得
  - レスポンス: `PhotoModel`

- **PUT** `/photos/:id` - 写真メタデータ更新
  - リクエスト: `{ imageUrl, caption }`
  - レスポンス: `{ photo: PhotoModel }`

- **DELETE** `/photos/:id` - 写真削除
  - レスポンス: `{ success: boolean }`

#### 友達エンドポイント
- **GET** `/friends` - ユーザーの友達リスト取得
  - レスポンス: `{ friends: [FriendModel] }`

- **GET** `/friends/recommendations` - 友達推奨取得
  - レスポンス: `{ recommendations: [UserModel] }`

- **POST** `/friend-requests` - 友達リクエスト送信
  - リクエスト: `{ recipientId }`
  - レスポンス: `{ request: FriendRequestModel }`

- **GET** `/friend-requests` - 保留中の友達リクエスト取得
  - レスポンス: `{ requests: [FriendRequestModel] }`

- **PUT** `/friend-requests/:id/accept` - 友達リクエスト受諾
  - レスポンス: `{ success: boolean }`

- **PUT** `/friend-requests/:id/decline` - 友達リクエスト拒否
  - レスポンス: `{ success: boolean }`

#### ユーザーエンドポイント
- **GET** `/users/:id` - ユーザープロフィール取得
  - レスポンス: `UserModel`

- **PUT** `/users/:id` - ユーザープロフィール更新
  - リクエスト: `{ bio, avatar, status }`
  - レスポンス: `UserModel`

- **POST** `/auth/signup` - 新規ユーザー登録
  - リクエスト: `SignupModel`
  - レスポンス: `{ user: UserModel, token: string }`

- **POST** `/auth/login` - ユーザーログイン
  - リクエスト: `{ email/username, password }`
  - レスポンス: `{ user: UserModel, token: string }`

#### メッセージエンドポイント
- **GET** `/messages` - メッセージ履歴取得
  - クエリ: `?chatId=value&limit=50`
  - レスポンス: `{ messages: [MessageModel] }`

- **WebSocket** `ws://10.0.2.2:8000/socket` - リアルタイムメッセージング
  - 即座のメッセージ配信とタイピングインジケーター対応ライブチャットを有効化

### API通信

すべてのAPI要求は専門のサービスクラスを通じて処理:
- `PhotoApi`: 写真CRUD操作を管理
- `FriendApi`: 友達管理を処理
- `FriendRequestApi`: 友達リクエストを管理
- `RecommendationApi`: 友達推奨を提供

### エラーハンドリング

アプリケーションは包括的なエラーハンドリングを実装:
- ネットワークタイムアウト管理
- HTTPエラーコード処理
- ユーザーへの適切なエラーメッセージ
- 一時的なエラーの自動再試行メカニズム
- デバッグ用の詳細ログ出力

### WebSocket統合

リアルタイムメッセージングはWebSocket接続を使用:
- 即座のメッセージ配信
- タイピングインジケーター
- オンラインステータス更新
- 自動再接続機能付きの接続永続化

---

## チームメンバー

- **Le Duong Huy** - リードディベロッパー
- **Tran Quoc Dat** - フルスタックディベロッパー
- **Tang Ngoc Hau** - UI/UXディベロッパー
- **Nguyen Tuan Ngoc** - バックエンド統合ディベロッパー

---

## ライセンス

本プロジェクトは所有権が明確なプロプライエタリソフトウェアです。すべての権利が保留されています。
