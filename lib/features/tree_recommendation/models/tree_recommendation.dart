import 'tree_model.dart';

class TreeRecommendation {
  const TreeRecommendation({
    required this.tree,
    required this.suitabilityPercent,
    required this.reasons,
  });

  final TreeModel tree;
  final int suitabilityPercent;
  final List<String> reasons;
}
