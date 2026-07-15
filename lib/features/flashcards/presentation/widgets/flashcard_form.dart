import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/utils/flashcard_categories.dart';
import 'package:flutter/material.dart';

class FlashcardForm extends StatefulWidget {
  const FlashcardForm({
    required this.onSubmit,
    required this.submitLabel,
    this.initialQuestion = '',
    this.initialAnswer = '',
    this.initialCategory = 'General',
    this.initialIsFavorite = false,
    super.key,
  });

  final String initialQuestion;
  final String initialAnswer;
  final String initialCategory;
  final bool initialIsFavorite;
  final String submitLabel;
  final Future<void> Function(
    String question,
    String answer,
    String category,
    bool isFavorite,
  )
  onSubmit;

  @override
  State<FlashcardForm> createState() => _FlashcardFormState();
}

class _FlashcardFormState extends State<FlashcardForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionFocusNode = FocusNode();
  final _answerFocusNode = FocusNode();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _customCategoryController;
  late String _selectedCategory;
  late bool _isFavorite;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialQuestion)
      ..addListener(_onTextChanged);
    _answerController = TextEditingController(text: widget.initialAnswer)
      ..addListener(_onTextChanged);
    _selectedCategory =
        defaultFlashcardCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'Custom';
    _customCategoryController = TextEditingController(
      text: _selectedCategory == 'Custom' ? widget.initialCategory : '',
    );
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  void dispose() {
    _questionFocusNode.dispose();
    _answerFocusNode.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categories = [...defaultFlashcardCategories, 'Custom'];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Flashcard details', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Keep prompts focused and answers easy to review at speed.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Question field',
            child: TextFormField(
              controller: _questionController,
              focusNode: _questionFocusNode,
              autofocus: widget.initialQuestion.isEmpty,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'Example: What is the capital of Japan?',
                prefixIcon: const Icon(Icons.help_outline),
                counterText: '${_questionController.text.length}/180',
              ),
              minLines: 2,
              maxLines: 5,
              maxLength: 180,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              onFieldSubmitted: (_) => _answerFocusNode.requestFocus(),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Answer field',
            child: TextFormField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              decoration: InputDecoration(
                labelText: 'Answer',
                hintText: 'Example: Tokyo',
                prefixIcon: const Icon(Icons.lightbulb_outline),
                counterText: '${_answerController.text.length}/500',
              ),
              minLines: 4,
              maxLines: 8,
              maxLength: 500,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              onFieldSubmitted: (_) => _submit(),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Category selector',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() => _selectedCategory = value);
                    },
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _selectedCategory == 'Custom'
                ? Padding(
                    key: const ValueKey('custom-category'),
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: _customCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Custom category',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: _selectedCategory == 'Custom'
                          ? _requiredValidator
                          : null,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('preset-category')),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: _isFavorite,
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _isFavorite = value),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            secondary: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? colorScheme.tertiary : null,
            ),
            title: const Text('Mark as favorite'),
            subtitle: const Text('Keep this card pinned for quick reviews.'),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: FilledButton.icon(
              key: ValueKey(_isSubmitting),
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isSubmitting ? 'Saving...' : widget.submitLabel),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _onTextChanged() {
    setState(() {});
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter this field.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final category = _selectedCategory == 'Custom'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    try {
      await widget.onSubmit(
        _questionController.text.trim(),
        _answerController.text.trim(),
        category,
        _isFavorite,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
