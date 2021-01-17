import 'package:flutter/foundation.dart';
import 'package:habr_app/models/models.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookmarksStore {
  final bookmarksBox = Hive.box<double>('bookmarks');
  final bookmarkedBox = Hive.box<PostPreview>('bookmarked');

  void addBookmark(String postId, double position, PostPreview preview) {
    bookmarksBox.put(postId, position);
    bookmarkedBox.put(postId, preview);
  }

  void removeBookmark(String postId) {
    print(postId);
    bookmarksBox.delete(postId);
    bookmarkedBox.delete(postId);
  }

  double getPosition(String postId) {
    return bookmarksBox.get(postId);
  }

  ValueListenable<Box<PostPreview>> bookmarks() {
    return bookmarkedBox.listenable();
  }
}