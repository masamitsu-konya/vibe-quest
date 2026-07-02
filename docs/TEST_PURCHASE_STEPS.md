# テスト購入の実行手順

## 前提条件
✅ App Store Connectで商品作成済み
✅ RevenueCatで商品設定済み
✅ Sandboxテストアカウント作成済み
✅ アプリにRevenueCat SDK組み込み済み

## テスト購入の流れ

### 1. アプリのビルドと実行

```bash
# iOSシミュレータまたは実機で実行
flutter run
```

または

```bash
# リリースモードでビルド
flutter build ios --release

# Xcodeで開く
open ios/Runner.xcworkspace
# Device選択 → Run
```

### 2. Sandboxアカウントの設定

#### iOSデバイスの場合
1. 設定 → App Store
2. 一番下の「Sandboxアカウント」
3. Sandboxテストアカウントでサインイン

#### シミュレータの場合
- 購入時に自動的にサインインプロンプトが表示される

### 3. アプリ内でテスト購入

1. **アプリを起動**
2. **設定画面を開く**
   - SwipeScreen右上の設定アイコンをタップ
3. **「プレミアムにアップグレード (¥500)」をタップ**
4. **Sandboxアカウントでサインイン**
   - メール: 作成したSandboxアカウント
   - パスワード: 設定したパスワード
5. **購入確認画面**
   - 「[環境: Sandbox]」と表示される
   - 実際の課金はされない
6. **「購入」をタップ**

### 4. 購入完了の確認

#### アプリ内で確認
- 設定画面のステータスが「プレミアム会員」に変更
- 広告が表示されなくなる

#### RevenueCatダッシュボードで確認
1. 「Customers」ページを開く
2. 左サイドバーの「**Sandbox**」をクリック
3. 購入したユーザーが表示される
4. ユーザーをクリックして詳細確認

## トラブルシューティング

### 「商品が見つかりません」エラー

**原因と対処法:**
1. **Bundle IDの不一致**
   - Xcode: Runner → General → Bundle Identifier確認
   - App Store Connect: アプリ情報で確認
   - 一致していることを確認

2. **商品IDの不一致**
   - App Store Connect: 製品ID確認
   - RevenueCat: Products → Identifer確認
   - 完全一致が必要

3. **商品が反映されていない**
   - App Store Connectで「送信準備完了」になっているか確認
   - 24時間待つ（反映に時間がかかる場合）

4. **RevenueCat設定ミス**
   - APIキーが正しく設定されているか確認
   - Offering/Package設定を確認

### 「購入に失敗しました」エラー

1. **Sandboxアカウントの問題**
   - 正しいSandboxアカウントでサインインしているか
   - アカウントの地域が日本になっているか

2. **ネットワーク接続**
   - インターネット接続を確認
   - VPNを使用している場合は切断

### RevenueCatにユーザーが表示されない

1. **購入が完了していない**
   - アプリで購入フローを最後まで完了する

2. **フィルター設定**
   - 左サイドバーで「Sandbox」を選択
   - 「Active subscription」ではなく「Non-subscription」も確認

3. **遅延**
   - 数分待つ（反映に時間がかかる場合）

## デバッグログの確認

### Xcodeコンソール
```
// RevenueCat初期化成功
RevenueCat初期化成功

// 購入成功時
[Purchases] - INFO: Purchase successful

// エラー時
[Purchases] - ERROR: 詳細なエラーメッセージ
```

### Flutter Debug Console
```bash
flutter run --verbose
```

## 次のステップ

1. ✅ テスト購入が成功
2. ✅ RevenueCatで確認
3. → **購入の復元をテスト**
4. → **別のSandboxアカウントでテスト**
5. → **TestFlightでベータテスト**
6. → **本番リリース準備**

## 重要な注意点

⚠️ **Sandboxでのテスト購入は無料**
- 実際の請求は発生しない
- テスト環境であることを示す表示がある

⚠️ **本番環境との違い**
- Sandbox: すぐに購入処理が完了
- 本番: Apple IDの認証が必要

⚠️ **購入の有効期限**
- Sandboxの非消費型購入は永続的
- サブスクリプションは短縮された期間で更新