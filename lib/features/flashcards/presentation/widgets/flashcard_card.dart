import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:flutter/material.dart';

class FlashcardCard extends StatelessWidget {
  const FlashcardCard({
    required this.flashcard,
    required this.onStudy,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
    super.key,
  });

  final FlashcardEntity flashcard;
  final VoidCallback onStudy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Hero(
      tag: 'flashcard-${flashcard.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onStudy,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.style_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _CategoryChip(category: flashcard.category),
                              if (flashcard.isFavorite)
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: colorScheme.tertiary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            flashcard.question,
                            style: textTheme.titleMedium?.copyWith(
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            flashcard.answer,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: flashcard.isFavorite
                          ? 'Remove favorite'
                          : 'Add favorite',
                      child: IconButton(
                        onPressed: onFavorite,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            flashcard.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            key: ValueKey(flashcard.isFavorite),
                          ),
                        ),
                        color: flashcard.isFavorite
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onStudy,
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Study'),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: const Icon(Icons.sell_outlined, size: 16),
      label: Text(category),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.55),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
