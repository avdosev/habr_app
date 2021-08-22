import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:habr_app/models/post_preview.dart';
import 'package:habr_app/utils/filters/filter.dart';

class FiltersStorage {
  static const _boxName = 'filters';

  void addFilter(Filter<PostPreview> filter) {
    Hive.box<Filter<PostPreview>>(_boxName).add(filter);
  }

  void removeFilterAt(int index) {
    Hive.box<Filter<PostPreview>>(_boxName).deleteAt(index);
  }

  Iterable<Filter<PostPreview>> getAll() {
    return Hive.box<Filter<PostPreview>>(_boxName)
        .values
        .cast<Filter<PostPreview>>();
  }

  ValueListenable<Box<Filter<PostPreview>>> listenable() {
    return Hive.box<Filter<PostPreview>>(_boxName).listenable();
  }
}
