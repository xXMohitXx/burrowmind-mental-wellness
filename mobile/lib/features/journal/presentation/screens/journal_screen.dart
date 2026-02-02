import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/providers/journal_provider.dart' as provider;
import '../widgets/journal_calendar.dart';
import '../widgets/journal_entry_card.dart';

/// Journal Entry Model - UI version (compatible with widgets)
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final int? mood; // 1-5 scale
  final List<String> tags;
  final bool hasVoiceNote;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.mood,
    this.tags = const [],
    this.hasVoiceNote = false,
  });

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '';
    }
  }

  /// Convert from provider model to UI model
  factory JournalEntry.fromProvider(provider.JournalEntry entry) {
    return JournalEntry(
      id: entry.id,
      title: entry.displayTitle,
      content: entry.content,
      timestamp: entry.createdAt,
      mood: null, // TODO: Link to mood entry if needed
      tags: entry.tags,
      hasVoiceNote: entry.voiceRecordingPath != null,
    );
  }
}

/// Journal entries provider using the database-backed provider
final journalEntriesProvider = Provider<AsyncValue<List<JournalEntry>>>((ref) {
  return ref.watch(provider.journalEntriesProvider).whenData(
        (entries) => entries.map((e) => JournalEntry.fromProvider(e)).toList(),
      );
});

/// Journal Screen
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

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
        title: const Text('My Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntriesTab(),
          _buildCalendarTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEntrySheet(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.edit, color: AppColors.textPrimary),
        label: Text(
          'New Entry',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEntriesTab() {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return entriesAsync.when(
      data: (entries) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats overview
            _buildStatsCard(entries),

            const SizedBox(height: AppSpacing.lg),

            // Recent entries header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Entries',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Journal entries list
            if (entries.isEmpty)
              _buildEmptyState()
            else
              ...entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: JournalEntryCard(
                      entry: entry,
                      onTap: () => _openEntryDetail(entry),
                    ),
                  )),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading entries: $e'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit_note,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No journal entries yet',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            text: 'Write Your First Entry',
            onPressed: () => _showNewEntrySheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        // Get entries for selected date
        final selectedEntries = entries.where((e) {
          final entryDate =
              DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
          final selected = DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day);
          return entryDate == selected;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar widget
              JournalCalendar(
                selectedDate: _selectedDate,
                entries: entries,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Entries for selected date
              Text(
                _formatDateHeader(_selectedDate),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              if (selectedEntries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No entries for this day',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SecondaryButton(
                        text: 'Write Entry',
                        onPressed: () => _showNewEntrySheet(context),
                      ),
                    ],
                  ),
                )
              else
                ...selectedEntries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: JournalEntryCard(
                        entry: entry,
                        onTap: () => _openEntryDetail(entry),
                      ),
                    )),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading entries: $e'),
      ),
    );
  }

  Widget _buildStatsCard(List<JournalEntry> entries) {
    final thisWeek = entries
        .where((e) => e.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;
    final thisMonth = entries
        .where((e) => e.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;
    final streak = 5; // Mock streak

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.3),
            AppColors.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Journal Stats',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('This Week', '$thisWeek', Icons.calendar_today),
              _buildStat('This Month', '$thisMonth', Icons.date_range),
              _buildStat('Streak', '$streak days', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return 'Today\'s Entries';
    if (selected == today.subtract(const Duration(days: 1)))
      return 'Yesterday\'s Entries';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return 'Entries for ${months[date.month - 1]} ${date.day}';
  }

  void _openEntryDetail(JournalEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalDetailScreen(entry: entry),
      ),
    );
  }

  void _showNewEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewJournalEntrySheet(),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search journals...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Search suggestions
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _buildTagChip('gratitude'),
                _buildTagChip('work'),
                _buildTagChip('family'),
                _buildTagChip('self-care'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return ActionChip(
      label: Text(tag),
      onPressed: () {},
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.divider),
    );
  }
}

/// Journal Detail Screen
class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and mood
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (entry.mood != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      entry.moodEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Timestamp
            Text(
              _formatTimestamp(entry.timestamp),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Tags
            if (entry.tags.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.sm,
                children: entry.tags
                    .map((tag) => Chip(
                          label: Text(
                            '#$tag',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.1),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                entry.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),

            // Voice note indicator
            if (entry.hasVoiceNote) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: AppColors.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Note',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '1:24',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_circle_filled),
                      color: AppColors.tertiary,
                      iconSize: 40,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // AI Insight
            _buildAIInsightCard(),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'AI Insight',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your entry reflects a positive mindset with themes of gratitude and mindfulness. This awareness of peaceful moments is strongly linked to improved mental wellbeing.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final hour = timestamp.hour > 12
        ? timestamp.hour - 12
        : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute $period';

    if (entryDate == today) return 'Today at $time';
    if (entryDate == today.subtract(const Duration(days: 1)))
      return 'Yesterday at $time';

    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} at $time';
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewJournalEntrySheet(existingEntry: entry),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.textSecondary),
              title: const Text('Share Entry'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border,
                  color: AppColors.textSecondary),
              title: const Text('Bookmark'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Delete Entry',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// New Journal Entry Bottom Sheet
class NewJournalEntrySheet extends StatefulWidget {
  final JournalEntry? existingEntry;

  const NewJournalEntrySheet({
    super.key,
    this.existingEntry,
  });

  @override
  State<NewJournalEntrySheet> createState() => _NewJournalEntrySheetState();
}

class _NewJournalEntrySheetState extends State<NewJournalEntrySheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int? _selectedMood;
  final List<String> _selectedTags = [];
  bool _isRecording = false;

  static const _availableTags = [
    'gratitude',
    'work',
    'family',
    'self-care',
    'stress',
    'health',
    'goals',
    'relationships',
    'creativity',
    'learning'
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingEntry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingEntry?.content ?? '');
    _selectedMood = widget.existingEntry?.mood;
    if (widget.existingEntry != null) {
      _selectedTags.addAll(widget.existingEntry!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Entry' : 'New Entry',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _saveEntry,
                  child: Text(
                    'Save',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Give your entry a title...',
                      hintStyle: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Mood selector
                  Text(
                    'How are you feeling?',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final mood = index + 1;
                      final emojis = ['😢', '😔', '😐', '😊', '😄'];
                      final isSelected = _selectedMood == mood;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(
                              isSelected ? AppSpacing.md : AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondary.withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.secondary, width: 2)
                                : null,
                          ),
                          child: Text(
                            emojis[index],
                            style: TextStyle(fontSize: isSelected ? 32 : 24),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Content field
                  TextField(
                    controller: _contentController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: null,
                    minLines: 8,
                    decoration: InputDecoration(
                      hintText:
                          'What\'s on your mind? Express your thoughts freely...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Voice recording
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? AppColors.error.withValues(alpha: 0.2)
                                : AppColors.tertiary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: _isRecording
                                ? AppColors.error
                                : AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _isRecording
                                ? 'Recording... Tap to stop'
                                : 'Add voice note',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isRecording
                                ? Icons.stop_circle
                                : Icons.play_circle,
                            color: _isRecording
                                ? AppColors.error
                                : AppColors.tertiary,
                          ),
                          onPressed: () =>
                              setState(() => _isRecording = !_isRecording),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Tags
                  Text(
                    'Tags',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(
                          '#$tag',
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: AppColors.card,
                        selectedColor: AppColors.secondary,
                        checkmarkColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.divider,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    // Save logic here
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            widget.existingEntry != null ? 'Entry updated!' : 'Entry saved!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
