# GitHub Actions 実行監視ガイド

## 🔍 リアルタイム監視

### GitHub UI での確認方法

```
1. リポジトリを開く
   https://github.com/zka32101/myfortune

2. Actions タブをクリック
   ↓

3. 実行中のワークフローを確認
   "iOS Build & Test CI/CD" を探す
   ↓

4. ワークフローをクリック
   ↓

5. 各ジョブの実行状況を監視
   • 黄色の ⏳ = 実行中
   • 緑色の ✅ = 成功
   • 赤色の ❌ = 失敗
```

### 期待される実行時間

| ジョブ | 時間 | 状態 |
|--------|------|------|
| Code Quality Check | 2-3分 | ⏳ |
| Build (Debug) | 5-7分 | ⏳ |
| Build (Release) | 5-7分 | ⏳ |
| Unit Tests | 3-5分 | ⏳ |
| Security Scan | 2-3分 | ⏳ |
| Code Coverage | 3-5分 | ⏳ |
| Artifacts Upload | 1-2分 | ⏳ |
| **合計** | **20-25分** | ⏳ |

## 📊 ワークフロー実行フロー

```
┌─────────────────────────────┐
│ Commit Push                 │
│ (main branch)               │
└──────────────┬──────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│ GitHub Actions トリガー                 │
│ build.yml ワークフロー開始              │
└──────────────┬──────────────────────────┘
               │
               ├──────────────────────────┐
               │                          │
               ↓                          ↓
      ┌────────────────┐        ┌────────────────┐
      │ Code Quality   │        │ (並列ジョブ)    │
      │ SwiftLint      │        │                │
      └────────┬───────┘        └────────────────┘
               │
               ↓
      ┌────────────────────────┐
      │ Build & Test (並列)     │
      │ ├─ Debug Build         │
      │ ├─ Release Build       │
      │ ├─ Unit Tests          │
      │ ├─ Security Scan       │
      │ └─ Code Coverage       │
      └────────┬───────────────┘
               │
               ↓
      ┌────────────────────────┐
      │ Status Check           │
      │ (全ジョブ完了を待機)     │
      └────────┬───────────────┘
               │
        ┌──────┴──────┐
        │             │
        ↓             ↓
     ✅ 成功        ❌ 失敗
   (全テストPASS)  (エラーログ確認)
```

## 🎯 ワークフロー実行状況の詳細確認

### 1. Actions ダッシュボード

```
GitHub → Actions タブ
  ↓
"iOS Build & Test CI/CD" をクリック
  ↓
最新の実行履歴を表示
  ↓
実行中のワークフロー名をクリック
  ↓
各ジョブの詳細ログを確認
```

### 2. ジョブごとの実行ログ確認

```
ジョブ名をクリック
  ↓
実行ステップが展開表示
  ↓
各ステップの出力を確認
  ↓
エラーがある場合は赤くハイライト
```

### 3. ビルドの成功/失敗確認

**成功時:**
```
✅ Code Quality Check passed
✅ Build succeeded  
✅ Tests passed (X tests)
✅ Security scan completed
✅ Code coverage uploaded
✅ All artifacts uploaded
```

**失敗時:**
```
❌ Step failed: [ステップ名]
Error: [エラーメッセージ]
Log output: [詳細ログ]
```

## 📈 実行結果の確認ポイント

### チェックすべき項目

- [ ] **Build Status**: ✅ All jobs passed
- [ ] **Build Duration**: ~20-25 minutes
- [ ] **Test Results**: すべてのテストが PASS
- [ ] **Artifacts**: ビルドアーティファクトがアップロード
- [ ] **Code Quality**: SwiftLint が警告なし
- [ ] **Security**: セキュリティスキャンでエラーなし
- [ ] **Coverage**: コードカバレッジが報告

## 🔔 実行結果の通知

### GitHub での通知

実行完了時に以下が表示される：

1. **PR Comment** (PR の場合)
   ```
   ✅ Build & Test Passed!
   
   - ✅ Code Quality Check
   - ✅ iOS Build (Simulator)
   - ✅ iOS Build (Device)
   - ✅ Unit Tests
   - ✅ Security Scan
   - ✅ Code Coverage
   ```

2. **Commit Status**
   ```
   ✅ All checks have passed
   (リポジトリのメインページに表示)
   ```

3. **Slack Notification** (設定時)
   ```
   🎉 iOS Build Passed!
   Branch: main
   Commit: [commit hash]
   ```

## 🐛 ビルド失敗時の確認方法

### Step 1: エラーメッセージを確認

```
ワークフロー → 失敗したジョブ → 失敗したステップ
  ↓
エラーログ全体を表示
  ↓
エラーメッセージを記録
```

### Step 2: ログの分析

一般的なエラーの種類：

| エラー | 原因 | 解決策 |
|--------|------|-------|
| Pod install failures | CocoaPods エラー | Podfile を確認 |
| Build errors | コンパイルエラー | Swift コード確認 |
| Test failures | テスト失敗 | テストロジック確認 |
| Code signing | 署名エラー | Team ID 確認 |
| Timeout | ビルド時間超過 | ビルド最適化 |

### Step 3: ローカルで再現

失敗を再現するには：

```bash
# ローカルでビルド
./verify-build.sh
./setup.sh
./build.sh Debug

# ローカルでテスト
./test.sh
```

## 📋 実行後のチェックリスト

ワークフロー完了後に確認：

- [ ] **All jobs passed** ✅
- [ ] **No build errors** ❌ なし
- [ ] **All tests passed** ✅
- [ ] **Code quality OK** ✅
- [ ] **Security scan OK** ✅
- [ ] **Artifacts uploaded** ✅

## 🔄 再実行方法

### GitHub UI から再実行

```
Actions → 実行履歴 → 右上の "Re-run" ボタン
  ↓
Re-run all jobs を選択
  ↓
再実行開始
```

### 失敗したジョブのみ再実行

```
Actions → 失敗したジョブ → "Re-run" ボタン
  ↓
該当ジョブのみ再実行
```

## 📊 実行履歴の管理

### 実行履歴の表示

```
Actions タブ
  ↓
ワークフロー選択
  ↓
実行履歴が時系列で表示
  ↓
最新30実行までが保持される
```

### 実行ログの保存

```
実行結果 → ⬇️ Download logs
  ↓
全ジョブのログが ZIP でダウンロード
  ↓
ローカルで分析可能
```

## 🎯 成功のサイン

GitHub Actions ビルドが成功すると：

```
✅ Repository リポジトリの Actions タブに緑色のチェック
✅ すべてのジョブが完了
✅ テストが全て PASS
✅ ビルドアーティファクトがアップロード
✅ PR に自動コメント（PR の場合）
```

## 📞 サポート

### よくある質問

**Q: 実行時間はどのくらい？**
A: 通常 20-25 分（macOS runner での実行時間）

**Q: キャッシュは使用される？**
A: はい、CocoaPods キャッシュは 5 日間保持

**Q: 失敗時は通知される？**
A: GitHub Notifications と Slack（設定時）

**Q: 手動実行は可能？**
A: はい、Actions タブから "Run workflow" で実行

---

**リアルタイムで実行状況を監視してください！** 🚀
