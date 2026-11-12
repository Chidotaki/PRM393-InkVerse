import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/genre.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

enum GenreFilter { all, active, inactive }

/// Admin screen for curating the platform genre taxonomy.
class GenreManagementScreen extends StatefulWidget {
  const GenreManagementScreen({super.key});

  @override
  State<GenreManagementScreen> createState() => _GenreManagementScreenState();
}

class _GenreManagementScreenState extends State<GenreManagementScreen> {
  GenreFilter _filter = GenreFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProvider>().loadGenres();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final allGenres = admin.genres;

    final filteredGenres = allGenres.where((g) {
      switch (_filter) {
        case GenreFilter.all:
          return true;
        case GenreFilter.active:
          return g.isActive;
        case GenreFilter.inactive:
          return !g.isActive;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genre Taxonomy'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: admin.loading ? null : _loadData,
          ),
          IconButton(
            tooltip: 'Add Genre',
            icon: const Icon(Icons.add),
            onPressed: _showAddGenreDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentTeal,
        foregroundColor: Colors.black87,
        onPressed: _showAddGenreDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Genre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: admin.loading && allGenres.isEmpty
                ? const LoadingState(message: 'Loading genres...')
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: filteredGenres.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: EmptyState(
                                icon: Icons.category_outlined,
                                title: 'No Genres Found',
                                message: 'No genres match this filter.',
                                actionLabel: _filter == GenreFilter.all
                                    ? 'Add First Genre'
                                    : null,
                                onAction: _filter == GenreFilter.all
                                    ? _showAddGenreDialog
                                    : null,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: filteredGenres.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final genre = filteredGenres[index];
                              return _buildGenreCard(context, genre);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          _filterChip('All Genres', GenreFilter.all),
          const SizedBox(width: 8),
          _filterChip('Active', GenreFilter.active),
          const SizedBox(width: 8),
          _filterChip('Inactive', GenreFilter.inactive),
        ],
      ),
    );
  }

  Widget _filterChip(String label, GenreFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _filter = filter);
      },
      selectedColor: AppTheme.accentTeal.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected ? AppTheme.accentTeal : AppTheme.borderDark,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? AppTheme.accentTeal : AppTheme.textMuted,
      ),
    );
  }

  Widget _buildGenreCard(BuildContext context, Genre genre) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.label_outline,
                size: 20,
                color: AppTheme.accentTeal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        genre.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textHighContrast,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusBadge(genre.isActive),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${genre.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Rename button
            IconButton(
              tooltip: 'Rename Genre',
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showRenameGenreDialog(genre),
            ),
            // Toggle active button
            IconButton(
              tooltip: genre.isActive ? 'Deactivate Genre' : 'Activate Genre',
              icon: Icon(
                genre.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                size: 28,
                color: genre.isActive ? Colors.green : AppTheme.textMuted,
              ),
              onPressed: () => _handleToggleActive(genre),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    final color = isActive ? Colors.green : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _showAddGenreDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final added = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Genre'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Cyberpunk, Isekai...',
              labelText: 'Genre Name',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentTeal,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (added == null || added.isEmpty || !mounted) return;

    try {
      await context.read<AdminProvider>().addGenre(added);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Genre "$added" added successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('already exists')
          ? 'A genre with this name already exists.'
          : 'Failed to add genre: $e';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(msg),
        ),
      );
    }
  }

  Future<void> _showRenameGenreDialog(Genre genre) async {
    final controller = TextEditingController(text: genre.name);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename "${genre.name}"'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New Genre Name'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentTeal,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !mounted) return;

    try {
      await context.read<AdminProvider>().renameGenre(
        id: genre.id,
        newName: newName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Genre renamed to "$newName".'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('already exists')
          ? 'A genre with this name already exists.'
          : 'Failed to rename genre: $e';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(msg),
        ),
      );
    }
  }

  Future<void> _handleToggleActive(Genre genre) async {
    final newActive = !genre.isActive;

    if (!newActive) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Deactivate Genre?'),
          content: Text(
            'Deactivate "${genre.name}"?\nExisting novels with this genre will keep it, but it will no longer be selectable for new releases.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;
    }

    try {
      await context.read<AdminProvider>().setGenreActive(
        id: genre.id,
        isActive: newActive,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text(
            'Genre "${genre.name}" ${newActive ? 'activated' : 'deactivated'}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to update genre status: $e'),
        ),
      );
    }
  }
}
