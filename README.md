# Vibe Quest

ワクワクを見つける自己発見アプリ

## 概要

Vibe Questは、1000個の質問に対して「ワクワクする」「ワクワクしない」をスワイプで答えることで、あなたの本当にやりたいことや価値観を発見するアプリです。

## 機能

- 👆 左右スワイプで直感的に回答
- 📊 10個ごとに分析結果を表示
- 🎯 回答が増えるほど精度が向上
- 💫 美しいグラデーションカード

## 技術スタック

- **Flutter** - クロスプラットフォーム開発
- **Supabase** - バックエンド（データベース）
- **Riverpod** - 状態管理
- **appinio_swiper** - スワイプUI

## セットアップ

1. 依存関係のインストール
```bash
flutter pub get
```

2. 環境変数の設定
`.env`ファイルを作成し、Supabaseの認証情報を設定
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. アプリの実行
```bash
flutter run
```

## 今後の改善予定

- [ ] より詳細な分析機能
- [ ] ユーザー認証とデータ永続化
- [ ] ビジュアル分析（グラフ・チャート）
- [ ] パーソナライズされた行動提案

## License

MIT
