import '../models/personality_type.dart';

/// パーソナリティタイプの定義
class PersonalityConstants {
  static const Map<String, PersonalityType> personalityTypes = {
    'explorer': PersonalityType(
      name: '探求者型',
      description: '新しい知識や経験を求め、常に学び続けることに喜びを感じるタイプ',
      traits: ['好奇心旺盛', '学習意欲が高い', '新しいことへの挑戦を恐れない'],
    ),
    'creator': PersonalityType(
      name: '創造者型',
      description: '自己表現や創作活動を通じて、世界に新しい価値を生み出すタイプ',
      traits: ['想像力豊か', '独創的', '美的センスが高い'],
    ),
    'supporter': PersonalityType(
      name: '支援者型',
      description: '他者との関わりや社会貢献を通じて、充実感を得るタイプ',
      traits: ['共感力が高い', '協調性がある', '人の役に立ちたい'],
    ),
    'challenger': PersonalityType(
      name: '挑戦者型',
      description: '高い目標を設定し、自己成長と達成感を追求するタイプ',
      traits: ['目標志向', '競争心が強い', '自己規律が高い'],
    ),
    'harmonizer': PersonalityType(
      name: '調和型',
      description: 'バランスの取れた生活と内面の平和を大切にするタイプ',
      traits: ['安定志向', 'マインドフル', '自己認識が高い'],
    ),
  };

  // サブタイプの定義
  static const Map<String, PersonalityProfile> personalityProfiles = {
    'explorer_pioneer': PersonalityProfile(
      mainType: '探求者',
      subType: '開拓者',
      description: '未知の領域を恐れず、常に新しい可能性を追求する冒険家タイプ',
      traits: ['先駆的', '独立心旺盛', '革新的思考'],
      strengthArea: '新規開拓・イノベーション',
    ),
    'explorer_scholar': PersonalityProfile(
      mainType: '探求者',
      subType: '学究者',
      description: '知識の深淵を追求し、理論と実践を結びつける研究者タイプ',
      traits: ['分析的', '体系的思考', '知的好奇心'],
      strengthArea: '研究・分析・理論構築',
    ),
    'explorer_wanderer': PersonalityProfile(
      mainType: '探求者',
      subType: '放浪者',
      description: '多様な経験を通じて自己を発見する自由人タイプ',
      traits: ['柔軟性', '適応力', '多角的視点'],
      strengthArea: '異文化理解・適応力',
    ),
    'creator_artist': PersonalityProfile(
      mainType: '創造者',
      subType: '芸術家',
      description: '感性と技術を融合させ、美的価値を生み出すアーティストタイプ',
      traits: ['審美眼', '表現力', '感受性'],
      strengthArea: '芸術・デザイン・美的創造',
    ),
    'creator_innovator': PersonalityProfile(
      mainType: '創造者',
      subType: '革新者',
      description: '既存の枠組みを超えて、新しい価値を創造するイノベータータイプ',
      traits: ['発想力', '実行力', '変革志向'],
      strengthArea: 'イノベーション・問題解決',
    ),
    'creator_builder': PersonalityProfile(
      mainType: '創造者',
      subType: '構築者',
      description: 'アイデアを形にし、持続可能なシステムを作り上げるビルダータイプ',
      traits: ['構築力', '計画性', '実現力'],
      strengthArea: 'システム構築・プロジェクト管理',
    ),
    'supporter_mentor': PersonalityProfile(
      mainType: '支援者',
      subType: '導師',
      description: '他者の成長を導き、潜在能力を引き出すメンタータイプ',
      traits: ['洞察力', '忍耐力', '育成力'],
      strengthArea: '人材育成・コーチング',
    ),
    'supporter_healer': PersonalityProfile(
      mainType: '支援者',
      subType: '癒し手',
      description: '心身の癒しを提供し、他者の回復を支援するヒーラータイプ',
      traits: ['共感力', '包容力', '癒しの力'],
      strengthArea: 'ケア・サポート・癒し',
    ),
    'supporter_connector': PersonalityProfile(
      mainType: '支援者',
      subType: '繋ぎ手',
      description: '人と人を結び、コミュニティを育むコネクタータイプ',
      traits: ['社交性', 'ネットワーク力', '調整力'],
      strengthArea: 'コミュニティ構築・連携',
    ),
    'challenger_warrior': PersonalityProfile(
      mainType: '挑戦者',
      subType: '戦士',
      description: '困難に立ち向かい、限界を突破する戦士タイプ',
      traits: ['勇気', '不屈の精神', '突破力'],
      strengthArea: '困難克服・目標達成',
    ),
    'challenger_strategist': PersonalityProfile(
      mainType: '挑戦者',
      subType: '戦略家',
      description: '長期的視点で計画を立て、着実に目標を達成する戦略家タイプ',
      traits: ['戦略的思考', '計画力', '先見性'],
      strengthArea: '戦略立案・長期計画',
    ),
    'challenger_competitor': PersonalityProfile(
      mainType: '挑戦者',
      subType: '競争者',
      description: '競争を通じて自己を高め、卓越性を追求する競争者タイプ',
      traits: ['競争心', '向上心', '成果志向'],
      strengthArea: '競争・パフォーマンス向上',
    ),
    'harmonizer_mediator': PersonalityProfile(
      mainType: '調和者',
      subType: '調停者',
      description: '対立を解消し、バランスの取れた解決策を見出す調停者タイプ',
      traits: ['公平性', '冷静さ', '調整力'],
      strengthArea: '紛争解決・調整',
    ),
    'harmonizer_philosopher': PersonalityProfile(
      mainType: '調和者',
      subType: '哲学者',
      description: '内省と洞察を通じて、人生の意味を探求する哲学者タイプ',
      traits: ['内省的', '洞察力', '俯瞰的視点'],
      strengthArea: '思索・意味探求',
    ),
    'harmonizer_gardener': PersonalityProfile(
      mainType: '調和者',
      subType: '庭師',
      description: '環境を整え、持続可能な成長を促す庭師タイプ',
      traits: ['育成力', '忍耐力', '環境配慮'],
      strengthArea: '環境整備・持続的成長',
    ),
  };
}