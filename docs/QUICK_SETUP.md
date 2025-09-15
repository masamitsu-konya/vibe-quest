# Vibe Quest クイック設定ガイド

## 前提条件
- AdMobアカウントの作成と広告ユニットIDの取得が完了していること
- RevenueCatアカウントの作成が完了していること（オプション）

## 設定手順

### 1. 環境変数の設定

`.env`ファイルを作成し、以下の内容を設定してください：

```env
# Supabase設定（既存）
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# AdMob設定（AdMobコンソールから取得したIDを設定）
ADMOB_APP_ID_IOS=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
ADMOB_APP_ID_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ
ADMOB_INTERSTITIAL_IOS=ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW
ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX/VVVVVVVVVV

# RevenueCat設定（RevenueCatダッシュボードから取得）
REVENUECAT_API_KEY_IOS=appl_XXXXXXXXXXXXXXXXXXXXXXXXXX
REVENUECAT_API_KEY_ANDROID=goog_XXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 2. iOS固有の設定

#### Info.plistの確認
既に設定済みです。`ios/Runner/Info.plist`に以下が含まれています：
- GADApplicationIdentifier（AdMob App ID）
- SKAdNetworkItems（広告ネットワーク識別子）
- NSUserTrackingUsageDescription（トラッキング許可の説明文）

#### 実機テストの準備
1. Xcodeでプロジェクトを開く
```bash
open ios/Runner.xcworkspace
```
2. Signing & Capabilitiesでチーム設定
3. Bundle Identifierを自分のものに変更

### 3. Android固有の設定

#### AndroidManifest.xmlの確認
既に設定済みです。`android/app/src/main/AndroidManifest.xml`に以下が含まれています：
- AdMob App IDのメタデータ

#### 最小SDKバージョンの確認
`android/app/build.gradle.kts`で最小SDKバージョンが21に設定されています。

### 4. パッケージの取得

```bash
flutter pub get
```

### 5. iOS用のPod更新（iOS実機テストの場合）

```bash
cd ios
pod install
cd ..
```

### 6. テスト実行

#### デバッグモード（テスト広告が表示されます）
```bash
flutter run
```

#### リリースモード（本番広告が表示されます）
```bash
flutter run --release
```

## テスト方法

### AdMobのテスト
1. アプリを起動
2. 質問に20個回答
3. テスト広告が表示されることを確認
4. 50個回答後、分析画面表示前にも広告が表示されることを確認

### RevenueCatのテスト（実装後）
1. 設定画面から「広告を削除」をタップ
2. 購入画面が表示されることを確認
3. Sandboxモードでテスト購入を実行

## トラブルシューティング

### 広告が表示されない場合
- `.env`ファイルのIDが正しいか確認
- デバッグモードで実行しているか確認（本番IDは承認が必要）
- コンソールログでエラーを確認

### ビルドエラーの場合
- `flutter clean`を実行
- `flutter pub get`を再実行
- iOS: `cd ios && pod install`を再実行

## 注意事項

- **テスト時は必ずデバッグモードで実行**してください（自動的にテスト広告が表示されます）
- 本番広告を自分でクリックすると**アカウント停止**の恐れがあります
- App Store/Google Playに提出する前に、必ず本番IDに切り替えてください

## 次のステップ

1. エクスポート機能の実装
2. Apple Reminders連携の実装
3. プライバシーポリシーの作成
4. App Store/Google Playへの申請準備