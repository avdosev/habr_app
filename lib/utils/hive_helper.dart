import 'package:habr_app/hive/register_in_hive.dart';
import 'package:habr_app/models/author.dart';
import 'package:habr_app/models/cached_image_info.dart';
import 'package:habr_app/models/cached_post.dart';
import 'package:habr_app/models/post_preview.dart';
import 'package:habr_app/utils/filters/filter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  registerAdapters();
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox<Filter<PostPreview>>('filters'),
    Hive.openBox<PostPreview>('bookmarked'),
    Hive.openBox<PostPreview>('read_late'),
    Hive.openBox<double>('bookmarks'),
    Hive.openLazyBox<CachedImageInfo>('cached_images'),
    Hive.openLazyBox<CachedPost>('cached_articles'),
    Hive.openLazyBox<Author>('cached_authors'),
  ]);
}
