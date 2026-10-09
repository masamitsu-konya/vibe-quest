# Supabase セットアップ（価値観マッチング基盤）

## 適用が必要なマイグレーション

**注意: `supabase db push` は必ずまさみつが手動で実行する（CLAUDE.md の制約）。**

```bash
cd ~/apps/vibe-quest
supabase db push
```

| ファイル | 内容 |
|---------|------|
| `20260703000001_values_matching_foundation.sql` | swipe_responses / values_profiles テーブル + RLS |
| `20260703000002_matching.sql`（Phase 4 で追加予定） | likes / matches / messages + マッチング RPC |

## ダッシュボード設定（手動・1回だけ）

### 1. 匿名サインインの有効化

アプリはサインアップ障壁ゼロのため匿名認証を使う。

1. https://supabase.com/dashboard/project/ztaakebbntapjlqolkcx へ
2. Authentication → Sign In / Up → **Anonymous Sign-Ins を ON**

これを忘れるとアプリ起動時のサインインが失敗する
（アプリはローカルのみで動き続けるが、同期・マッチングが動かない）。

### 2. 環境変数（設定済みなら不要）

`.env` に以下が必要:

```
SUPABASE_URL=https://ztaakebbntapjlqolkcx.supabase.co
SUPABASE_ANON_KEY=<anon key>
```

## ローカル開発（任意）

```bash
supabase start          # ローカルスタック起動（Docker 必須）
supabase db reset       # ローカル DB にマイグレーション適用
```

ローカルで使う場合は `.env` の URL / key をローカルの値に差し替える。

## 設計メモ

- 質問データはアプリ内（`lib/data/questions_data.dart`）にあり、サーバーには置かない。
  `swipe_responses.question_id` は TEXT（'1'〜'1020'）
- 旧テーブル（questions / user_responses / user_profiles / habits / avoid_list /
  analysis_results）はサーバー駆動設計時代の遺物で現行アプリからは未使用。
  データ確認後、別マイグレーションで DROP してよい
- 同期はローカルファースト: 失敗してもアプリは動く。10問ごと + 起動時に差分同期
