# Vibe Quest

**スワイプで価値観を炙り出し、自分を理解し、価値観の合う人とつながるアプリ。**

質問カードを右（ワクワクする）/ 左（しない）にスワイプするだけで、自分では言語化
できていなかった価値観が浮かび上がる。自己理解の道具として無料で使え、その先で
価値観の合う人とのマッチング（月額サブスクリプション）につながる。

## 機能

### 発見（無料）
- 👆 1000問超の質問を左右スワイプで直感回答
- 📊 50問ごとに性格・動機・生きがい分析（SDT / ikigai / Big Five）
- 💡 分析結果から具体的な行動提案を自動生成

### 自己理解（無料 / ¥200買い切りで広告除去）
- 🧭 27次元の価値観プロファイル（価値観トップ5の言語化 + 領域別親和度）
- 💾 回答はローカル永続化 + サーバー同期（匿名認証、オフラインでも動作）

### つながり（月額サブスクリプション）
- 💫 価値観の一致度順にマッチング候補を表示
- 🤝 相互 Like でマッチ成立
- 💬 マッチした相手とリアルタイムチャット

## 技術スタック

- **Flutter** + **Riverpod** — クロスプラットフォーム / 状態管理
- **Supabase** — 匿名認証・データ同期・マッチング（RLS + SECURITY DEFINER RPC）・Realtime チャット
- **RevenueCat** — 課金（買い切り `premium` / 月額 `matching`）
- **Google AdMob** — 無料版の広告
- **appinio_swiper** — スワイプUI

## セットアップ

1. 依存関係のインストール

```bash
flutter pub get
```

2. 環境変数の設定（`.env`）

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
REVENUECAT_API_KEY_IOS=your_revenuecat_ios_key
REVENUECAT_API_KEY_ANDROID=your_revenuecat_android_key
```

3. Supabase のセットアップ（マイグレーション適用・匿名認証の有効化）

→ `docs/SUPABASE_SETUP.md`

4. RevenueCat / App Store Connect の商品設定

→ `docs/REVENUECAT_PRODUCT_SETUP.md`

5. アプリの実行

```bash
flutter run
```

## テスト

```bash
flutter analyze   # 静的解析（0 issues 維持）
flutter test      # 単体テスト
```

## ドキュメント

| ファイル | 内容 |
|---------|------|
| `docs/CONCEPT_AND_ROADMAP.md` | コンセプト・価値の3層構造・アーキテクチャ決定 |
| `docs/SUPABASE_SETUP.md` | DB マイグレーション・匿名認証の設定 |
| `docs/REVENUECAT_PRODUCT_SETUP.md` | 課金商品の設定手順 |
| `docs/ANALYSIS_THEORY.md` | 分析の理論的背景（SDT / ikigai / Big Five） |

## License

MIT
