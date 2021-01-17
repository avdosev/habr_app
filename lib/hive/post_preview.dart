import 'package:hive/hive.dart';

import 'package:habr_app/models/post_preview.dart';
import 'package:habr_app/models/statistics.dart';

class PostPreviewAdapter extends TypeAdapter<PostPreview> {
  @override
  final int typeId = 5;

  @override
  PostPreview read(BinaryReader reader) {
    final id = reader.read();
    final title = reader.read();
    final tags = reader.read();
    final corporative = reader.read();
    final publishDate = reader.read();
    final author = reader.read();
    return PostPreview(
      id: id,
      title: title,
      tags: tags,
      corporative: corporative,
      publishDate: publishDate,
      author: author,
      statistics: const Statistics.zero(),
    );
  }

  @override
  void write(BinaryWriter writer, PostPreview obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.writeList(obj.tags);
    writer.write(obj.corporative);
    writer.write(obj.publishDate);
    writer.write(obj.author);
  }
}
