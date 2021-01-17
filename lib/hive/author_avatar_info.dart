import 'package:hive/hive.dart';

import 'package:habr_app/models/author_avatar_info.dart';

class AuthorAvatarInfoAdapter extends TypeAdapter<AuthorAvatarInfo> {
  @override
  final int typeId = 3;

  @override
  AuthorAvatarInfo read(BinaryReader reader) {
    final url = reader.read();
    final cached = reader.read();
    return AuthorAvatarInfo(url: url, cached: cached);
  }

  @override
  void write(BinaryWriter writer, AuthorAvatarInfo obj) {
    writer.write(obj.url);
    writer.write(obj.cached);
  }
}
