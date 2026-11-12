import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/author_provider.dart';
import '../../providers/novel_provider.dart';
import '../../widgets/loading_state.dart';

/// Form screen for creating or editing a serialized novel.
class NovelFormScreen extends StatefulWidget {
  final String? novelId;

  const NovelFormScreen({super.key, this.novelId});

  bool get isEdit => novelId != null && novelId!.isNotEmpty;

  @override
  State<NovelFormScreen> createState() => _NovelFormScreenState();
}

class _NovelFormScreenState extends State<NovelFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverUrlController;

  final Set<String> _selectedGenres = {};
  NovelStatus _status = NovelStatus.ongoing;
  Novel? _existingNovel;
  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _coverUrlController = TextEditingController();

    if (widget.isEdit) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);

    final authorProvider = context.read<AuthorProvider>();
    // Try to find in loaded list first
    Novel? found = authorProvider.myNovels
        .where((n) => n.id == widget.novelId)
        .firstOrNull;

    // If not found, fetch from NovelProvider
    if (found == null) {
      try {
        found = await context.read<NovelProvider>().getNovelById(
          widget.novelId!,
        );
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _existingNovel = found;
        _loadingExisting = false;
        if (found != null) {
          _titleController.text = found.title;
          _descriptionController.text = found.description;
          _coverUrlController.text = found.coverUrl;
          _status = found.status;
          _selectedGenres.addAll(found.genres);
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authorProvider = context.watch<AuthorProvider>();
    final auth = context.watch<AuthProvider>();

    final titleText = widget.isEdit ? 'Edit Novel' : 'Create Novel';

    if (_loadingExisting) {
      return Scaffold(
        appBar: AppBar(title: Text(titleText)),
        body: const LoadingState(message: 'Loading novel details...'),
      );
    }

    if (widget.isEdit && _existingNovel == null) {
      return Scaffold(
        appBar: AppBar(title: Text(titleText)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Novel not found.'),
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
      appBar: AppBar(title: Text(titleText)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  Text(
                    'Novel Title *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter an engaging title...',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  Text(
                    'Synopsis / Description *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe the plot, protagonists, and setting...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Genre Selection
                  Text(
                    'Genres (Select at least one) *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.defaultGenres.map((genre) {
                      final selected = _selectedGenres.contains(genre);
                      return FilterChip(
                        label: Text(genre),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedGenres.add(genre);
                            } else {
                              _selectedGenres.remove(genre);
                            }
                          });
                        },
                        selectedColor: AppTheme.accentTeal.withValues(
                          alpha: 0.25,
                        ),
                        checkmarkColor: AppTheme.accentTeal,
                        side: BorderSide(
                          color: selected
                              ? AppTheme.accentTeal
                              : AppTheme.borderDark,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? AppTheme.accentTeal
                              : AppTheme.textMuted,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedGenres.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Please select at least one genre.',
                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Status Dropdown
                  Text(
                    'Release Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<NovelStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.speed_outlined),
                    ),
                    items: NovelStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Cover URL Field (Optional)
                  Text(
                    'Cover Image URL (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _coverUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://images.unsplash.com/...',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

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
                          : Icon(widget.isEdit ? Icons.save : Icons.add_circle),
                      label: Text(
                        authorProvider.submitting
                            ? 'Saving...'
                            : (widget.isEdit ? 'Save Changes' : 'Create Novel'),
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

  Future<void> _handleSubmit(
    AuthProvider auth,
    AuthorProvider authorProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text('Please select at least one genre.'),
        ),
      );
      return;
    }

    final uid = auth.currentUid;
    final userName = auth.currentUser?.fullName ?? 'Author';

    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    try {
      if (widget.isEdit && _existingNovel != null) {
        // Update existing novel while preserving metadata
        final updated = _existingNovel!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          genres: _selectedGenres.toList(),
          status: _status,
          coverUrl: _coverUrlController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await authorProvider.updateNovel(updated);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text('Novel updated successfully!'),
          ),
        );
        context.pop();
      } else {
        // Create new novel
        final novelId = await authorProvider.createNovel(
          authorId: uid,
          authorName: userName,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          genres: _selectedGenres.toList(),
          status: _status,
          coverUrl: _coverUrlController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text(
              'Novel created successfully! Now add your first chapter.',
            ),
          ),
        );
        // Navigate to chapter management for this new novel
        context.pushReplacement(AppRoutes.authorChaptersPath(novelId));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to save novel: $e'),
        ),
      );
    }
  }
}
