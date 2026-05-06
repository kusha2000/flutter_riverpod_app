import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostsRepository {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const _limit = 15;

  final http.Client _client;
  PostsRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$_baseUrl/posts?_limit=$_limit');

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw PostsFetchException(
        'Network error — could not reach the server.',
      );
    }

    if (response.statusCode != 200) {
      throw PostsFetchException(
        'Server returned status \${response.statusCode}.',
      );
    }

    try {
      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw PostsFetchException('Failed to parse posts.');
    }
  }
}

class PostsFetchException implements Exception {
  final String message;
  const PostsFetchException(this.message);
  @override
  String toString() => message;
}
