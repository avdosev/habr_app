import 'package:flutter/foundation.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/utils/filters/filter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FiltersStorage {
  static const _boxName = 'filters';

  void addFilter(Filter<PostPreview> filter) {
    Hive.box<Filter<PostPreview>>(_boxName).add(filter);
  }

  void removeFilterAt(int index) {
    Hive.box<Filter<PostPreview>>(_boxName).deleteAt(index);
  }

  Iterable<Filter<PostPreview>> getAll() {
    return Hive.box<Filter<PostPreview>>(_boxName).values.cast<Filter<PostPreview>>();
  }

  ValueListenable<Box<Filter<PostPreview>>> listenable() {
    return Hive.box<Filter<PostPreview>>(_boxName).listenable();
  }
}
