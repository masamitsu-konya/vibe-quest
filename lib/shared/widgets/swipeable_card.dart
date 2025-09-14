import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/question.dart';

class SwipeableCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const SwipeableCard({
    Key? key,
    required this.question,
    this.onSwipeLeft,
    this.onSwipeRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (AppSpacing.md * 4);  // 固定幅を設定

    return Container(
      width: cardWidth,  // 固定幅を明示的に設定
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: 24,  // 上部マージン24px
        bottom: 56,  // 下部マージン56px
      ),
      clipBehavior: Clip.antiAlias,  // はみ出した部分をクリップ
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.secondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                Text(
                  _getCategoryEmoji(question.category),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: AppSpacing.lg),
                Flexible(
                  child: Text(
                    question.text,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,  // 折り返しを有効化
                    overflow: TextOverflow.visible,  // オーバーフローを表示
                  ),
                ),
                const SizedBox(height: 40),  // メインテキストとタグの間隔を40pxに
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: question.tags.map((tag) => Text(
                    '#$tag',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case QuestionCategory.health:
        return '❤️';
      case QuestionCategory.career:
        return '💼';
      case QuestionCategory.hobby:
        return '🎨';
      case QuestionCategory.learning:
        return '📚';
      case QuestionCategory.relationship:
        return '👥';
      case QuestionCategory.lifestyle:
        return '🏠';
      case QuestionCategory.finance:
        return '💰';
      case QuestionCategory.creativity:
        return '💡';
      case QuestionCategory.sports:
        return '⚽';
      case QuestionCategory.travel:
        return '✈️';
      case 'adventure':
        return '🚀';
      case 'service':
        return '🤝';
      case 'mindfulness':
        return '🧘';
      case 'entertainment':
        return '🎬';
      default:
        return '⭐';
    }
  }
}