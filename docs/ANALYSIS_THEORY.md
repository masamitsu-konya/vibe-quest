# Vibe Quest 分析理論の背景

## 概要
Vibe Questの性格分析システムは、複数の確立された心理学理論を統合して、ユーザーの深層的な価値観と動機を理解することを目的としています。

## 理論的基盤

### 1. 自己決定理論（Self-Determination Theory, SDT）
**提唱者**: Edward L. Deci & Richard M. Ryan (1985)

SDTは人間の動機づけと人格の発達に関する理論で、3つの基本的な心理的欲求を提唱しています：

- **自律性（Autonomy）**: 自分の行動を自分で決定したいという欲求
- **有能感（Competence）**: 効果的に環境と関わり、望む結果を達成したいという欲求
- **関係性（Relatedness）**: 他者とつながり、愛し愛されたいという欲求

**実装**: 各質問に`sdt_autonomy`、`sdt_competence`、`sdt_relatedness`のスコアを設定

### 2. 生きがい（Ikigai）フレームワーク
**起源**: 日本の伝統的な概念、Marc Winnによって西洋向けに体系化

4つの要素の交差点で「生きがい」を見出す：

- **Love（好きなこと）**: 情熱を感じること
- **Good at（得意なこと）**: スキルや才能
- **World needs（世界が必要としていること）**: 社会的な需要
- **Paid for（お金になること）**: 経済的な価値

**実装**: 各質問に`ikigai_love`、`ikigai_good_at`、`ikigai_world_needs`、`ikigai_paid_for`のスコアを設定

### 3. ビッグファイブ性格特性（Big Five Personality Traits）
**研究者**: Lewis Goldberg他、多数の研究者による確立

5つの主要な性格次元：

- **開放性（Openness）**: 新しい経験への開放性、創造性、好奇心
- **誠実性（Conscientiousness）**: 自己規律、達成志向、組織性
- **外向性（Extraversion）**: 社交性、活動性、積極性
- **協調性（Agreeableness）**: 思いやり、協力性、信頼性
- **神経症傾向（Neuroticism）**: 感情の安定性、ストレス耐性

**実装**: 各質問に`big5_openness`、`big5_conscientiousness`、`big5_extraversion`、`big5_agreeableness`、`big5_neuroticism`のスコアを設定

### 4. 内発的・外発的動機づけ理論
**基盤**: SDTの拡張概念

- **内発的動機（Intrinsic）**: 活動自体への興味や楽しさから生じる動機
- **外発的動機（Extrinsic）**: 外部からの報酬や評価によって生じる動機
- **混合型（Mixed）**: 内発的・外発的要素の両方を含む

**実装**: 各質問に`motivation_type`を設定

## パーソナリティタイプの定義

### 5つの基本タイプ

#### 1. Explorer（探求者型）
- **特徴**: 高い開放性、自律性重視
- **判定基準**: `openness > 0.7 && autonomy > 0.6`
- **心理学的根拠**: 好奇心と自己決定の組み合わせが探索行動を促進

#### 2. Creator（創造者型）
- **特徴**: 高い開放性、情熱重視
- **判定基準**: `openness > 0.6 && love > 0.7`
- **心理学的根拠**: 創造性と内発的動機の強い相関

#### 3. Supporter（支援者型）
- **特徴**: 高い協調性、関係性重視、社会貢献志向
- **判定基準**: `agreeableness > 0.7 && relatedness > 0.7 && worldNeeds > 0.6`
- **心理学的根拠**: 向社会的行動と関係性欲求の関連

#### 4. Challenger（挑戦者型）
- **特徴**: 高い誠実性、有能感重視
- **判定基準**: `conscientiousness > 0.7 && competence > 0.7`
- **心理学的根拠**: 達成動機と自己効力感の重要性

#### 5. Harmonizer（調和型）
- **特徴**: バランス重視、安定志向
- **判定基準**: 他のタイプに該当しない場合
- **心理学的根拠**: 均衡理論、ホメオスタシス的アプローチ

## 質問設計の原則

### 1. 多次元評価
各質問は複数の心理学的次元で評価され、単一の回答から多面的な洞察を得られるよう設計

### 2. カテゴリー分散
10のカテゴリー（hobby、learning、health、creativity、relationship、adventure、service、mindfulness、entertainment、career）に均等に分散

### 3. スコアリング範囲
- 全てのスコアは0.0〜1.0の範囲で正規化
- growth_scoreは総合的な成長可能性を示す

### 4. 統計的信頼性
- 最低1000問の質問プールを用意
- ランダムサンプリングによる偏りの排除
- 10回ごとの分析で傾向の安定性を確認

## 分析アルゴリズム

### 1. データ収集
- スワイプ方向（右：興味あり、左：興味なし）を記録
- タイムスタンプで時系列変化を追跡

### 2. スコア集計
```
平均スコア = Σ(質問のスコア × 興味度) / 質問数
```

### 3. パターン認識
- 閾値ベースの判定（例：スコア > 0.7で「高い」と判定）
- 複数指標の組み合わせによる複合的判定

### 4. 洞察生成
- ルールベース：事前定義されたパターンに基づく
- スコア比較：相対的な強弱から特徴を抽出

## 参考文献とリソース

### 自己決定理論（SDT）関連

1. **原著論文**
   - Deci, E. L., & Ryan, R. M. (1985). Intrinsic motivation and self-determination in human behavior. New York: Plenum.
   - Ryan, R. M., & Deci, E. L. (2000). Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being. American Psychologist, 55(1), 68-78.
   - PDF: https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf

