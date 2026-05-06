import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post.dart';
import '../widgets/post_list_tile.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplePost = Post(
      id: 1,
      userId: 101,
      title: 'Sample Post Title',
      body: 'Sample Post Body',
    );

    return Scaffold(
      body: Center(
        child: PostListTile(
          post: samplePost,
          onTap: () {},
        ),
      ),
    );
  }
}
