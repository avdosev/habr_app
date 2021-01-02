class Statistics {
  final int commentsCount;
  final int favoritesCount;
  final int readingCount;
  final int score;
  final int votesCount;

  const Statistics({
    this.commentsCount,
    this.favoritesCount,
    this.readingCount,
    this.score,
    this.votesCount});

  Statistics.fromJson(Map<String, dynamic> json) :
        commentsCount = json['commentsCount'],
        favoritesCount = json['favoritesCount'],
        readingCount = json['readingCount'],
        score = json['score'],
        votesCount = json['votesCount'];

  Statistics.zero() :
        commentsCount = 0,
        favoritesCount = 0,
        readingCount = 0,
        score = 0,
        votesCount = 0
  ;
}