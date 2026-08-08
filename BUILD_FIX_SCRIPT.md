# iOS ビルド修正・トラブルシューティングガイド

## 🔧 macOS 環境でのビルド実行手順

このスクリプトはmacOS環境で実行してください。

### Step 1: 前提条件確認

```bash
#!/bin/bash
set -e

echo "🔍 Checking prerequisites..."

# Xcode 確認
if ! xcode-select -p &> /dev/null; then
  echo "❌ Xcode Command Line Tools not installed"
  xcode-select --install
  exit 1
fi
echo "✅ Xcode Command Line Tools: $(xcode-select -p)"

# Ruby 確認
if ! command -v ruby &> /dev/null; then
  echo "❌ Ruby not found"
  exit 1
fi
echo "✅ Ruby: $(ruby --version)"

# CocoaPods 確認
if ! command -v pod &> /dev/null; then
  echo "❌ CocoaPods not installed"
  sudo gem install cocoapods
fi
echo "✅ CocoaPods: $(pod --version)"

echo "✅ All prerequisites OK"
```

### Step 2: クリーンビルド

```bash
#!/bin/bash
set -e

echo "🧹 Cleaning build artifacts..."

# キャッシュクリア
rm -rf Pods
rm -rf Podfile.lock
rm -rf Build
rm -rf DerivedData
rm -rf .DS_Store

# Xcode のクリア
xcodebuild clean -workspace myfortune.xcworkspace -scheme myfortune

echo "✅ Clean complete"
```

### Step 3: 依存関係インストール

```bash
#!/bin/bash
set -e

echo "📦 Installing dependencies..."

# CocoaPods ポッドをインストール
pod install --repo-update

echo "✅ Dependencies installed"
```

### Step 4: ビルド実行

```bash
#!/bin/bash
set -e

echo "🔨 Building iOS app..."

# Debug ビルド
xcodebuild build \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath Build/Debug \
  -verbose

if [ $? -eq 0 ]; then
  echo "✅ Build succeeded!"
else
  echo "❌ Build failed!"
  exit 1
fi
```

### Step 5: テスト実行

```bash
#!/bin/bash
set -e

echo "🧪 Running tests..."

xcodebuild test \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath Build/Debug \
  -verbose

if [ $? -eq 0 ]; then
  echo "✅ Tests passed!"
else
  echo "❌ Tests failed!"
  exit 1
fi
```

## 🆘 よくあるビルドエラーと解決方法

### エラー: "Pods not found"

**症状:**
```
error: The following pods could not be resolved:
```

**解決:**
```bash
rm -rf Pods Podfile.lock
pod install
```

### エラー: "Code signing error"

**症状:**
```
error: Code signing is required for product type 'Application'
```

**解決:**
```bash
# Xcode で自動署名を有効化
xcodebuild -allowProvisioningUpdates \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug
```

### エラー: "Duplicate symbol"

**症状:**
```
duplicate symbol _variableName in:
```

**解決:**
```bash
# クリーンビルド
xcodebuild clean
rm -rf DerivedData
rm -rf Pods Podfile.lock
pod install
```

### エラー: "Swift compiler error"

**症状:**
```
error: cannot find 'ClassName' in scope
```

**解決:**
```bash
# プロジェクトファイル確認
# 1. Xcode で該当ファイルがターゲットに含まれているか確認
# 2. Build Phases → Compile Sources でファイル確認
# 3. 必要に応じてファイルを追加
```

### エラー: "Module not found"

**症状:**
```
error: 'import Alamofire' does not exist
```

**解決:**
```bash
# CocoaPods を再インストール
pod deintegrate
pod install
```

## 📋 ビルド成功チェックリスト

実行前に以下を確認：

- [ ] Xcode 15.0 以上がインストール
- [ ] Ruby がインストール
- [ ] CocoaPods がインストール
- [ ] git がインストール
- [ ] インターネット接続が安定

実行中：

- [ ] ビルド出力にエラーなし
- [ ] すべてのファイルがコンパイル
- [ ] リンク段階でエラーなし
- [ ] テストが実行される

完了後：

- [ ] .app ファイルが生成
- [ ] シミュレーターで実行可能
- [ ] 全テストが PASS

## 🚀 完全なビルドスクリプト

以下をコピーして `build-complete.sh` として保存：

```bash
#!/bin/bash
set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$PROJECT_DIR"

echo "================================"
echo "🚀 Complete iOS Build Process"
echo "================================"
echo ""

# 1. Prerequisites
echo "Step 1️⃣ : Checking prerequisites..."
if ! xcode-select -p &> /dev/null; then
  echo "❌ Xcode not found"
  exit 1
fi

if ! command -v pod &> /dev/null; then
  echo "❌ CocoaPods not found"
  sudo gem install cocoapods
fi

echo "✅ Prerequisites OK"
echo ""

# 2. Clean
echo "Step 2️⃣ : Cleaning..."
rm -rf Pods Podfile.lock Build DerivedData
xcodebuild clean -workspace myfortune.xcworkspace -scheme myfortune 2>/dev/null || true
echo "✅ Clean complete"
echo ""

# 3. Install dependencies
echo "Step 3️⃣ : Installing dependencies..."
pod install --repo-update
echo "✅ Dependencies installed"
echo ""

# 4. Build
echo "Step 4️⃣ : Building..."
xcodebuild build \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath Build/Debug

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi
echo "✅ Build succeeded"
echo ""

# 5. Test
echo "Step 5️⃣ : Testing..."
xcodebuild test \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath Build/Debug

if [ $? -ne 0 ]; then
  echo "⚠️ Tests failed"
  exit 1
fi
echo "✅ Tests passed"
echo ""

echo "================================"
echo "✅ Build Complete!"
echo "================================"
echo ""
echo "📦 Build output:"
echo "   Debug: Build/Debug/"
echo ""
echo "🚀 To run on simulator:"
echo "   open myfortune.xcworkspace"
echo ""
```

実行方法：
```bash
chmod +x build-complete.sh
./build-complete.sh
```

## 📊 ビルド出力の確認

```bash
# ビルド出力の詳細を確認
xcodebuild build \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  -verbose \
  -showBuildSettings

# 警告を確認
xcodebuild build 2>&1 | grep -i warning

# エラーのみを表示
xcodebuild build 2>&1 | grep -i error
```

## 🔄 繰り返しビルド

ビルドが失敗する場合の対処フロー：

```
1. xcodebuild clean
   ↓
2. rm -rf Pods Podfile.lock
   ↓
3. pod install
   ↓
4. xcodebuild build
   ↓
   成功 → ✅
   失敗 → エラーメッセージを確認
           ↓
        該当する解決策を実施
           ↓
        Step 1 に戻る
```

## 📝 トラブルシューティングログの保存

```bash
# ビルドログをファイルに保存
xcodebuild build \
  -workspace myfortune.xcworkspace \
  -scheme myfortune \
  -configuration Debug \
  > build.log 2>&1

# エラー部分を抽出
grep -i "error" build.log > errors.log

# 警告部分を抽出
grep -i "warning" build.log > warnings.log
```

---

このガイドに従ってmacOS環境でビルドを実行してください。
