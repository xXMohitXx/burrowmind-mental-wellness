import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/text_fields.dart';

/// Search Screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<String> _categories = [
    'All',
    'Articles',
    'Courses',
    'Exercises',
    'Community',
  ];
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _recentSearches = [
    {'query': 'anxiety management', 'type': 'search'},
    {'query': 'sleep meditation', 'type': 'search'},
    {'query': 'breathing exercises', 'type': 'search'},
  ];

  final List<Map<String, dynamic>> _popularTopics = [
    {'title': 'Managing Stress', 'icon': Icons.psychology},
    {'title': 'Better Sleep', 'icon': Icons.nightlight},
    {'title': 'Mindfulness', 'icon': Icons.self_improvement},
    {'title': 'Anxiety Relief', 'icon': Icons.healing},
    {'title': 'Gratitude', 'icon': Icons.favorite},
    {'title': 'Focus', 'icon': Icons.center_focus_strong},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
            child: SearchTextField(
              controller: _searchController,
              autofocus: true,
              hint: 'Search articles, courses, exercises...',
              onChanged: (value) => setState(() => _query = value),
              onClear: () => setState(() => _query = ''),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                    ),
                    child: Text(
                      category,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Content
          Expanded(
            child: _query.isEmpty ? _buildIdleContent() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            ...List.generate(_recentSearches.length, (index) {
              final search = _recentSearches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: AppColors.textTertiary),
                title: Text(
                  search['query'],
                  style: AppTypography.bodyMedium,
                ),
                trailing: const Icon(Icons.north_west, color: AppColors.textTertiary, size: 16),
                onTap: () {
                  _searchController.text = search['query'];
                  setState(() => _query = search['query']);
                },
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Popular topics
          Text(
            'Popular Topics',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _popularTopics.map((topic) {
              return InkWell(
                onTap: () {
                  _searchController.text = topic['title'];
                  setState(() => _query = topic['title']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(topic['icon'], size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        topic['title'],
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Mock search results
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Searching for "$_query"',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Search results coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
