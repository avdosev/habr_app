import 'package:moor_flutter/moor_flutter.dart';

part 'cache_tables.g.dart';

class CachedPosts extends Table {
  // autoIncrement automatically sets this to be the primary key
  TextColumn get id =>
      text().customConstraint('UNIQUE')();
  TextColumn get authorId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get publishTime => dateTime()();
  DateTimeColumn get insertTime => dateTime()();
}

class CachedPostWithAuthor {
  final CachedPost post;
  final CachedAuthor author;

  CachedPostWithAuthor({
    @required this.post,
    @required this.author,
  });
}

class CachedAuthors extends Table {
  TextColumn get id => text().customConstraint('UNIQUE')();
  TextColumn get nickname => text()(); // alias used in moor_flutter
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get speciality => text()();
}

class CachedImages extends Table {
  TextColumn get url => text().customConstraint('UNIQUE')();
  TextColumn get path => text()();
}

// Dao

@UseDao(tables: [CachedAuthors])
class CachedAuthorDao extends DatabaseAccessor<Cache> with _$CachedAuthorDaoMixin {
  final Cache db;

  CachedAuthorDao(this.db) : super(db);

  Future<List<CachedAuthor>> getAuthors(Iterable<String> ids) => (select(cachedAuthors)..where((authors) => authors.id.isIn(ids))).get();
  Future<CachedAuthor> getAuthor(String id) => (select(cachedAuthors)..where((authors) => authors.id.equals(id))).getSingle();
  Future insertAuthor(Insertable<CachedAuthor> author) => into(cachedAuthors).insert(author);
}

@UseDao(
  tables: [CachedPosts, CachedAuthors],
)
class CachedPostDao extends DatabaseAccessor<Cache> with _$CachedPostDaoMixin {
  final Cache db;

  // Called by the AppDatabase class
  CachedPostDao(this.db) : super(db);

  Future<List<CachedPostWithAuthor>> getAllPosts({int page = 1, int count = 10}) {
    // Wrap the whole select statement in parenthesis
    return
      (select(cachedPosts)
      ..limit(count, offset: (page-1)*count))
      .join([
        leftOuterJoin(cachedAuthors, cachedAuthors.id.equalsExp(cachedPosts.authorId)),
      ],)
      .map(
        (row) {
          return CachedPostWithAuthor(
            post: row.readTable(cachedPosts),
            author: row.readTable(cachedAuthors),
          );
        }
    ).get();
  }

  Future<int> count() async {
    final countExp = cachedPosts.id.count(distinct: true);
    final query = selectOnly(cachedPosts)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result;
  }

  Future<CachedPost> getPost(String id) => (select(cachedPosts)..where((posts) => posts.id.equals(id))).getSingle();
  Future insertPost(Insertable<CachedPost> post) => into(cachedPosts).insert(post);
  Future updatePost(Insertable<CachedPost> post) => update(cachedPosts).replace(post);
  Future deletePost(String id) => (delete(cachedPosts)..where((posts) => posts.id.equals(id))).go();
}

@UseDao(tables: [CachedImages])
class CachedImagesDao extends DatabaseAccessor<Cache> with _$CachedImagesDaoMixin  {
  final Cache db;

  // Called by the AppDatabase class
  CachedImagesDao(this.db) : super(db);

  Future<CachedImage> getImage(String url) => (select(cachedImages)..where((image) => image.url.equals(url))).getSingle();
  Future insertImage(Insertable<CachedImage> image) => into(cachedImages).insert(image);
  Future deleteImage(String url) => (delete(cachedImages)..where((image) => image.url.equals(url))).go();
}

// DB

@UseMoor(tables: [CachedPosts, CachedAuthors, CachedImages], daos: [CachedPostDao, CachedAuthorDao, CachedImagesDao])
class Cache extends _$Cache {
  Cache()
      : super(FlutterQueryExecutor.inDatabaseFolder(
      path: 'cache.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;
}

final globalCache = Cache();