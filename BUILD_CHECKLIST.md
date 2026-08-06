# iOS Build チェックリスト

## 🖥️ ローカル環境（macOS）で実行

### ✅ 前提条件の確認

- [ ] macOS 12.0以上がインストール
- [ ] Xcode 13.0以上がインストール
  ```bash
  xcode-select --install
  ```
- [ ] Swift 5.5以上が利用可能
  ```bash
  swift --version
  ```
- [ ] Rubyとgem（CocoaPods用）
  ```bash
  ruby --version
  ```

### 📦 Step 1: 依存関係のインストール

```bash
# リポジトリをクローン
git clone https://github.com/zka32101/myfortune.git
cd myfortune

# CocoaPodsをインストール（初回のみ）
sudo gem install cocoapods

# プロジェクト依存関係をインストール
pod install
```

✅ 確認: `myfortune.xcworkspace` ファイルが作成されたか確認

### 🔨 Step 2: Xcodeで開く

```bash
# ⚠️ 重要: .xcworkspaceを開く（.xcodeproj ではない）
open myfortune.xcworkspace
```

### 🔐 Step 3: コード署名設定

Xcode内で以下を実施：

1. **Project選択**
   - Project Navigator から `myfortune` を選択

2. **Signing & Capabilities タブ**
   - Targets: `myfortune` を選択
   - General タブ → Signing & Capabilities

3. **Team設定**
   - Team: 自分のApple Developerチームを選択
   - Bundle Identifier: `com.example.myfortune` を確認
   - Minimum Deployment: iOS 14.0 を確認

4. **署名証明書**
   - Automatically manage signing: ✅ チェック
   - Code Sign Identity: Automatic を選択

### 🎯 Step 4: ビルド対象の選択

**シミュレーター用ビルド**
```bash
# コマンドラインでビルド
xcodebuild \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration Debug \
    -sdk iphonesimulator \
    -derivedDataPath Build/Debug

# または Xcode内で:
# Product > Scheme > myfortune
# Product > Destination > iPhone 15 (Simulator)
```

**実機用ビルド**
```bash
# 実機をMacに接続してから:
xcodebuild \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration Debug \
    -sdk iphoneos \
    -derivedDataPath Build/Device
```

### ▶️ Step 5: ビルド実行

**Xcodeでビルド**
```
Cmd + B    # ビルド
Cmd + R    # ビルド＆実行
```

**コマンドラインでビルド＆テスト**
```bash
# テスト実行
xcodebuild test \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration Debug \
    -sdk iphonesimulator
```

### 🧪 Step 6: テスト実行

```bash
# ユニットテスト
xcodebuild test \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration Debug

# または、スクリプト実行
./test.sh
```

## 🐛 トラブルシューティング

### ❌ エラー: "Pods directory not found"
```bash
pod install
```

### ❌ エラー: "Missing developer team"
- Xcode > Signing & Capabilities でチームを選択

### ❌ エラー: "No provisioning profile found"
- Xcode > Preferences > Accounts
- Apple Developer アカウントを追加
- チームを管理 → ダウンロード

### ❌ エラー: "Code signing error"
```bash
# キーチェーンをリセット
security delete-keychain ~/Library/Keychains/login.keychain
# または手動署名に変更
```

### ❌ エラー: "Swift version mismatch"
```bash
# Xcodeを最新版に更新
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## 📱 デバイスでのテスト

### 物理デバイスに接続

1. **USBケーブルでiPhoneを接続**
2. **信頼を許可** （デバイス画面）
3. **Xcodeで認識確認**
   ```bash
   xcodebuild -showsdks | grep iphoneos
   ```

4. **Xcodeで実行**
   - Product > Destination > あなたのiPhone
   - Cmd + R でビルド＆実行

### ビルド出力

- **成功時の出力ファイル**
  - `Build/Debug/myfortune.app` (Simulator用)
  - `Build/Device/myfortune.app` (実機用)

## 🚀 自動ビルドスクリプト

```bash
# セットアップ
./setup.sh

# ビルド
./build.sh Debug      # Debug版
./build.sh Release    # Release版

# テスト
./test.sh
```

## ✅ ビルド成功の確認

- [ ] Xcodeでエラーなしでコンパイル
- [ ] テストが全て PASS
- [ ] `.app` ファイルが生成
- [ ] シミュレーターで実行可能
- [ ] 実機で実行可能 (provisioning profile設定後)

## 📋 チェックリスト（App Store Submit前）

- [ ] All Tests Pass
- [ ] Code Signing OK
- [ ] Provisioning Profile Valid
- [ ] Version Number Updated
- [ ] Build Number Updated
- [ ] Icon Assets Complete
- [ ] Launch Screen Configured
- [ ] Privacy Policy Ready
- [ ] Screenshots Ready
- [ ] App Description Ready

---

**詳細は `docs/BUILD_GUIDE.md` を参照**
