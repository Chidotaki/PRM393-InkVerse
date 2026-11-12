import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/chapter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/author_provider.dart';
import '../../widgets/loading_state.dart';

/// Form screen for creating or editing a serialized chapter with live word count.
class ChapterFormScreen extends StatefulWidget {
  final String novelId;
  final String? chapterId;

  const ChapterFormScreen({super.key, required this.novelId, this.chapterId});

  bool get isEdit => chapterId != null && chapterId!.isNotEmpty;

  @override
  State<ChapterFormScreen> createState() => _ChapterFormScreenState();
}

class _ChapterFormScreenState extends State<ChapterFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  Chapter? _existingChapter;
  bool _loadingExisting = false;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _contentController.addListener(_updateWordCount);

    if (widget.isEdit) {
      _loadExisting();
    } else {
      // Suggest next chapter number based on existing chapters
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chapters = context.read<AuthorProvider>().getChaptersForNovel(
          widget.novelId,
        );
        final nextNum = chapters.isEmpty
            ? 1
            : chapters
                      .map((c) => c.chapterNumber)
                      .fold<int>(0, (max, n) => n > max ? n : max) +
                  1;
        _numberController.text = nextNum.toString();
      });
    }
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      if (_wordCount != 0) setState(() => _wordCount = 0);
      return;
    }
    final words = text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    if (words != _wordCount) {
      setState(() => _wordCount = words);
    }
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);

    final authorProvider = context.read<AuthorProvider>();
    List<Chapter> chapters = authorProvider.getChaptersForNovel(widget.novelId);

    if (chapters.isEmpty) {
      await authorProvider.loadChapters(widget.novelId);
      chapters = authorProvider.getChaptersForNovel(widget.novelId);
    }

    final found = chapters.where((c) => c.id == widget.chapterId).firstOrNull;

    if (mounted) {
      setState(() {
        _existingChapter = found;
        _loadingExisting = false;
        if (found != null) {
          _numberController.text = found.chapterNumber.toString();
          _titleController.text = found.title;
          _contentController.text = found.content;
          _wordCount = found.wordCount;
        }
      });
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateWordCount);
    _numberController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorProvider = context.watch<AuthorProvider>();
    final auth = context.watch<AuthProvider>();

    final titleText = widget.isEdit ? 'Edit Chapter' : 'New Chapter';

    if (_loadingExisting) {
      return Scaffold(
        appBar: AppBar(title: Text(titleText)),
        body: const LoadingState(message: 'Loading chapter content...'),
      );
    }

    if (widget.isEdit && _existingChapter == null) {
      return Scaffold(
        appBar: AppBar(title: Text(titleText)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Chapter not found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Text(
                  'Words: $_wordCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentTeal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter Number & Title in Responsive Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 140, child: _buildNumberField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTitleField()),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNumberField(),
                            const SizedBox(height: 16),
                            _buildTitleField(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Chapter Content Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chapter Content *',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textHighContrast,
                        ),
                      ),
                      Text(
                        'Markdown / plain text supported',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content Editor Text Area
                  TextFormField(
                    controller: _contentController,
                    minLines: 16,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppTheme.textHighContrast,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Once upon a time in a world far away...',
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted.withValues(alpha: 0.6),
                      ),
                      alignLabelWithHint: true,
                      fillColor: AppTheme.surfaceDark,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.borderDark,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Chapter content cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentTeal,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: authorProvider.submitting
                          ? null
                          : () => _handleSubmit(auth, authorProvider),
                      icon: authorProvider.submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : Icon(widget.isEdit ? Icons.save : Icons.check),
                      label: Text(
                        authorProvider.submitting
                            ? 'Saving Chapter...'
                            : (widget.isEdit
                                  ? 'Save Changes'
                                  : 'Save Chapter (Draft)'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chapter # *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textHighContrast,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '1',
            prefixIcon: Icon(Icons.tag),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Required';
            }
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) {
              return '> 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chapter Title *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textHighContrast,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'e.g. The Awakening',
            prefixIcon: Icon(Icons.bookmark_border),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleSubmit(
    AuthProvider auth,
    AuthorProvider authorProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final uid = auth.currentUid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    final chapterNumber = int.parse(_numberController.text.trim());
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    try {
      if (widget.isEdit && _existingChapter != null) {
        final updated = _existingChapter!.copyWith(
          chapterNumber: chapterNumber,
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );

        await authorProvider.updateChapter(updated);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text('Chapter updated successfully!'),
          ),
        );
        context.pop();
      } else {
        await authorProvider.createChapter(
          novelId: widget.novelId,
          authorId: uid,
          chapterNumber: chapterNumber,
          title: title,
          content: content,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F766E),
            content: Text('Chapter $chapterNumber saved as draft!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      final msg =
          e.toString().contains('duplicate') ||
              e.toString().contains('already exists')
          ? 'A chapter with this number already exists.'
          : 'Failed to save chapter: $e';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(msg),
        ),
      );
    }
  }
}
