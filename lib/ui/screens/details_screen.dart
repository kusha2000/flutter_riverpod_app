import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_app/providers/posts_providers.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final int postId;

  const DetailsScreen({super.key, required this.postId});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  bool _isEditing = false;

  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _enterEditMode(String currentTitle, String currentBody) {
    _titleController.text = currentTitle;
    _bodyController.text = currentBody;
    setState(() => _isEditing = true);
  }

  void _save() {
    final post = ref.read(postByIdProvider(widget.postId));
    if (post == null) return;

    final edited = post.copyWith(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    ref.read(localEditsProvider.notifier).save(edited);

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved locally.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(postByIdProvider(widget.postId));

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${post.id}'),
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ]
            : [
                IconButton(
                  tooltip: 'Edit post',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _enterEditMode(post.title, post.body),
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isEditing
            ? _EditView(
                titleController: _titleController,
                bodyController: _bodyController,
              )
            : _ReadView(title: post.title, body: post.body),
      ),
    );
  }
}

class _ReadView extends StatelessWidget {
  final String title;
  final String body;

  const _ReadView({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text(body, style: textTheme.bodyLarge),
      ],
    );
  }
}

// Edit sub-widget

class _EditView extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;

  const _EditView({
    required this.titleController,
    required this.bodyController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Post title',
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        Text(
          'Body',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: bodyController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Post body',
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 10,
          minLines: 6,
        ),
      ],
    );
  }
}