2. **公式ウェブサイト**
   - Self-Determination Theory公式サイト: https://selfdeterminationtheory.org/
   - 理論の概要: https://selfdeterminationtheory.org/theory/
   - 研究論文アーカイブ: https://selfdeterminationtheory.org/publications/

3. **日本語リソース**
   - SDT日本語解説: https://www.jstage.jst.go.jp/article/jjep/60/1/60_1_111/_article/-char/ja/
   - 動機づけ理論の応用: https://www.jstage.jst.go.jp/article/sjpr/55/1/55_1_160/_article/-char/ja/

### ビッグファイブ（Big Five）関連

1. **基礎研究**
   - Goldberg, L. R. (1993). The structure of phenotypic personality traits. American Psychologist, 48(1), 26-34.
   - DOI: https://doi.org/10.1037/0003-066X.48.1.26
   - Costa, P. T., & McCrae, R. R. (1992). NEO PI-R professional manual. Psychological Assessment Resources.
   - John, O. P., & Srivastava, S. (1999). The Big Five trait taxonomy: History, measurement, and theoretical perspectives.
   - PDF: https://www.ocf.berkeley.edu/~johnlab/bfi.htm

2. **オンラインリソース**
   - IPIP (International Personality Item Pool): https://ipip.ori.org/
   - Big Five測定ツール: https://www.truity.com/test/big-five-personality-test
   - 学術的レビュー: https://www.annualreviews.org/doi/10.1146/annurev-psych-120710-100452

### 生きがい（Ikigai）関連

1. **学術研究**
   - Kamiya, M. (1966). 生きがいについて (On Ikigai). Misuzu Shobo.
   - Sone, T., et al. (2008). Sense of life worth living (ikigai) and mortality in Japan: Ohsaki Study.
   - PDF: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2650981/
   - Mitsuhashi, Y. (2018). Ikigai: A Japanese concept to improve work and life.
   - Link: https://www.bbc.com/worklife/article/20170807-ikigai-a-japanese-concept-to-improve-work-and-life

2. **フレームワーク解説**
   - Marc Winn's Ikigai Diagram: https://theviewinside.me/what-is-your-ikigai/
   - 批判的考察: https://ikigaitribe.com/ikigai/ikigai-misunderstood/
   - 日本文化における生きがい: https://www.japan-experience.com/to-know/japanese-culture/ikigai

### フロー理論関連

1. **Csikszentmihalyi の研究**
   - Csikszentmihalyi, M. (1990). Flow: The Psychology of Optimal Experience. Harper & Row.
   - Csikszentmihalyi, M. (1997). Finding Flow: The Psychology of Engagement with Everyday Life.
   - TED Talk: https://www.ted.com/talks/mihaly_csikszentmihalyi_flow_the_secret_to_happiness

### 内発的・外発的動機づけ

1. **基礎理論**
   - Deci, E. L. (1971). Effects of externally mediated rewards on intrinsic motivation.
   - PDF: https://selfdeterminationtheory.org/SDT/documents/1971_Deci.pdf
   - Gagné, M., & Deci, E. L. (2005). Self-determination theory and work motivation.
   - DOI: https://doi.org/10.1002/job.322

2. **実践的応用**
   - Pink, D. H. (2009). Drive: The Surprising Truth About What Motivates Us.
   - RSA Animate: https://www.youtube.com/watch?v=u6XAPnuFjJc

### ウェルビーイング関連

1. **PERMA モデル**
   - Seligman, M. E. P. (2011). Flourish: A Visionary New Understanding of Happiness and Well-being.
   - 公式サイト: https://www.authentichappiness.sas.upenn.edu/
   - PERMA測定ツール: https://www.permahsurvey.com/

2. **日本のウェルビーイング研究**
   - 内閣府: https://www5.cao.go.jp/keizai2/wellbeing/index.html
   - 慶應義塾大学ウェルビーイング研究センター: https://www.kri.keio.ac.jp/

### データベースとアーカイブ

1. **学術論文データベース**
   - Google Scholar: https://scholar.google.com/
   - PubMed: https://pubmed.ncbi.nlm.nih.gov/
   - J-STAGE: https://www.jstage.jst.go.jp/

2. **オープンアクセス論文**
   - PLOS ONE: https://journals.plos.org/plosone/
   - Frontiers in Psychology: https://www.frontiersin.org/journals/psychology
   - ResearchGate: https://www.researchgate.net/

### 実装の参考資料

1. **性格診断の実装例**
   - 16Personalities: https://www.16personalities.com/
   - Understanding Myself (Jordan Peterson): https://www.understandmyself.com/
   - VIA Character Strengths: https://www.viacharacter.org/

2. **統計的検証**
   - 信頼性と妥当性: https://www.statisticshowto.com/reliability-validity/
   - 因子分析: https://www.ibm.com/topics/factor-analysis

## 今後の拡張可能性

### 1. 機械学習の導入
- ユーザーのスワイプパターンから個別化された分析モデルを構築
- クラスタリング手法による新しいパーソナリティタイプの発見

### 2. 縦断的研究
- 時系列データを活用した成長・変化の追跡
- 季節性や周期性の分析

### 3. 文化的適応
- 地域・文化による価値観の違いを反映
- 多文化対応のパーソナリティモデル

### 4. 統合的ウェルビーイング指標
- PERMA（Positive Emotion, Engagement, Relationships, Meaning, Achievement）モデルの統合
- ウェルビーイングスコアの算出

## ライセンスと倫理的配慮

- 心理学的評価は自己理解のためのツールであり、診断ツールではない
- プライバシーとデータ保護の徹底
- ポジティブな自己発見を促進する設計