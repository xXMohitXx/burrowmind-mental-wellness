import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Resource Model
class MindfulResource {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int readTime;
  final String author;
  final bool isBookmarked;

  const MindfulResource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.readTime,
    required this.author,
    this.isBookmarked = false,
  });
}

/// Course Model
class MindfulCourse {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int totalLessons;
  final int completedLessons;
  final int durationMinutes;
  final String instructor;

  const MindfulCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.totalLessons,
    required this.completedLessons,
    required this.durationMinutes,
    required this.instructor,
  });

  double get progress => completedLessons / totalLessons;
}

/// Mock data providers
final resourcesProvider = StateProvider<List<MindfulResource>>((ref) {
  return [
    const MindfulResource(
      id: '1',
      title: 'Understanding Anxiety: A Complete Guide',
      description: 'Learn about the science behind anxiety and practical strategies to manage it effectively.',
      category: 'Mental Health',
      imageUrl: '',
      readTime: 8,
      author: 'Dr. Sarah Johnson',
    ),
    const MindfulResource(
      id: '2',
      title: '10 Mindfulness Exercises for Daily Life',
      description: 'Simple techniques you can practice anywhere to stay present and reduce stress.',
      category: 'Mindfulness',
      imageUrl: '',
      readTime: 5,
      author: 'Michael Chen',
    ),
    const MindfulResource(
      id: '3',
      title: 'The Power of Gratitude Journaling',
      description: 'Discover how a simple journaling practice can transform your mental wellbeing.',
      category: 'Self-Care',
      imageUrl: '',
      readTime: 6,
      author: 'Emma Williams',
      isBookmarked: true,
    ),
    const MindfulResource(
      id: '4',
      title: 'Better Sleep: Science-Backed Tips',
      description: 'Improve your sleep quality with evidence-based techniques and habits.',
      category: 'Sleep',
      imageUrl: '',
      readTime: 10,
      author: 'Dr. James Miller',
    ),
  ];
});

final coursesProvider = StateProvider<List<MindfulCourse>>((ref) {
  return [
    const MindfulCourse(
      id: '1',
      title: 'Meditation Fundamentals',
      description: 'A beginner-friendly introduction to meditation practices.',
      imageUrl: '',
      totalLessons: 10,
      completedLessons: 3,
      durationMinutes: 45,
      instructor: 'Sarah Chen',
    ),
    const MindfulCourse(
      id: '2',
      title: 'Managing Stress at Work',
      description: 'Practical techniques for handling workplace stress.',
      imageUrl: '',
      totalLessons: 8,
      completedLessons: 8,
      durationMinutes: 60,
      instructor: 'Dr. Michael Park',
    ),
    const MindfulCourse(
      id: '3',
      title: 'Sleep Better Tonight',
      description: 'Transform your sleep with guided relaxation techniques.',
      imageUrl: '',
      totalLessons: 6,
      completedLessons: 0,
      durationMinutes: 30,
      instructor: 'Emma Wilson',
    ),
  ];
});

