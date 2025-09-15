# Vibe Quest 収益化設定ガイド

このドキュメントでは、Google AdMobとRevenueCatの設定手順を説明します。

## 目次
1. [Google AdMob設定](#google-admob設定)
2. [RevenueCat設定](#revenuecat設定)
3. [環境変数の設定](#環境変数の設定)

---

## Google AdMob設定

### 1. AdMobアカウントの作成
1. [Google AdMob](https://admob.google.com/)にアクセス
2. Googleアカウントでログイン
3. アカウント情報を入力して登録

### 2. アプリの登録

#### iOS版
1. AdMobダッシュボードで「アプリを追加」をクリック
2. プラットフォームで「iOS」を選択
3. App Store IDを入力（まだ公開していない場合は「いいえ」を選択）
4. アプリ名：`Vibe Quest`を入力
5. 「アプリを追加」をクリック

#### Android版
1. AdMobダッシュボードで「アプリを追加」をクリック
2. プラットフォームで「Android」を選択
3. パッケージ名：`com.example.vibe_quest`を入力（実際のパッケージ名に変更）
4. アプリ名：`Vibe Quest`を入力
5. 「アプリを追加」をクリック

### 3. 広告ユニットの作成

#### インタースティシャル広告
1. アプリを選択して「広告ユニット」をクリック
2. 「広告ユニットを追加」をクリック
3. 「インタースティシャル」を選択
4. 広告ユニット名：`Vibe Quest Interstitial`を入力
5. 「広告ユニットを作成」をクリック
6. 表示される広告ユニットIDをメモ

### 4. プラットフォーム別設定

#### iOS設定

1. **ios/Runner/Info.plist**に以下を追加：
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- 他のSKAdNetworkIdentifierも追加 -->
</array>
```

2. **ios/Podfile**の最小iOSバージョンを確認：
```ruby
platform :ios, '12.0'
```

#### Android設定

1. **android/app/src/main/AndroidManifest.xml**に以下を追加：
```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

2. **android/app/build.gradle**の最小SDKバージョンを確認：
```gradle
defaultConfig {
    minSdkVersion 21
}
```

### 5. コード内の広告IDを更新

**lib/features/monetization/services/ad_service.dart**を編集：

```dart
static String get _interstitialAdUnitId {
  if (kDebugMode) {
    // テスト用広告ID（変更不要）
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  } else {
    // 本番用広告ID（ここを変更）
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Android用広告ユニットID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW'; // iOS用広告ユニットID
    }
  }
  throw UnsupportedError('Unsupported platform');
}
```

---

## RevenueCat設定

### 1. RevenueCatアカウントの作成
1. [RevenueCat](https://www.revenuecat.com/)にアクセス
2. 「Get Started Free」をクリック
3. アカウントを作成

### 2. プロジェクトの作成
1. ダッシュボードで「Create New Project」
2. プロジェクト名：`Vibe Quest`を入力
3. 「Create Project」をクリック

### 3. アプリの設定

#### iOS App Store設定
1. 「Set up your app」→「App Store」を選択
2. Bundle ID：`com.example.vibequest`を入力（実際のBundle IDに変更）
3. App Store Connect App-Specific Shared Secretを入力（App Store Connectから取得）

#### Google Play設定
1. 「Set up your app」→「Play Store」を選択
2. パッケージ名：`com.example.vibe_quest`を入力
3. Google Play Service Account credentialsをアップロード

### 4. 商品の作成

#### App Store Connect
1. App Store Connectにログイン
2. アプリを選択
3. 「アプリ内課金」→「+」をクリック
4. 以下の情報で商品を作成：
   - 参照名：`Vibe Quest Premium`
   - 製品ID：`vibe_quest_premium_500`
   - タイプ：`非消耗型`
   - 価格：`¥500`

#### Google Play Console
1. Google Play Consoleにログイン
2. アプリを選択
3. 「収益化」→「アプリ内アイテム」→「商品を作成」
4. 以下の情報で商品を作成：
   - 商品ID：`vibe_quest_premium_500`
   - 名前：`Vibe Quest Premium`
   - 説明：`広告削除とエクスポート機能`
   - デフォルト価格：`¥500`

### 5. RevenueCat設定の続き

#### Entitlementの作成
1. RevenueCatダッシュボードで「Entitlements」をクリック
2. 「+ New」をクリック
3. Identifier：`premium`を入力
4. Description：`Premium Features`を入力
5. 「Add」をクリック

#### Offeringの作成
1. 「Offerings」をクリック
2. 「+ New」をクリック
3. Identifier：`default`を入力
4. 「Add」をクリック
5. 作成したOfferingに商品を追加

#### APIキーの取得
1. 「API Keys」をクリック
2. 「Public App-Specific API Keys」セクションを確認
3. iOS/Android用のAPIキーをコピー

### 6. コード内のAPIキーを更新

**lib/features/monetization/services/purchase_service.dart**を編集：

```dart
class PurchaseService extends StateNotifier<PurchaseState> {
  // ここにRevenueCat APIキーを設定
  static const String _revenueCatApiKey = 'appl_XXXXXXXXXXXXXXXXXXXXXXXXXX'; // iOS用
  // または
  static const String _revenueCatApiKey = 'goog_XXXXXXXXXXXXXXXXXXXXXXXXXX'; // Android用

  static const String _entitlementId = 'premium';
  static const String _productId = 'vibe_quest_premium_500';

  // ...
}
```

プラットフォームごとに異なるAPIキーを使用する場合：

```dart
import 'dart:io';

static String get _revenueCatApiKey {
  if (Platform.isIOS) {
    return 'appl_XXXXXXXXXXXXXXXXXXXXXXXXXX';
  } else if (Platform.isAndroid) {
    return 'goog_XXXXXXXXXXXXXXXXXXXXXXXXXX';
  }
  throw UnsupportedError('Unsupported platform');
}
```

---

## 環境変数の設定

### .envファイルの更新（オプション）

セキュリティを高めるため、APIキーを環境変数に移すことを推奨：

**.env**
```env
# 既存の設定
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# AdMob設定（本番環境用）
ADMOB_APP_ID_IOS=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
ADMOB_APP_ID_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ
ADMOB_INTERSTITIAL_IOS=ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW
ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX/VVVVVVVVVV

# RevenueCat設定
REVENUECAT_API_KEY_IOS=appl_XXXXXXXXXXXXXXXXXXXXXXXXXX
REVENUECAT_API_KEY_ANDROID=goog_XXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## テスト方法

### AdMobテスト
1. デバッグモードで実行（自動的にテスト広告が表示）
2. 20問回答して広告が表示されることを確認
3. 分析画面表示前に広告が表示されることを確認

### RevenueCatテスト
1. テストアカウントを設定（App Store Connect/Google Play Console）
2. Sandboxモードで購入をテスト
3. 購入後、広告が表示されないことを確認

---

## トラブルシューティング

### AdMob関連
- **広告が表示されない**
  - App IDと広告ユニットIDが正しいか確認
  - プラットフォーム設定（Info.plist/AndroidManifest.xml）を確認
  - AdMobアカウントが承認されているか確認

### RevenueCat関連
- **購入できない**
  - 商品IDが一致しているか確認
  - App Store/Google Playで商品が有効になっているか確認
  - Sandboxテストアカウントが設定されているか確認

---

## 本番リリース前のチェックリスト

- [ ] AdMob本番用広告IDを設定
- [ ] RevenueCat本番用APIキーを設定
- [ ] App Store Connectで商品を承認
- [ ] Google Play Consoleで商品を有効化
- [ ] プライバシーポリシーを更新（広告・課金について記載）
- [ ] App Tracking Transparency（iOS 14.5+）の対応
- [ ] テスト広告IDを本番用に変更
- [ ] 環境変数が正しく設定されているか確認

---

## 参考リンク

- [Google AdMob Documentation](https://developers.google.com/admob)
- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)
- [Flutter RevenueCat Plugin](https://pub.dev/packages/purchases_flutter)