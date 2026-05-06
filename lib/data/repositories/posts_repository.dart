class PostsRepository {}

class PostsFetchException implements Exception {
  final String message;
  const PostsFetchException(this.message);
}
