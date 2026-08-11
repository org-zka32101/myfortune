# myfortune

iOS / Android占い・運勢アプリ

## 概要

myfortuneは、ユーザーが毎日の運勢や占いを楽しむことができるアプリケーションです。
iOS版（`myfortune/`）とAndroid版（`android/`）があり、AIバックエンド（`functions/`）を共有しています。

## 要件

- iOS 14.0 以上
- Xcode 13.0 以上
- Swift 5.5 以上

## セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/zka32101/myfortune.git
cd myfortune
```

### 2. 依存関係のインストール

```bash
# CocoaPodsを使用する場合
pod install

# または Swift Package Managerを使用する場合
# Xcodeで管理
```

### 3. ビルド

```bash
# Xcodeで開く
open myfortune.xcworkspace

# またはコマンドラインでビルド
xcodebuild -workspace myfortune.xcworkspace -scheme myfortune -configuration Debug
```

## プロジェクト構造

```
myfortune/
├── README.md
├── .gitignore
├── myfortune/                    # iOSアプリケーション
│   ├── myfortune.xcodeproj/
│   ├── myfortune/
│   │   ├── App/
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Resources/
│   └── myfortuneTests/
├── android/                      # Androidアプリケーション（詳細は docs/android-setup.md）
│   └── app/src/main/java/com/example/myfortune/
├── functions/                    # AIバックエンド（Cloud Functions、iOS/Android共通）
├── .github/
│   └── workflows/               # CI/CD設定
└── docs/                        # ドキュメント
```

## ビルド・リリース

### デバッグビルド

```bash
xcodebuild -workspace myfortune.xcworkspace -scheme myfortune -configuration Debug
```

### リリースビルド

```bash
xcodebuild -workspace myfortune.xcworkspace -scheme myfortune -configuration Release
```

## テスト

```bash
xcodebuild test -workspace myfortune.xcworkspace -scheme myfortune
```

## ライセンス

MIT License

## 開発者

- zka32101
