# GitHub Actions セットアップガイド

## 🚀 クイックスタート

### Step 1: Secrets の設定

GitHub リポジトリの Settings → Secrets and variables → Actions で以下を追加：

#### App Store デプロイメント用 (必須)

```
APPLE_USERNAME              = your-apple-id@example.com
APPLE_APP_SPECIFIC_PASSWORD = xxxx-xxxx-xxxx-xxxx
APPLE_TEAM_ID              = ABCD123456
```

**取得方法:**

1. **APPLE_USERNAME**
   - Apple ID メールアドレス

2. **APPLE_APP_SPECIFIC_PASSWORD**
   ```
   https://appleid.apple.com
   → Security
   → App-specific passwords
   → Generate password
   ```

3. **APPLE_TEAM_ID**
   ```
   https://developer.apple.com
   → Membership Details
   → Team ID
   ```

#### Slack 通知用 (オプション)

```
SLACK_WEBHOOK = https://hooks.slack.com/services/...
```

**取得方法:**
```
Slack Workspace Settings
→ Apps & integrations
→ Incoming Webhooks
→ Create New Webhook
```

### Step 2: ワークフロー確認

リポジトリの **Actions** タブで以下のワークフローが表示されることを確認：

- ✅ iOS Build & Test CI/CD
- ✅ Pull Request Validation
- ✅ App Store Deployment

### Step 3: テスト実行

```bash
# main または develop ブランチに push
git push origin main

# GitHub Actions が自動実行される
# Actions タブで進捗を確認
```

## 📋 ワークフロー詳細

### 🔨 build.yml (自動実行)

**トリガー:**
- Push to main, develop, claude/*
- Pull Request to main, develop
- 毎日 02:00 UTC にスケジュール実行

**実行ジョブ:**
1. Code Quality Check (SwiftLint)
2. Build (Debug + Release)
3. Unit Tests
4. Security Scan
5. Code Coverage
6. Artifacts
7. PR Comment (PR 時のみ)

**実行時間:** 約15-20分

**結果確認:**
```
GitHub → Actions → ワークフロー選択 → 実行履歴
```

### 🚀 app-store-deploy.yml (手動 or タグ)

**トリガー:**
```bash
# タグ作成時に自動実行
git tag v1.0.0
git push origin v1.0.0

# または GitHub Actions から手動実行
# Actions → App Store Deployment → Run workflow
```

**実行ステップ:**
1. Archive 作成
2. IPA エクスポート
3. App Store Connect アップロード
4. TestFlight 配布
5. GitHub Release 作成
6. Slack 通知

**実行時間:** 約5-10分

### 👥 pull-request.yml (自動実行)

**トリガー:**
- PR の作成・更新

**チェック項目:**
- PR Title 形式
- Commit メッセージ
- ビルド
- テスト
- コードスキャン

**失敗時:** PR マージをブロック

## ✅ セットアップチェックリスト

### 初期セットアップ

- [ ] リポジトリが GitHub に存在
- [ ] Workflows ディレクトリが存在 (.github/workflows/)
- [ ] YAML ファイルが正しいフォーマット

### Secrets 設定

- [ ] APPLE_USERNAME を設定
- [ ] APPLE_APP_SPECIFIC_PASSWORD を設定
- [ ] APPLE_TEAM_ID を設定
- [ ] (オプション) SLACK_WEBHOOK を設定

### 初回テスト

- [ ] コミットを push して build.yml が実行
- [ ] PR を作成して pull-request.yml が実行
- [ ] PR がマージ可能な状態（すべての check が pass）

### デプロイメント準備

- [ ] タグ命名規則を確認 (v*.*.*)
- [ ] App Store Connect でアプリを登録
- [ ] Provisioning Profile を有効化

## 🔧 高度な設定

### ワークフロー実行タイミングの変更

`.github/workflows/build.yml` を編集：

```yaml
on:
  push:
    branches: [ main, develop ]  # push されるブランチ
  pull_request:
    branches: [ main, develop ]  # PR のターゲットブランチ
  schedule:
    - cron: '0 2 * * *'  # UTC 時刻 (cron 形式)
```

**Cron 表記例:**
```
0 2 * * *    = 毎日 02:00 UTC
0 9 * * 1-5  = 平日 09:00 UTC
0 */6 * * *  = 6時間ごと
```

### Slack 通知メッセージのカスタマイズ

`.github/workflows/app-store-deploy.yml` で修正：

```yaml
- name: Send Slack notification
  with:
    text: |
      🎉 App Store Deployment Complete!
      Version: ${{ steps.version.outputs.VERSION }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}
```

### ジョブのスキップ

コミットメッセージに以下を含める：

```bash
git commit -m "Fix bug [skip ci]"
git push

# CI/CD スキップ
```

## 📊 実行状況の監視

### GitHub UI

```
リポジトリ → Actions タブ
  ↓
ワークフロー選択
  ↓
実行履歴確認
  ↓
詳細ログ表示
```

### ローカルからの確認

```bash
# 最新の実行状況を確認
gh run list --repo zka32101/myfortune

# 詳細を表示
gh run view <RUN_ID> --repo zka32101/myfortune
```

### ワークフロー実行ログのダウンロード

```bash
# 全ジョブのログをダウンロード
gh run download <RUN_ID> --repo zka32101/myfortune

# 特定ジョブのログ
gh run view <RUN_ID> --repo zka32101/myfortune --log
```

## 🐛 よくあるエラーと対策

### ❌ "Secrets not found"

**症状:**
```
Error: Secrets not available
```

**対策:**
```
1. GitHub Settings → Secrets and variables → Actions
2. Secrets が正しく設定されているか確認
3. ワークフローで ${{ secrets.SECRET_NAME }} を使用
```

### ❌ "Xcode not found"

**症状:**
```
Error: xcodebuild: command not found
```

**対策:**
```yaml
- name: Set up Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.0'
```

### ❌ "CocoaPods installation failed"

**症状:**
```
Error: pod: command not found
```

**対策:**
```bash
# Gemfile を追加
gem install cocoapods

# または workflow で
- name: Install CocoaPods
  run: gem install cocoapods --user-install
```

### ❌ "Code signing failures"

**症状:**
```
error: Provisioning profile is invalid
```

**対策:**
```
1. APPLE_TEAM_ID を確認
2. Apple Developer Program を確認
3. Certificate を再生成
```

## 📈 パフォーマンス改善

### キャッシング

```yaml
- name: Cache CocoaPods
  uses: actions/cache@v3
  with:
    path: Pods
    key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
    restore-keys: |
      ${{ runner.os }}-pods-
```

**効果:** 初回 15分 → 次回以降 3分

### 並列実行

```yaml
strategy:
  matrix:
    include:
      - config: Debug
      - config: Release
```

複数設定を同時実行

## 📚 参考リンク

- [GitHub Actions 公式ドキュメント](https://docs.github.com/en/actions)
- [Xcode GitHub Actions](https://github.com/actions/setup-xcode)
- [Swift GitHub Actions](https://github.com/marketplace?type=actions&query=swift)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## 🆘 サポート

問題が発生した場合：

1. **Logs を確認**
   ```
   GitHub Actions → ワークフロー → ジョブ → ログ
   ```

2. **Workflow を再実行**
   ```
   Actions → ワークフロー → 実行 → Rerun
   ```

3. **Issues を作成**
   ```
   GitHub → Issues → New Issue
   ```

---

**セットアップ完了後、最初のコミットをプッシュしてワークフローをテストしてください！** ✨
