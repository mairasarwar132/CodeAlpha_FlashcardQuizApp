import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _HomeFilter { all, favorites, category }

enum _HomeSort { newest, oldest, alphabetical }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  _HomeFilter _filter = _HomeFilter.all;
  _HomeSort _sort = _HomeSort.newest;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(flashcardNotifierProvider.notifier).refresh(),
        child: flashcardsState.when(
          data: _buildContent,
          error: (error, stackTrace) => _ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(flashcardNotifierProvider.notifier).loadFlashcards(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Create a new flashcard',
        child: FloatingActionButton.extended(
          heroTag: 'add-flashcard',
          onPressed: () => context.push(AppRoutes.addFlashcard),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New card'),
        ),
      ),
    );
  }

  Widget _buildContent(List<FlashcardEntity> flashcards) {
    final categories = _categoriesFrom(flashcards);
    final filtered = _filteredFlashcards(flashcards);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
      children: [
        _SearchAndControls(
          controller: _searchController,
          sort: _sort,
          onSortChanged: (sort) => setState(() => _sort = sort),
        ),
        const SizedBox(height: 12),
        _FilterRow(
          filter: _filter,
          categories: categories,
          selectedCategory: _selectedCategory,
          onFilterChanged: (filter) => setState(() => _filter = filter),
          onCategoryChanged: (category) {
            setState(() {
              _filter = _HomeFilter.category;
              _selectedCategory = category;
            });
          },
        ),
        const SizedBox(height: 18),
        if (flashcards.isEmpty)
          const _EmptyState()
        else if (filtered.isEmpty)
          const _NoResultsState()
        else
          ...List.generate(filtered.length, (index) {
            final flashcard = filtered[index];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 220 + index * 35),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: FlashcardCard(
                  flashcard: flashcard,
                  onStudy: () => context.go(AppRoutes.study),
                  onEdit: () =>
                      context.push('/flashcards/edit/${flashcard.id}'),
                  onDelete: () => _confirmDelete(context, ref, flashcard),
                  onFavorite: () => ref
                      .read(flashcardNotifierProvider.notifier)
                      .toggleFavorite(flashcard),
                ),
              ),
            );
          }),
      ],
    );
  }

  List<FlashcardEntity> _filteredFlashcards(List<FlashcardEntity> flashcards) {
    final query = _searchController.text.trim().toLowerCase();
    var result = flashcards.where((flashcard) {
      final matchesQuery =
          query.isEmpty ||
          flashcard.question.toLowerCase().contains(query) ||
          flashcard.answer.toLowerCase().contains(query) ||
          flashcard.category.toLowerCase().contains(query) ||
          (flashcard.isFavorite && 'favorite'.contains(query));
      final matchesFilter = switch (_filter) {
        _HomeFilter.all => true,
        _HomeFilter.favorites => flashcard.isFavorite,
        _HomeFilter.category =>
          _selectedCategory == null || flashcard.category == _selectedCategory,
      };

      return matchesQuery && matchesFilter;
    }).toList();

    result.sort((a, b) {
      return switch (_sort) {
        _HomeSort.newest => b.createdAt.compareTo(a.createdAt),
        _HomeSort.oldest => a.createdAt.compareTo(b.createdAt),
        _HomeSort.alphabetical => a.question.toLowerCase().compareTo(
          b.question.toLowerCase(),
        ),
      };
    });

    return result;
  }

  List<String> _categoriesFrom(List<FlashcardEntity> flashcards) {
    final categories = flashcards.map((card) => card.category).toSet().toList()
      ..sort();

    return categories;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FlashcardEntity flashcard,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shouldDelete = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete flashcard',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.delete_outline,
              color: colorScheme.onErrorContainer,
            ),
          ),
          title: const Text('Delete flashcard?'),
          content: Text(
            'This will permanently remove this question and answer from your deck.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );

    if (shouldDelete != true || !context.mounted || flashcard.id == null) {
      return;
    }

    await ref
        .read(flashcardNotifierProvider.notifier)
        .deleteFlashcard(flashcard.id!);

    if (!context.mounted) {
      return;
    }

    final state = ref.read(flashcardNotifierProvider);
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      _buildSnackBar(
        context,
        message: state.hasError ? state.error.toString() : 'Flashcard deleted.',
        icon: state.hasError ? Icons.error_outline : Icons.check_circle_outline,
      ),
    );
  }
}

class _SearchAndControls extends StatelessWidget {
  const _SearchAndControls({
    required this.controller,
    required this.sort,
    required this.onSortChanged,
  });

  final TextEditingController controller;
  final _HomeSort sort;
  final ValueChanged<_HomeSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            controller: controller,
            hintText: 'Search question, answer, category, favorite',
            leading: const Icon(Icons.search),
            trailing: [
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<_HomeSort>(
          initialValue: sort,
          tooltip: 'Sort',
          icon: const Icon(Icons.sort_rounded),
          onSelected: onSortChanged,
          itemBuilder: (context) => const [
            PopupMenuItem(value: _HomeSort.newest, child: Text('Newest')),
            PopupMenuItem(value: _HomeSort.oldest, child: Text('Oldest')),
            PopupMenuItem(
              value: _HomeSort.alphabetical,
              child: Text('Alphabetical'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.categories,
    required this.selectedCategory,
    required this.onFilterChanged,
    required this.onCategoryChanged,
  });

  final _HomeFilter filter;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<_HomeFilter> onFilterChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: filter == _HomeFilter.all,
            onSelected: (_) => onFilterChanged(_HomeFilter.all),
            avatar: const Icon(Icons.all_inclusive, size: 18),
            label: const Text('All'),
            showCheckmark: false,
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: filter == _HomeFilter.favorites,
            onSelected: (_) => onFilterChanged(_HomeFilter.favorites),
            avatar: const Icon(Icons.star_border_rounded, size: 18),
            label: const Text('Favorites'),
            showCheckmark: false,
          ),
          const SizedBox(width: 8),
          for (final category in categories) ...[
            FilterChip(
              selected:
                  filter == _HomeFilter.category &&
                  selectedCategory == category,
              onSelected: (_) => onCategoryChanged(category),
              avatar: const Icon(Icons.sell_outlined, size: 18),
              label: Text(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text('No flashcards yet', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Create your first card and start a focused review session.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching flashcards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}

SnackBar _buildSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: colorScheme.onInverseSurface),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
