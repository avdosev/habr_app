import 'package:hive/hive.dart';

import 'package:habr_app/models/cached_post.dart';

class CachedPostAdapter extends TypeAdapter<CachedPost> {
  @override
  final int typeId = 7;

  @override
  CachedPost read(BinaryReader reader) {
    final id = reader.read();
    final title = reader.read();
    final body = reader.read();
    final publishDate = reader.read();
    final insertDate = reader.read();
    final authorId = reader.read();
    return CachedPost(
      id: id,
      title: title,
      body: body,
      publishDate: publishDate,
      insertDate: insertDate,
      authorId: authorId,
    );
  }

  @override
  void write(BinaryWriter writer, CachedPost obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.body);
    writer.write(obj.publishDate);
    writer.write(obj.insertDate);
    writer.write(obj.authorId);
  }
}
