import 'package:equatable/equatable.dart';

typedef String Id();

class Post extends Equatable {
  final Id id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id];
}

class PostPreview extends Equatable {
  final Id id;
  final String title;

  const PostPreview({this.id, this.title});

  @override
  List<Object> get props => [id];
}