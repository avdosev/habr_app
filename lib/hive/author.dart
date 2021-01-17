import 'package:hive/hive.dart';

import 'package:habr_app/models/author.dart';

class AuthorAdapter extends TypeAdapter<Author> {
  @override
  final int typeId = 4;

  @override
  Author read(BinaryReader reader) {
    final id = reader.read();
    final alias = reader.read();
    final avatar = reader.read();
    return Author(id: id, alias: alias, avatar: avatar);
  }

  @override
  void write(BinaryWriter writer, Author obj) {
    writer.write(obj.id);
    writer.write(obj.alias);
    writer.write(obj.avatar);
  }
}