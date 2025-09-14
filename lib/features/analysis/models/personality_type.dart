/// パーソナリティタイプのモデル
class PersonalityType {
  final String name;
  final String description;
  final List<String> traits;

  const PersonalityType({
    required this.name,
    required this.description,
    required this.traits,
  });
}

/// パーソナリティプロファイル（拡張版）
class PersonalityProfile {
  final String mainType;
  final String subType;
  final String description;
  final List<String> traits;
  final String strengthArea;

  const PersonalityProfile({
    required this.mainType,
    required this.subType,
    required this.description,
    required this.traits,
    required this.strengthArea,
  });
}