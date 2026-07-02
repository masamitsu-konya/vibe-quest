# App Store Connect 新規アプリ作成ガイド

## 前提条件
- Apple Developer Program に登録済み（年間$99/12,980円）
- Apple Developer アカウントでログイン可能
- Bundle ID を決めている（例: `com.yourcompany.vibequest`）

## 手順

### 1. Apple Developer Portalで準備

#### App IDの作成
1. [Apple Developer Portal](https://developer.apple.com)にログイン
2. 「Certificates, Identifiers & Profiles」をクリック
3. 左メニューの「Identifiers」を選択
4. 「+」ボタンをクリック
5. 「App IDs」を選択して「Continue」
6. 「App」を選択して「Continue」
7. 以下を入力：
   - **Description**: `Vibe Quest`
   - **Bundle ID**: `Explicit`を選択
   - **Bundle ID**: `com.yourcompany.vibequest`（実際のBundle IDに置き換え）
8. **Capabilities**で必要な機能を選択：
   - ✅ In-App Purchase（課金機能用）
   - ✅ Push Notifications（必要に応じて）
9. 「Continue」→「Register」

### 2. App Store Connectで新規アプリ作成

#### 基本手順
1. [App Store Connect](https://appstoreconnect.apple.com)にログイン
2. 「マイApp」をクリック
3. 「+」ボタンまたは「新規App」をクリック
4. プラットフォームで「iOS」を選択

#### アプリ情報の入力
以下の情報を入力：

**基本情報**
- **名前**: `Vibe Quest`（App Storeに表示される名前）
- **プライマリ言語**: `日本語`または`英語（アメリカ）`
- **Bundle ID**: 先ほど作成したものを選択
- **SKU**: `vibe-quest-001`（任意の一意の識別子）
- **ユーザーアクセス**: `フルアクセス`

**追加情報**
- **App Store Connect ユーザー**: 必要に応じて追加

5. 「作成」をクリック

### 3. アプリ情報の設定

アプリ作成後、以下の情報を設定：

#### App情報タブ
1. **カテゴリ**:
   - プライマリ: `ライフスタイル`または`ヘルスケア/フィットネス`
   - セカンダリ: 任意
2. **コンテンツの権利**: 第三者コンテンツの有無を選択
3. **年齢制限指定**: アンケートに回答

#### 価格および配信状況
1. **価格**: `0`（無料）を選択
2. **配信地域**: 全地域または特定地域を選択

#### App内課金
1. 「管理」→「+」で商品を追加
2. タイプを選択：
   - **非消費型**: 一度購入すれば永続的に有効（推奨）
3. 以下を設定：
   - **参照名**: `Vibe Quest Premium`
   - **製品ID**: `vibe_quest_premium_500`
   - **価格**: Tier 5（¥500）

### 4. アプリのバージョン情報

#### 1.0 提出準備
左メニューの「1.0 提出準備」を選択し、以下を入力：

**スクリーンショット**
- 6.7インチ（必須）: 1290 x 2796 px
- 6.5インチ: 1242 x 2688 px または 1284 x 2778 px
- 5.5インチ: 1242 x 2208 px

**プロモーションテキスト**
```
自分探しの新しい形。1000の質問に答えて、あなたの「やりたいこと」を発見しよう。
```

**説明**
```
Vibe Questは、楽しくスワイプしながら自己理解を深められる自己発見アプリです。

【主な機能】
• 1000以上の厳選された質問
• スワイプで簡単に回答
• 50問ごとに詳細な分析
• 具体的な行動提案とやりたいことリスト
• 習慣化のためのアドバイス

【プレミアム機能（¥500）】
• 広告なしで快適に利用
• 分析結果のエクスポート（CSV/Markdown）
• Apple Remindersとの連携
• 他のタスク管理アプリとの連携

あなたの新しい一歩を、Vibe Questがサポートします。
```

**キーワード**
```
自己分析,性格診断,自己理解,習慣化,目標設定,ライフスタイル,自己啓発
```

**サポートURL**: あなたのウェブサイトURL
**マーケティングURL**: オプション

**バージョン情報**
- **バージョン**: `1.0.0`
- **著作権**: `© 2024 Your Company Name`

**App Review情報**
- **サインイン情報**: テストアカウント（必要な場合）
- **連絡先情報**: レビュー時の連絡先
- **メモ**: アプリの使い方や特記事項

### 5. ビルドのアップロード

#### Xcodeでアーカイブ作成
1. Flutterプロジェクトで：
```bash
flutter build ios --release
```

2. Xcodeを開く：
```bash
open ios/Runner.xcworkspace
```

3. Xcodeで設定確認：
   - **Team**: Apple Developerアカウントを選択
   - **Bundle Identifier**: App Store Connectと一致
   - **Version**: 1.0.0
   - **Build**: 1

4. デバイスを「Any iOS Device」に設定

5. メニューから「Product」→「Archive」

6. アーカイブ完了後、「Distribute App」をクリック

7. 以下を選択：
   - App Store Connect
   - Upload
   - 自動管理を選択
   - アップロード

#### TestFlight設定
1. App Store Connectに戻る
2. 「TestFlight」タブを選択
3. ビルドが処理されるのを待つ（15-30分）
4. ビルドが利用可能になったら：
   - 「輸出コンプライアンス」に回答
   - 暗号化を使用していない場合は「いいえ」
5. テスターを招待

### 6. 審査提出

#### 提出前チェックリスト
- [ ] すべての必須情報が入力済み
- [ ] スクリーンショットがアップロード済み
- [ ] ビルドが選択済み
- [ ] App内課金の設定完了
- [ ] プライバシーポリシーURL設定済み

#### 提出
1. 「審査へ提出」をクリック
2. 広告識別子（IDFA）の使用について回答
3. 「提出」をクリック

### 7. 審査期間

- **初回審査**: 通常2-7日
- **アップデート**: 通常1-3日
- **迅速な審査リクエスト**: 緊急の場合のみ

### トラブルシューティング

#### Bundle IDが選択できない
- Apple Developer PortalでApp IDが作成されているか確認
- 正しいTeamでログインしているか確認

#### ビルドが表示されない
- 処理中の可能性（最大1時間待つ）
- Xcodeで正しいBundle IDでアップロードしたか確認
- ビルドのバージョン番号が前回より大きいか確認

#### 審査でリジェクトされた場合
- Resolution Centerでフィードバックを確認
- 指摘事項を修正
- 必要に応じてアプリ審査チームに返信
- 再提出

### 参考リンク

- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### 注意事項

1. **アプリ名**: 他のアプリと重複しない、30文字以内
2. **Bundle ID**: 一度作成すると変更不可
3. **スクリーンショット**: 実際のアプリ画面を使用
4. **課金**: 明確な価値提供と説明が必要
5. **プライバシー**: データ収集する場合はプライバシーポリシー必須

## 次のステップ

1. TestFlightでベータテスト
2. フィードバックを元に改善
3. 本番リリース
4. アプリのマーケティング開始