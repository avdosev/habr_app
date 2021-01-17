import 'package:hive/hive.dart';
import 'adaptors.dart';

void registerAdapters() {
  Hive.registerAdapter(ThemeAdapter());
  Hive.registerAdapter(TextAlignAdapter());
  Hive.registerAdapter(PostPreviewFilterAdapter());
  Hive.registerAdapter(PostPreviewAdapter());
  Hive.registerAdapter(AuthorAdapter());
  Hive.registerAdapter(AuthorAvatarInfoAdapter());
}