/// Resources Screen
class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Mental Health', 'Mindfulness', 'Self-Care', 'Sleep'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _showBookmarks(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArticlesTab(),
          _buildCoursesTab(),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    final resources = ref.watch(resourcesProvider);
    final filtered = _selectedCategory == 'All'
        ? resources
        : resources.where((r) => r.category == _selectedCategory).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return InkWell(
                  onTap: () => setState(() => _selectedCategory = category),
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      category,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Featured article
          if (filtered.isNotEmpty) ...[
            _buildFeaturedArticle(filtered.first),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Article list
          Text(
            'Latest Articles',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...filtered.skip(1).map((resource) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildArticleCard(resource),
          )),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    final courses = ref.watch(coursesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In Progress section
          Text(
            'Continue Learning',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...courses
              .where((c) => c.completedLessons > 0 && c.completedLessons < c.totalLessons)
              .map((course) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildCourseCard(course, showProgress: true),
              )),

          const SizedBox(height: AppSpacing.lg),

          // All courses
          Text(
            'All Courses',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...courses.map((course) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildCourseCard(course),
          )),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFeaturedArticle(MindfulResource resource) {
    return InkWell(
      onTap: () => _openArticle(resource),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.tertiary.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.article,
                size: 150,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                    ),
                    child: Text(
                      'Featured',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    resource.title,
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        resource.author,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${resource.readTime} min read',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(MindfulResource resource) {
    return InkWell(
      onTap: () => _openArticle(resource),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getCategoryColor(resource.category).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(resource.category),
                color: _getCategoryColor(resource.category),
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Text(
                        resource.category,
                        style: AppTypography.caption.copyWith(
                          color: _getCategoryColor(resource.category),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${resource.readTime} min',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (resource.isBookmarked)
              Icon(
                Icons.bookmark,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(MindfulCourse course, {bool showProgress = false}) {
    return InkWell(
      onTap: () => _openCourse(course),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'by ${course.instructor}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (course.progress == 1.0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.play_lesson,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${course.totalLessons} lessons',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${course.durationMinutes} min',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            if (showProgress || course.progress > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: AppColors.surface,
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${(course.progress * 100).toInt()}%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mental Health': return AppColors.primary;
      case 'Mindfulness': return AppColors.tertiary;
      case 'Self-Care': return AppColors.secondary;
      case 'Sleep': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mental Health': return Icons.psychology;
      case 'Mindfulness': return Icons.self_improvement;
      case 'Self-Care': return Icons.spa;
      case 'Sleep': return Icons.bedtime;
      default: return Icons.article;
    }
  }

  void _openArticle(MindfulResource resource) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(resource: resource),
      ),
    );
  }

  void _openCourse(MindfulCourse course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) {
        final bookmarked = ref.read(resourcesProvider).where((r) => r.isBookmarked).toList();
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Bookmarked',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (bookmarked.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No bookmarks yet',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                ...bookmarked.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildArticleCard(r),
                )),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

/// Article Detail Screen
class ArticleDetailScreen extends StatelessWidget {
  final MindfulResource resource;

  const ArticleDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.tertiary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  resource.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(resource.category).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                    ),
                    child: Text(
                      resource.category,
                      style: AppTypography.caption.copyWith(
                        color: _getCategoryColor(resource.category),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    resource.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.card,
                        child: Text(
                          resource.author[0],
                          style: AppTypography.titleSmall,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        resource.author,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${resource.readTime} min read',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.lg),

                  // Article content (placeholder)
                  Text(
                    resource.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildParagraph('Introduction', 
                    'Understanding your mental health is the first step toward building resilience and emotional wellbeing. This guide explores evidence-based strategies...'),
                  _buildParagraph('Key Concepts', 
                    'Mental wellness encompasses our emotional, psychological, and social well-being. It affects how we think, feel, and act...'),
                  _buildParagraph('Practical Strategies', 
                    '1. Practice mindfulness daily\n2. Maintain regular sleep patterns\n3. Stay connected with loved ones\n4. Exercise regularly...'),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mental Health': return AppColors.primary;
      case 'Mindfulness': return AppColors.tertiary;
      case 'Self-Care': return AppColors.secondary;
      case 'Sleep': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }
}

/// Course Detail Screen
class CourseDetailScreen extends StatelessWidget {
  final MindfulCourse course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.school,
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          course.title,
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'by ${course.instructor}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Progress card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Lessons', '${course.completedLessons}/${course.totalLessons}'),
                      _buildStat('Duration', '${course.durationMinutes} min'),
                      _buildStat('Progress', '${(course.progress * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: AppColors.surface,
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'About this course',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              course.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Lessons
            Text(
              'Lessons',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            ...List.generate(course.totalLessons, (index) {
              final isCompleted = index < course.completedLessons;
              final isCurrent = index == course.completedLessons;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isCurrent ? AppColors.secondary : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.secondary
                                : AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isCurrent
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lesson ${index + 1}',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '5 minutes',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isCompleted
                          ? Icons.replay
                          : isCurrent
                              ? Icons.play_circle_filled
                              : Icons.lock_outline,
                      color: isCurrent ? AppColors.secondary : AppColors.textTertiary,
                      size: 28,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
