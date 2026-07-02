# Sandboxテストアカウント作成ガイド（最新版）

## Sandboxテストアカウントの作成方法

### 方法1: App Store Connect内で作成（現在の方法）

1. [App Store Connect](https://appstoreconnect.apple.com)にログイン
2. 「ユーザとアクセス」をクリック
3. 上部のタブから「**Sandbox**」を選択（青い文字でハイライトされているタブ）
4. 「テストアカウントを追加」ボタンをクリック
5. 以下の情報を入力：
   - **メール**: テスト用のメールアドレス（実在しないものでもOK）
     - 例: `test001@example.com`
   - **パスワード**: テスト用パスワード
   - **名前（名）**: テスト
   - **名前（姓）**: ユーザー
   - **地域**: 日本
6. 「作成」をクリック

### 方法2: Xcodeから直接作成（代替方法）

1. Xcodeを開く
2. メニューバー → 「Xcode」→「Settings」（または「Preferences」）
3. 「Accounts」タブを選択
4. Apple IDを選択
5. 「Manage Certificates」の下にある「Manage...」ボタンをクリック
6. 「+」ボタンから「Sandbox Tester」を追加

### デバイスでSandboxアカウントを使用

#### iOS 15以降
1. 設定アプリを開く
2. 「App Store」をタップ
3. 最下部の「Sandboxアカウント」をタップ
4. 作成したSandboxアカウントでサインイン

#### iOS 14以前
1. 設定アプリを開く
2. 「iTunes & App Store」をタップ
3. Apple IDをサインアウト
4. アプリ内で購入時にSandboxアカウントでサインイン

## テスト購入の手順

1. **本番のApple IDからサインアウト**
   - 設定 → App Store → Apple IDをタップ → サインアウト

2. **アプリを起動**
   - デバッグビルドまたはTestFlightビルドを使用

3. **購入フローを開始**
   - アプリ内で購入ボタンをタップ
   - Sandboxアカウントでサインインを求められる

4. **テスト購入を実行**
   - パスワードを入力
   - 「購入」をタップ（実際には課金されない）

## 注意事項

### Sandboxアカウントの制限
- 実際のApp Storeでは使用できない
- テスト専用のアカウント
- 24時間後に自動的に期限切れになる購入もある

### トラブルシューティング

#### 「このApple IDは本番環境用です」エラー
- 本番のApple IDでサインインしている
- 解決: Sandboxアカウントでサインイン

#### 商品が表示されない
- App Store Connectで商品が「送信準備完了」になっているか確認
- Bundle IDが一致しているか確認
- 24時間待つ（反映に時間がかかる場合がある）

#### 購入できない
- Sandboxアカウントが正しく設定されているか確認
- デバイスの地域設定が日本になっているか確認

## RevenueCatでの確認

1. RevenueCatダッシュボードにログイン
2. 左メニューの「**Customers**」を選択
3. Sandbox購入したユーザーが表示される
4. ユーザーをクリックして購入詳細を確認
   - Sandbox購入には特別な表示がされる
   - 購入履歴、エンタイトルメント状態を確認可能

## ベストプラクティス

1. **複数のテストアカウントを作成**
   - 新規ユーザーテスト用
   - 既存ユーザーテスト用
   - 購入復元テスト用

2. **メールアドレスの命名規則**
   ```
   sandbox.new@example.com    # 新規ユーザー
   sandbox.premium@example.com # プレミアムユーザー
   sandbox.restore@example.com # 復元テスト用
   ```

3. **パスワード管理**
   - 同じパスワードを使用してもOK
   - メモアプリなどで管理

## 参考リンク

- [Testing In-App Purchases](https://developer.apple.com/documentation/storekit/testing-in-app-purchases)
- [RevenueCat Testing Guide](https://www.revenuecat.com/docs/sandbox)