class Statistics {
  final int commentsCount;
  final int favoritesCount;
  final int readingCount;
  final int score;
  final int votesCount;

  const Statistics({
    required this.commentsCount,
    required this.favoritesCount,
    required this.readingCount,
    required this.score,
    required this.votesCount,
  });

  Statistics.fromJson(Map<String, dynamic> json)
      : commentsCount = json['commentsCount'],
        favoritesCount = json['favoritesCount'],
        readingCount = json['readingCount'],
        score = json['score'],
        votesCount = json['votesCount'];

  const Statistics.zero()
      : commentsCount = 0,
        favoritesCount = 0,
        readingCount = 0,
        score = 0,
        votesCount = 0;
}
