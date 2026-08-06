# iOS アプリ デプロイメントガイド

## 🎯 このガイドについて

myfortune iOS アプリを App Store にリリースするための完全なガイドです。

## 📋 デプロイメント前チェックリスト

### ✅ アプリ側の準備

- [ ] **バージョン番号を更新**
  - Info.plist の `CFBundleShortVersionString` を更新
  - Info.plist の `CFBundleVersion` をインクリメント

- [ ] **アイコンを設定**
  - AppIcon.appiconset に全サイズのアイコンを配置
  - 1024x1024 の App Store Icon を追加

- [ ] **LaunchScreen を設定**
  - LaunchScreen.storyboard をカスタマイズ

- [ ] **Privacy Policy & Terms を用意**
  - プライバシーポリシーのURL
  - 利用規約のURL

- [ ] **スクリーンショットを用意**
  - 各デバイスサイズ用のスクリーンショット (5枚以上推奨)
  - iPhone Pro Max (6.7"), Pro (6.1"), 標準 (6.1")

- [ ] **説明文を用意**
  - アプリ名
  - サブタイトル
  - 説明文 (最大4000文字)
  - キーワード (100文字以内、カンマ区切り)
  - サポートURL

### ✅ Apple Developer アカウント側の準備

- [ ] **Apple Developer Program に登録** ($99/年)
  - https://developer.apple.com/programs/

- [ ] **App Store Connect にアプリを登録**
  - App Name: myfortune
  - Bundle ID: com.example.myfortune (または独自のID)
  - SKU: 任意のユニークな識別子

- [ ] **Certificates を作成**
  - Apple ID で https://developer.apple.com にサインイン
  - Certificates, Identifiers & Profiles
  - iOS Distribution Certificate を作成

- [ ] **App ID を作成**
  - Bundle Identifier: com.yourcompany.myfortune
  - Capabilities を選択 (例: Push Notifications)

- [ ] **Provisioning Profile を作成**
  - Distribution Provisioning Profile を作成
  - ダウンロードしてXcodeに追加

### ✅ ビルド準備

- [ ] **Xcode で署名設定を完了**
  ```
  Target > myfortune > Signing & Capabilities
  Team: あなたのAppleチーム
  Bundle Identifier: com.yourcompany.myfortune
  Provisioning Profile: 作成したProfile
  Code Sign Identity: iOS Distribution
  ```

- [ ] **Release ビルド設定を確認**
  - Build Settings > Code Signing Identity = iOS Distribution
  - Build Settings > Provisioning Profile = Distribution Profile

## 🔨 ビルドとアップロード

### Step 1: Archive を作成

**Xcode で**
```
1. Product > Destination を "Generic iOS Device" に変更
2. Product > Build For > Running を実行
3. Product > Archive
```

**または コマンドラインで**
```bash
xcodebuild \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Release \
  -archivePath "./myfortune.xcarchive" \
  archive
```

### Step 2: Export IPA を生成

**Xcode で**
```
1. Window > Organizer
2. Archives タブで myfortune.xcarchive を選択
3. Distribute App
4. App Store Connect を選択
5. Upload を選択
6. 続行...
```

**または xcodebuild で**
```bash
xcodebuild \
  -exportArchive \
  -archivePath "./myfortune.xcarchive" \
  -exportPath "./export" \
  -exportOptionsPlist "export_options.plist"
```

### Step 3: App Store Connect にアップロード

**Xcode から直接**
- Distribute App のウィザードに従う
- Apple ID でログイン
- アップロード完了

**または Transporter アプリで**
```bash
# Apple から Transporter をダウンロード
# https://apps.apple.com/jp/app/transporter/id1450874784

# IPA ファイルを Transporter でアップロード
```

### Step 4: 審査提出

**App Store Connect で**
```
1. https://appstoreconnect.apple.com にサインイン
2. My Apps > myfortune
3. Version 情報を確認
4. 一般 > App Review Information を入力
5. Build を選択 (最新の uploaded build)
6. 審査のために提出
```

## 📝 App Store Review 情報

### 必須情報

- **Contact Information**
  - 連絡先メールアドレス
  - 電話番号
  - サポートURL

- **App Review Information**
  - Demo Account (ログインが必要な場合)
  - Notes for App Review (レビュアーへのメモ)

- **Content Rights**
  - 著作権情報
  - サードパーティサービスの利用について

### ガイドライン

- App Store Review Guidelines に準拠
  - https://developer.apple.com/app-store/review/guidelines/

### よくある却下理由と対策

| 問題 | 対策 |
|------|------|
| クラッシュ | テスト実機で十分なテストを実施 |
| パフォーマンス低下 | バッテリー消費とメモリ使用量を最適化 |
| UI/UX の不具合 | 複数デバイスで動作確認 |
| プライバシー問題 | Privacy Policy を明記、ユーザー許可を取得 |
| 外部決済 | In-App Purchase を使用 |

## 🔄 アップデート手順

### マイナーアップデート

1. コード修正
2. バージョン番号を更新
3. Release Build を作成
4. Archive & Export
5. App Store Connect にアップロード

### メジャーアップデート

1. 新機能実装
2. 十分なテスト実施
3. バージョン番号を大幅更新
4. Release Notes を準備
5. 上記の手順に従う

## 📊 リリース後の監視

### App Store Connect で確認

- **Impressions & Conversions**
  - アプリの表示回数
  - ダウンロード数

- **Crashes & Exceptions**
  - クラッシュレート
  - エラーログ

- **Performance**
  - アプリの起動時間
  - メモリ使用量

### Firebase Analytics で確認

- ユーザー数
- エンゲージメント
- カスタムイベント

## 🚨 トラブルシューティング

### ❌ "Certificate is not valid" エラー

```bash
# キーチェーンから古い証明書を削除
security delete-certificate -Z <Certificate Fingerprint>

# 新しい証明書を再作成してダウンロード
```

### ❌ "Provisioning Profile is invalid"

```bash
# Xcode で自動管理を有効化
# または手動で Profile をダウンロード & インストール
```

### ❌ "Archive 作成に失敗"

```bash
# Clean してから再度ビルド
xcodebuild clean -workspace myfortune.xcworkspace -scheme myfortune
xcodebuild archive ...
```

### ❌ "Upload に失敗"

```bash
# ネットワーク接続を確認
# Xcode を再起動
# Transporter アプリを試す
```

## 📚 参考資料

- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Xcode Help - App Distribution](https://help.apple.com/xcode/mac/current/#/dev60e8f853d)
- [TestFlight ガイド](https://developer.apple.com/testflight/)

## ✅ デプロイメント完了チェック

- [ ] App Store Connect で「Ready for Sale」
- [ ] App Store で検索可能
- [ ] ダウンロード可能
- [ ] Reviews & Ratings が表示開始
- [ ] Analytics データが見える

---

**質問または問題が発生した場合は、Apple Developer Support にお問い合わせください。**
