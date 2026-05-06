import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/repositories/posts_repository.dart';

// Repository provider
final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository();
});

// Raw fetch — AsyncNotifier
final _rawPostsFetchProvider =
    AsyncNotifierProvider<_RawPostsNotifier, List<Post>>(
  _RawPostsNotifier.new,
);

class _RawPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    return ref.read(postsRepositoryProvider).fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(postsRepositoryProvider).fetchPosts(),
    );
  }
}

// Local edits — Map<int, Post>
final localEditsProvider = NotifierProvider<LocalEditsNotifier, Map<int, Post>>(
  LocalEditsNotifier.new,
);

class LocalEditsNotifier extends Notifier<Map<int, Post>> {
  @override
  Map<int, Post> build() => {};

  void save(Post edited) {
    state = {...state, edited.id: edited};
  }
}

// Merged view — what UI reads
final postsNotifierProvider = Provider<AsyncValue<List<Post>>>((ref) {
  final rawAsync = ref.watch(_rawPostsFetchProvider);
  final edits = ref.watch(localEditsProvider);
  return rawAsync.whenData((posts) {
    if (edits.isEmpty) return posts;
    return posts
        .map((p) => edits.containsKey(p.id) ? edits[p.id]! : p)
        .toList();
  });
});

// Single post by ID
final postByIdProvider = Provider.family<Post?, int>((ref, id) {
  final edits = ref.watch(localEditsProvider);
  if (edits.containsKey(id)) return edits[id];
  return ref
      .watch(_rawPostsFetchProvider)
      .valueOrNull
      ?.firstWhere((p) => p.id == id, orElse: () => throw StateError(''));
});

// Expose refresh to UI
final refreshPostsProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(_rawPostsFetchProvider.notifier).refresh();
});
