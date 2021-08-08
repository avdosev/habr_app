import 'package:habr_app/models/cached_image_info.dart';
import 'package:hive/hive.dart';

class CachedImageInfoAdapter extends TypeAdapter<CachedImageInfo> {
  @override
  final int typeId = 8;

  @override
  CachedImageInfo read(BinaryReader reader) {
    final url = reader.read();
    final path = reader.read();
    return CachedImageInfo(
      url: url,
      path: path,
    );
  }

  @override
  void write(BinaryWriter writer, CachedImageInfo obj) {
    writer.write(obj.url);
    writer.write(obj.path);
  }
}
