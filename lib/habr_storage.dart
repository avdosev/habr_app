import 'package:habr_app/habr/api.dart';
import 'package:habr_app/habr/dto.dart';

/// Singleton cache_storage for habr api
class HabrStorage {
  HabrStorage._privateConstructor();

  static final HabrStorage _instance = HabrStorage._privateConstructor();

  factory HabrStorage() {
    return _instance;
  }

  
}