# iOSビルドガイド

## ビルド環境の準備

### 1. Xcodeのインストール

```bash
# Mac App Storeからインストールするか、以下で最新版を取得
xcode-select --install
```

### 2. 依存関係の管理

#### CocoaPods を使用する場合

```bash
# CocoaPodsのインストール
sudo gem install cocoapods

# プロジェクトディレクトリで実行
pod install
```

#### Swift Package Manager を使用する場合

Xcode内で管理されます。`File > Add Packages` から依存関係を追加してください。

## ビルドコマンド

### デバッグビルド

```bash
xcodebuild \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -derivedDataPath Build/Debug
```

### リリースビルド

```bash
xcodebuild \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Release \
  -derivedDataPath Build/Release
```

### シミュレーターでのビルド

```bash
xcodebuild \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphonesimulator \
  -arch arm64 \
  -derivedDataPath Build/Simulator
```

### 実機でのビルド

```bash
xcodebuild \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphoneos \
  -derivedDataPath Build/Device
```

## コード署名

### 開発用証明書の設定

1. Xcodeで`myfortune`プロジェクトを開く
2. `Signing & Capabilities`タブを選択
3. `Team`を設定
4. `Automatically manage signing`を有効化

### 証明書の手動管理

```bash
# 証明書情報の確認
security find-identity -v -p codesigning

# 特定の証明書で署名
codesign -s "Certificate Name" path/to/app.app
```

## テスト

### ユニットテストの実行

```bash
xcodebuild test \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug
```

### UIテストの実行

```bash
xcodebuild test \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -testPlan myfortuneUITests
```

## トラブルシューティング

### ビルドエラー: "Podfile.lock not found"

```bash
cd myfortune
pod install
```

### ビルドエラー: "No such file or directory"

```bash
# Derived Dataのクリア
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean
```

### シミュレーターの再起動

```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

## ビルド出力の場所

- **デバッグビルド**: `Build/Debug/`
- **リリースビルド**: `Build/Release/`
- **Simulator**: `Build/Simulator/`
- **Device**: `Build/Device/`

## パフォーマンス最適化

### ビルド時間の短速化

1. **キャッシュを活用**: `$(SRCROOT)/Build` をDerivedDataに設定
2. **並列ビルド**: `xcodebuild -parallel-jobs 4`
3. **不要なビルド設定の削除**
4. **CocoaPodsのプリコンパイル**: `pod install --repo-update`
