# Android版 セットアップ手順

`android/` は既存のiOSアプリ（`myfortune/`）と同じ機能（AIバックエンド経由の占い取得、
インタースティシャル広告）を持つAndroid版です。バックエンド（Cloud Functions /
Firestore / Anthropic連携）はiOS版と共通で、`functions/` を再利用します。

このリポジトリのコードだけでは完結せず、以下はコンソール上での手動セットアップが必要です。

## 1. Firebaseプロジェクトへ Android アプリを追加

iOS版で使っているものと**同じFirebaseプロジェクト**に追加します（バックエンドは共通のため）。

```
Firebaseコンソール → プロジェクトの設定 → Androidアプリを追加
→ パッケージ名: com.yourwish.cometrueaifortune（android/app/build.gradle.kts の applicationId と一致させる）
→ google-services.json をダウンロード
→ android/app/ 直下に配置
```

⚠️ `google-services.json` は `.gitignore` 対象です。コミットせず、各自ダウンロードして配置してください。

## 2. App Check（Play Integrity）を有効化

```
Firebaseコンソール → App Check → Androidアプリを登録 → Play Integrity を選択
```

- デバッグビルドは `DebugAppCheckProviderFactory` を使用します（`MyFortuneApplication.kt`）。初回起動時にLogcatへ出力されるデバッグトークンをFirebaseコンソールに登録してください。
- リリースビルドは Play Integrity を使用します（Google Play Consoleでアプリの署名情報が登録されている必要があります）。

## 3. AdMob の App ID / 広告ユニットIDを差し替え

`AndroidManifest.xml` の `com.google.android.gms.ads.APPLICATION_ID` と、
`AdManager.kt` の `INTERSTITIAL_AD_UNIT_ID` は現在Googleの公開テストIDです。
[AdMobコンソール](https://apps.admob.com/) で実際のApp ID・広告ユニットIDを発行し、
リリース前に差し替えてください。

## 4. ビルド

```bash
cd android
./gradlew assembleDebug   # デバッグAPK
./gradlew assembleRelease # リリースAPK（署名設定は別途必要）
./gradlew testDebugUnitTest
```

CI（`.github/workflows/android-build.yml`）でも同様のビルド・テストを自動実行します。
