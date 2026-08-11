# AI占いバックエンド セットアップ手順

`記録AI占い` 機能(過去の履歴を踏まえてAIが今日の占いを生成する)は、
Firebase Cloud Functions を経由してAnthropic APIを呼び出す構成になっています。
APIキーはアプリには一切含まれず、Cloud Functions側のシークレットとしてのみ存在します。

```
iOSアプリ(匿名Auth + App Check) → analyzeFortune (Cloud Functions) → Anthropic API
                                            │
                                            └→ Firestore(履歴の保存・当日分のキャッシュ)
```

これはこのリポジトリのコードだけでは完結せず、以下はコンソール上での手動セットアップが必要です。

## 1. Firebaseプロジェクトを作成する

```
https://console.firebase.google.com/
→ プロジェクトを追加
→ Blazeプラン(従量課金)にアップグレード
  (Cloud Functionsから外部API(Anthropic)を呼ぶには無料のSparkプランでは不可)
```

## 2. iOSアプリを登録し、GoogleService-Info.plistを追加

```
Firebaseコンソール → プロジェクトの設定 → iOSアプリを追加
→ Bundle ID(myfortune.xcodeprojの正式なBundle IDと一致させる)
→ GoogleService-Info.plist をダウンロード
→ Xcodeプロジェクトの myfortune/ フォルダに追加(Copy items if needed)
```

⚠️ `GoogleService-Info.plist` は `.gitignore` 対象です。コミットせず、各自ダウンロードして配置してください。

## 3. Firestore / Authentication / App Check を有効化

```
Firebaseコンソール → Firestore Database → データベースを作成
Firebaseコンソール → Authentication → Sign-in method → 匿名 を有効化
Firebaseコンソール → App Check → アプリを登録
  - Debug: AppCheckDebugProviderのトークンをXcodeのコンソールログから取得し登録
  - Release: App Attest を選択(追加設定不要、iOS標準機能)
```

## 4. Anthropic APIキーをCloud Functionsのシークレットとして登録

```bash
npm install -g firebase-tools
firebase login
firebase use <your-project-id>

firebase functions:secrets:set ANTHROPIC_API_KEY
# プロンプトでAPIキーを入力(Gitにもローカルにも残らない)
```

## 5. Cloud Functionsをデプロイ

```bash
cd functions
npm install
cd ..
firebase deploy --only functions,firestore:rules
```

## 6. コスト事故を防ぐための安全弁(必須)

```
Anthropic Console → Usage limits → 月額上限を設定
```

Cloud Functions / Firestore自体のコストはこの規模では通常ほぼ$0ですが、
AI API側の使用上限だけは必ず設定してください。ここが唯一の「実際に呼び出しを止める」上限です。
(GCPの予算アラートは通知のみで自動停止しません)

## ローカル動作確認(エミュレータ)

```bash
cd functions
npm run serve
```

Xcode側は `Auth.auth().useEmulator(withHost:port:)` 等の切り替えコードが必要です
(現状は未実装。エミュレータで検証したくなったタイミングで追加してください)。
