# CI/CD・インフラ トラブルシューティング記録

このリポジトリのCI/CD構築(GitHub Actions、Firebase自動デプロイ、Android署名ビルドなど)で
実際にハマった問題と解決策の記録です。同じ問題を再度踏まないよう、直す前に一度ここを確認してください。

## GitHub Actions

### `secrets` コンテキストはジョブレベルの `if:` に書けない

```yaml
# ❌ これはエラーになる (Unrecognized named-value: 'secrets')
jobs:
  release-bundle:
    if: ${{ secrets.ANDROID_KEYSTORE_BASE64 != '' }}
```

`secrets` コンテキストは `env:` / `with:` では使えるが、ジョブレベルの `if:` には使えない
(GitHub Actionsの仕様上の制約)。`vars` コンテキストはジョブレベルの `if:` でも使える
(`functions-deploy.yml` の `if: ${{ vars.FIREBASE_PROJECT_ID != '' }}` はこれで動く)。

**対処法**: 最初のステップで `secrets` を `env:` 経由で読み、`$GITHUB_OUTPUT` に真偽値を書き出し、
以降の各ステップを `if: steps.<id>.outputs.xxx == 'true'` で制御する
(`.github/workflows/android-build.yml` の `release-bundle` ジョブ参照)。

### `defaults.run.working-directory` は全ステップに効く

ジョブに `defaults: run: working-directory: android` を設定すると、**チェックアウトより前のステップにも**
そのディレクトリへの `cd` が適用される。まだ存在しないディレクトリに `cd` しようとして最初のステップ自体が失敗する。

**対処法**: `actions/checkout@v4` を必ず最初のステップにする(working-directory系の設定より前に置く)。

### GitHub Variables へのペーストでCRLFが混入する

Windows由来のクリップボードから GitHub の **Variable**(Secretではなく)にペーストすると、末尾に `\r` が
混入することがある。値を使う条件分岐(`if: vars.FOO != ''` など)は文字列一致で判定されるため、
見た目は正しく見えても意図せず分岐が変わる/スキップされる。ジョブログに実際の値を出力すると
`FIREBASE_PROJECT_ID: app1-6c108\r\n` のように混入が見える。

**対処法**: 値は貼り付けず直接タイプするか、貼り付け後にジョブログで実際の値をエコーして確認する。

## Google Cloud IAM

### Secret Manager のアクセス権限は「付与したつもり」でも反映に時間がかかることがある

Cloud Functions のデプロイ用サービスアカウントに `Secret Manager Secret Accessor`
(`secretmanager.secrets.get` 権限を含む)ロールを付与しても、即座に反映されず
403エラーが続くことがあった。IAM Policy Troubleshooter
(エラーメッセージ内のリンクから開ける)で実際に許可ポリシーが揃っているか確認するのが確実。

**対処法**: ロール付与後は数分待ってから再実行する。それでも失敗する場合は
Policy Troubleshooterで対象プリンシパル(サービスアカウントのメールアドレス)に
正しいロールが付いているか確認する。

## Android ビルド

### AdMobとFirebase Analyticsのマニフェストマージ衝突

`play-services-ads` と `play-services-measurement-api` が両方とも
`android.adservices.AD_SERVICES_CONFIG` の `<property>` をマニフェストに宣言するため、
マニフェストマージでコンフリクトする。

**対処法**: `AndroidManifest.xml` の該当 `<property>` に `tools:replace="android:resource"` を追加する
(Googleのエラーメッセージが提示する修正方法そのまま)。

### AGP 8.x で `BuildConfig` が解決できない

AGP 8.0以降は `buildConfig` フィールドの生成がデフォルトで無効。
`android { buildFeatures { buildConfig = true } }` を明示的に指定する必要がある。

## このセッション(Claude Code on the web)固有の制約

- **`dl.google.com` への到達不可**: サンドボックスのプロキシがブロックしており、
  Android Gradle Plugin / Google Maven リポジトリの解決ができない。そのため
  **Androidアプリのローカルビルド確認はできず**、実際のビルド/テスト検証は必ず
  GitHub Actions(ネットワーク制限なし)側で行う。
- **Azure Blob署名URLへの到達不可**: GitHub Actionsのartifactダウンロード用署名URLに
  直接 `curl` できない。Artifactはユーザー自身がGitHub Actionsの実行結果ページ
  (`https://github.com/<owner>/<repo>/actions/runs/<run_id>`)からブラウザでダウンロードする。

## 過去に発生した実際の不具合

現時点でアプリ本体(iOS/Android/Cloud Functions)側に、実行時にクラッシュ・データ不整合を
引き起こす既知のバグは見つかっていません(2026-08-29 定期レビュー時点)。
過去に発生した問題は上記のCI/CDインフラ関連のみです。
