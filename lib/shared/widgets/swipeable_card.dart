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
                Icon(
                  _getCategoryIcon(question.category),
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
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
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: question.tags.map((tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case QuestionCategory.health:
        return Icons.favorite;
      case QuestionCategory.career:
        return Icons.work;
      case QuestionCategory.hobby:
        return Icons.palette;
      case QuestionCategory.learning:
        return Icons.school;
      case QuestionCategory.relationship:
        return Icons.people;
      case QuestionCategory.lifestyle:
        return Icons.home;
      case QuestionCategory.finance:
        return Icons.attach_money;
      case QuestionCategory.creativity:
        return Icons.lightbulb;
      case QuestionCategory.sports:
        return Icons.sports_basketball;
      case QuestionCategory.travel:
        return Icons.flight;
      default:
        return Icons.star;
    }
  }
}