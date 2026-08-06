# GitHub Actions CI/CD Pipeline

myfortune プロジェクトの自動ビルド、テスト、デプロイメントパイプラインについての完全ガイド。

## 📋 概要

3つのメインワークフローが自動実行されます：

| ワークフロー | トリガー | 目的 |
|------------|---------|------|
| **build.yml** | Push / PR | コード品質チェック、ビルド、テスト |
| **pull-request.yml** | PR イベント | PR 検証、タイトルチェック |
| **app-store-deploy.yml** | タグ作成 / 手動 | App Store へのデプロイメント |

## 🔄 Workflow: build.yml

### トリガー条件

```yaml
on:
  push:
    branches: [ main, develop, claude/* ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * *'  # 毎日 02:00 UTC
```

### ジョブ構成

#### 1️⃣ **Code Quality Check**
- SwiftLint によるコード品質スキャン
- 結果: ⚠️ エラーは warning（続行）

```bash
swiftlint myfortune --strict
```

#### 2️⃣ **Build & Test** (並列実行)
- **Debug (Simulator)**
  ```bash
  xcodebuild build -sdk iphonesimulator -configuration Debug
  ```
- **Release (Device)**
  ```bash
  xcodebuild build -sdk iphoneos -configuration Release
  ```

#### 3️⃣ **Unit Tests**
- XCTest フレームワークで実行
- 結果は GitHub に自動アップロード

```bash
xcodebuild test -sdk iphonesimulator
```

#### 4️⃣ **Security Scan**
- Trivy による脆弱性スキャン
- Secret スキャン
- 結果は GitHub Security tab に表示

#### 5️⃣ **Code Coverage**
- Test coverage を Codecov にアップロード
- カバレッジレポート生成

#### 6️⃣ **Artifacts**
- ビルド成果物の保存
- 30日間の保持

#### 7️⃣ **PR Comment**
- PR 作成時に自動でコメント
- ビルド＆テスト結果を表示

### 環境変数

```yaml
env:
  XCODE_VERSION: '15.0'
  IOS_VERSION: '14.0'
  SWIFT_VERSION: '5.9'
```

### ジョブ間の依存関係

```
code-quality
    ↓
   build (code-quality 完了後)
    ↓
unit-tests, code-coverage (build 完了後)
    ↓
status-check (全ジョブ完了後)
```

## 🚀 Workflow: app-store-deploy.yml

### トリガー条件

```yaml
on:
  push:
    tags:
      - 'v*'  # e.g., v1.0.0, v1.0.1
  workflow_dispatch:  # 手動実行
```

### デプロイメントステップ

#### 1️⃣ **Archive 作成**
```bash
xcodebuild archive \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Release \
  -archivePath "./myfortune.xcarchive"
```

#### 2️⃣ **IPA エクスポート**
```bash
xcodebuild -exportArchive \
  -archivePath "./myfortune.xcarchive" \
  -exportPath "./export" \
  -exportOptionsPlist "ExportOptions.plist"
```

#### 3️⃣ **App Store Connect へアップロード**
```bash
xcrun altool --upload-app \
  -f myfortune.ipa \
  -t ios \
  -u "$APPLE_USERNAME" \
  -p "$APPLE_APP_SPECIFIC_PASSWORD"
```

#### 4️⃣ **TestFlight へアップロード**
- 自動的に Beta テスター用ビルドとして登録

#### 5️⃣ **GitHub Release 作成**
- タグ情報から自動でリリースノート生成

#### 6️⃣ **Slack 通知**
- デプロイメント完了/失敗を Slack で通知

### 必要な Secrets

```
APPLE_USERNAME              # Apple ID メールアドレス
APPLE_APP_SPECIFIC_PASSWORD # App-specific パスワード
APPLE_TEAM_ID              # Apple Developer Team ID
SLACK_WEBHOOK              # Slack Webhook URL
```

## 👥 Workflow: pull-request.yml

### トリガー条件

```yaml
on:
  pull_request:
    branches: [ main, develop ]
    types: [opened, synchronize, reopened]
```

### チェック項目

#### 1️⃣ **PR Title Validation**
Conventional Commits フォーマットをチェック

**許可されるフォーマット:**
```
feat(scope): description
fix(scope): description
docs(scope): description
style(scope): description
refactor(scope): description
test(scope): description
chore(scope): description
```

