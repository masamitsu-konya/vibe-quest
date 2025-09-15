import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/action_recommendation.dart';
import '../services/action_generator.dart';
import '../../analysis/models/analysis_result.dart';

/// 行動提案ビュー
class ActionRecommendationsView extends StatelessWidget {
  final AnalysisResult analysisResult;
  final List<Map<String, dynamic>> responses;

  const ActionRecommendationsView({
    super.key,
    required this.analysisResult,
    required this.responses,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations = ActionGenerator.generateFromAnalysis(
      analysisResult,
      responses,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'あなたのやりたいことリスト',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${recommendations.totalCount}個のアクションを提案します',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 今すぐできること
        if (recommendations.immediateActions.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '今すぐできること',
            '5分で始められる簡単なアクション',
            Icons.flash_on,
            Colors.orange,
          ),
          ...recommendations.immediateActions.map((action) =>
            _buildActionCard(context, action),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 毎日の習慣
        if (recommendations.dailyHabits.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '毎日の習慣',
            '小さな積み重ねが大きな変化を生む',
            Icons.repeat,
            Colors.blue,
          ),
          ...recommendations.dailyHabits.map((habit) =>
            _buildHabitCard(context, habit),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 週1回の習慣
        if (recommendations.weeklyHabits.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '週1回の習慣',
            '週末を充実させるアクティビティ',
            Icons.calendar_today,
            Colors.purple,
          ),
          ...recommendations.weeklyHabits.map((habit) =>
            _buildHabitCard(context, habit),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 短期目標
        if (recommendations.shortTermGoals.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '3ヶ月以内の目標',
            '達成可能な短期目標',
            Icons.flag,
            Colors.green,
          ),
          ...recommendations.shortTermGoals.map((goal) =>
            _buildActionCard(context, goal),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 中期目標
        if (recommendations.mediumTermGoals.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '1年以内の目標',
            '本格的な成長のための中期目標',
            Icons.trending_up,
            Colors.indigo,
          ),
          ...recommendations.mediumTermGoals.map((goal) =>
            _buildActionCard(context, goal),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 長期目標
        if (recommendations.longTermGoals.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            '長期的なビジョン',
            '人生を変える大きな目標',
            Icons.star,
            Colors.amber,
          ),
          ...recommendations.longTermGoals.map((goal) =>
            _buildActionCard(context, goal),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ActionRecommendation action) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          // TODO: アクションの詳細表示
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(
                action.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _buildTag(context, action.difficulty.label),
                        const SizedBox(width: AppSpacing.xs),
                        _buildTag(context, action.timeframe.label),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitSuggestion habit) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              habit.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildHabitDetail(context, Icons.access_time, habit.trigger),
                  _buildHabitDetail(context, Icons.directions_run, habit.routine),
                  _buildHabitDetail(context, Icons.emoji_events, habit.reward),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${habit.durationMinutes}分',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitDetail(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}