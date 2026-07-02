# RevenueCat 商品設定ガイド（新UI版）

## 前提条件
- App Store Connectで商品が作成済みであること
- RevenueCatプロジェクトが作成済みであること

## 手順

### 1. App Store Connectで商品を作成

1. [App Store Connect](https://appstoreconnect.apple.com)にログイン
2. 「マイApp」から対象アプリを選択
3. 左メニューの「App内課金」を選択
4. 「+」ボタンで新規作成
5. 以下の設定を行う：
   - **タイプ**: 「消費型」または「非消費型」を選択（今回は「非消費型」）
   - **参照名**: `Vibe Quest Premium`
   - **製品ID**: `vibe_quest_premium_500`
   - **価格**: ¥500を選択
   - **表示名**: `プレミアムアップグレード`
   - **説明**: `広告を削除し、エクスポート機能を利用できます`
6. 「保存」をクリック

### 2. RevenueCatダッシュボードで商品を設定（新UI）

#### Product catalog（商品カタログ）の設定
1. RevenueCatダッシュボードにログイン
2. 左メニューの「**Product catalog**」をクリック
3. 3つのタブが表示されます：
   - **Offerings**: パッケージの作成
   - **Products**: 商品の登録
   - **Entitlements**: 権限の設定

#### Products（商品）の追加
1. 「Product catalog」→「**Products**」タブを選択
2. 「+ New Product」ボタンをクリック
3. 以下を入力：
   - **Identifier**: `vibe_quest_premium_500`
   - **App Store Product ID**: `vibe_quest_premium_500`（App Store Connectの製品IDと同じ）
   - **Play Store Product ID**: （Androidの場合は入力）
   - **Amazon Product ID**: （Amazon Appstoreの場合）
   - **Stripe Product ID**: （Webの場合）
   - **Description**: `Premium upgrade for Vibe Quest`
4. 「Save」をクリック

#### Entitlements（権限）の設定
1. 「Product catalog」→「**Entitlements**」タブを選択
2. 「+ New Entitlement」ボタンをクリック
3. 以下を入力：
   - **Identifier**: `premium`
   - **Description**: `Premium features access`
4. 「Save」をクリック
5. 作成した`premium`をクリック
6. 「Products」セクションで「+ Attach」をクリック
7. `vibe_quest_premium_500`を選択
8. 「Attach」をクリック

#### Offerings（オファリング）の設定
1. 「Product catalog」→「**Offerings**」タブを選択
2. デフォルトで「Offering #1」が存在する場合はそれを使用、なければ「+ New Offering」
3. Offeringをクリックして編集：
   - **Identifier**: デフォルトのまま使用（変更不要）
   - **Description**: `Default offering`
   - **Metadata**（オプション）: 必要に応じて追加
4. 「Packages」セクションで「+ New Package」をクリック
5. Packageの設定：
   - **Identifier**: ドロップダウンから「**Lifetime**」を選択（一回買い切りの場合）
     - または「Custom」を選択して`default`と入力
   - **Description**: `Premium Package`
6. 「Products」で`vibe_quest_premium_500`を選択
7. 「Save」をクリック
8. 「Make Current」ボタンをクリックして現在のOfferingに設定

### 3. テスト設定

#### Sandbox Testerの作成（iOS）
1. App Store Connectの「ユーザーとアクセス」へ
2. 「Sandboxテスター」タブを選択
3. 「+」ボタンで新規作成
4. テスト用のメールアドレスを入力
5. 保存

#### RevenueCatでSandboxテスト購入の確認
1. **まずアプリでテスト購入を実行**（購入しないとCustomersに表示されません）
2. RevenueCatダッシュボードの「Customers」へ
3. 左サイドバーの「Sandbox」をクリック（Sandboxユーザーのみ表示）
4. テスト購入したユーザーが表示される
5. ユーザーをクリックして購入詳細を確認

### 4. アプリ側の確認事項

コード内で以下が正しく設定されているか確認：

```dart
// lib/features/monetization/services/purchase_service.dart
static const String _entitlementId = 'premium';  // RevenueCatで設定したID
static const String _productId = 'vibe_quest_premium_500';  // 使用しない（Offeringsから取得）
```

### 5. 商品の有効化

App Store Connect側：
1. 商品のステータスが「送信準備完了」になっていることを確認
2. アプリの次回アップデート時に商品も一緒に送信

### トラブルシューティング

#### 商品が表示されない場合
1. App Store Connectで商品が「送信準備完了」になっているか確認
2. RevenueCatのProduct IDとApp Store Connectの製品IDが一致しているか確認
3. Sandboxアカウントでログインしているか確認
4. 24時間待つ（App Store側の反映に時間がかかることがある）

#### 購入できない場合
1. Sandboxアカウントの設定を確認
2. デバイスの設定 > App Store > Sandboxアカウントでログイン
3. RevenueCatのデバッグログを確認

## 重要な注意点

- **製品ID**: 一度作成すると変更できないので慎重に決める
- **価格**: App Store Connectの価格ティアから選択
- **テスト**: 必ずSandbox環境でテストしてから本番環境へ
- **審査**: App内課金を含むアップデートは審査が必要

## 次のステップ

1. アプリをビルド: `flutter build ios`
2. Xcodeでデバイス/シミュレータにインストール
3. Sandboxアカウントでテスト購入
4. RevenueCatダッシュボードで購入を確認