**例:**
```
✅ feat(home): add fortune display widget
✅ fix(api): handle network timeout correctly
❌ update stuff
❌ WIP: new feature
```

#### 2️⃣ **Commit Message Validation**
Conventional Commits フォーマット確認

#### 3️⃣ **Files Changed Check**
制限されたファイルの変更を検出

#### 4️⃣ **Build & Test on PR**
- PR がマージ前にビルド＆テスト実行
- 失敗時は PR マージをブロック

#### 5️⃣ **Code Review Insights**
OSSF Scorecard で品質チェック

#### 6️⃣ **PR Checklist**
自動でチェックリストコメントを追加

#### 7️⃣ **Size Check**
PR のサイズを警告

- ⚠️ 20ファイル以上
- ⚠️ 500行以上の追加

## 🔐 GitHub Secrets 設定

### 設定方法

1. GitHub リポジトリ → **Settings**
2. **Secrets and variables** → **Actions**
3. **New repository secret** をクリック

### 必要な Secrets

#### App Store Deploy 用

| Secret | 取得方法 |
|--------|---------|
| `APPLE_USERNAME` | Apple Developer アカウント |
| `APPLE_APP_SPECIFIC_PASSWORD` | https://appleid.apple.com/account → App Specific Passwords |
| `APPLE_TEAM_ID` | Apple Developer Program → Team ID |

#### 通知用

| Secret | 取得方法 |
|--------|---------|
| `SLACK_WEBHOOK` | Slack Workspace → Apps → Incoming Webhooks |

## 📊 ワークフロー実行状況の確認

### GitHub UI で確認

1. リポジトリ → **Actions** タブ
2. ワークフロー選択
3. 実行履歴を確認

### 実行結果の詳細

```
✅ success    = 全ジョブ成功
⚠️ failure    = ジョブ失敗
⏭️ skipped    = ジョブスキップ
⏸️ cancelled  = キャンセル
```

## 🐛 トラブルシューティング

### ❌ ビルド失敗

**症状:** "Pod Install Failures"
```
解決策:
1. GitHub Actions で `pod install` を実行確認
2. Podfile.lock がバージョン管理下にあるか確認
```

**症状:** "Code Signing Failures"
```
解決策:
1. `secrets.APPLE_TEAM_ID` を確認
2. Xcode で自動署名を有効化
```

### ❌ テスト失敗

**症状:** "Test Timeout"
```
解決策:
1. テストの処理時間を最適化
2. タイムアウト値を増加
```

**症状:** "Simulator Not Available"
```
解決策:
1. Xcode バージョン確認
2. `-sdk iphonesimulator` 指定を確認
```

### ❌ デプロイメント失敗

**症状:** "Invalid Credentials"
```
解決策:
1. App-specific パスワード確認
2. Apple ID 二要素認証状態確認
```

**症状:** "IPA Validation Failed"
```
解決策:
1. Code signing certificate 確認
2. Provisioning profile 有効期限確認
```

## 📈 パフォーマンス最適化

### キャッシング

```yaml
- name: Cache CocoaPods
  uses: actions/cache@v3
  with:
    path: Pods
    key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
```

**効果:**
- 初回: 10-15分
- キャッシュ利用時: 2-3分

### 並列実行

複数のジョブが同時実行可能:
```
- code-quality (並列)
- build (並列 x 2)
- unit-tests (並列)
- security-scan (並列)
- code-coverage (並列)
```

## 📝 カスタマイズ

### スケジュール実行の変更

```yaml
schedule:
  - cron: '0 2 * * *'  # UTC時刻
  # 毎日 02:00 UTC = 日本時間 11:00 (JST)
  # 毎週月曜: '0 2 * * 1'
```

### 通知先の追加

```yaml
# Slack 以外の通知
- name: Send Email Notification
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: ${{ secrets.EMAIL_SERVER }}
    server_port: ${{ secrets.EMAIL_PORT }}
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Build Failed
    to: team@example.com
    from: ci@example.com
```

## 📚 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift CI/CD Best Practices](https://developer.apple.com/documentation/xcode/continuous-integration)
- [Xcode Cloud Documentation](https://developer.apple.com/documentation/xcode/xcode-cloud)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## ✅ チェックリスト

- [ ] Secrets を設定
- [ ] ワークフローファイルをレビュー
- [ ] テスト実行を確認
- [ ] PR チェック動作確認
- [ ] デプロイメント手順確認

---

**質問がある場合は、Issues で報告してください。**
