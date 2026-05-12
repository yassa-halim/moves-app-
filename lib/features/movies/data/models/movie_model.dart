import 'package:hive/hive.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends Movie {
  @HiveField(0)
  final int movieId;
  
  @HiveField(1)
  final String movieUrl;
  
  @HiveField(2)
  final String movieTitle;
  
  @HiveField(3)
  final String movieTitleEnglish;
  
  @HiveField(4)
  final String movieTitleLong;
  
  @HiveField(5)
  final int movieYear;
  
  @HiveField(6)
  final double movieRating;
  
  @HiveField(7)
  final int movieRuntime;
  
  @HiveField(8)
  final List<String> movieGenres;
  
  @HiveField(9)
  final String movieSummary;
  
  @HiveField(10)
  final String movieDescriptionFull;
  
  @HiveField(11)
  final String movieSynopsis;
  
  @HiveField(12)
  final String movieYtTrailerCode;
  
  @HiveField(13)
  final String movieLanguage;
  
  @HiveField(14)
  final String movieMpaRating;
  
  @HiveField(15)
  final String movieBackgroundImage;
  
  @HiveField(16)
  final String movieBackgroundImageOriginal;
  
  @HiveField(17)
  final String movieSmallCoverImage;
  
  @HiveField(18)
  final String movieMediumCoverImage;
  
  @HiveField(19)
  final String movieLargeCoverImage;

  // Cast isn't stored in Hive right now to avoid type adapter complexity
  final List<Cast> movieCast;
  final List<String> movieScreenshots;
  final int movieLikeCount;

  const MovieModel({
    required this.movieId,
    required this.movieUrl,
    required this.movieTitle,
    required this.movieTitleEnglish,
    required this.movieTitleLong,
    required this.movieYear,
    required this.movieRating,
    required this.movieRuntime,
    required this.movieGenres,
    required this.movieSummary,
    required this.movieDescriptionFull,
    required this.movieSynopsis,
    required this.movieYtTrailerCode,
    required this.movieLanguage,
    required this.movieMpaRating,
    required this.movieBackgroundImage,
    required this.movieBackgroundImageOriginal,
    required this.movieSmallCoverImage,
    required this.movieMediumCoverImage,
    required this.movieLargeCoverImage,
    this.movieCast = const [],
    this.movieScreenshots = const [],
    this.movieLikeCount = 0,
  }) : super(
          id: movieId,
          url: movieUrl,
          title: movieTitle,
          titleEnglish: movieTitleEnglish,
          titleLong: movieTitleLong,
          year: movieYear,
          rating: movieRating,
          runtime: movieRuntime,
          genres: movieGenres,
          summary: movieSummary,
          descriptionFull: movieDescriptionFull,
          synopsis: movieSynopsis,
          ytTrailerCode: movieYtTrailerCode,
          language: movieLanguage,
          mpaRating: movieMpaRating,
          backgroundImage: movieBackgroundImage,
          backgroundImageOriginal: movieBackgroundImageOriginal,
          smallCoverImage: movieSmallCoverImage,
          mediumCoverImage: movieMediumCoverImage,
          largeCoverImage: movieLargeCoverImage,
          cast: movieCast,
          screenshots: movieScreenshots,
          likeCount: movieLikeCount,
        );

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    List<Cast> parsedCast = [];
    if (json['cast'] != null) {
      json['cast'].forEach((c) {
        parsedCast.add(Cast(
          name: c['name'] ?? '',
          characterName: c['character_name'] ?? '',
          urlSmallImage: c['url_small_image'] ?? '',
          imdbCode: c['imdb_code'] ?? '',
        ));
      });
    }

    List<String> parsedScreenshots = [];
    if (json['large_screenshot_image1'] != null) parsedScreenshots.add(json['large_screenshot_image1']);
    if (json['large_screenshot_image2'] != null) parsedScreenshots.add(json['large_screenshot_image2']);
    if (json['large_screenshot_image3'] != null) parsedScreenshots.add(json['large_screenshot_image3']);

    return MovieModel(
      movieId: json['id'] ?? 0,
      movieUrl: json['url'] ?? '',
      movieTitle: json['title'] ?? '',
      movieTitleEnglish: json['title_english'] ?? '',
      movieTitleLong: json['title_long'] ?? '',
      movieYear: json['year'] ?? 0,
      movieRating: (json['rating'] ?? 0).toDouble(),
      movieRuntime: json['runtime'] ?? 0,
      movieGenres: List<String>.from(json['genres'] ?? []),
      movieSummary: json['summary'] ?? '',
      movieDescriptionFull: json['description_full'] ?? '',
      movieSynopsis: json['synopsis'] ?? '',
      movieYtTrailerCode: json['yt_trailer_code'] ?? '',
      movieLanguage: json['language'] ?? '',
      movieMpaRating: json['mpa_rating'] ?? '',
      movieBackgroundImage: json['background_image'] ?? '',
      movieBackgroundImageOriginal: json['background_image_original'] ?? '',
      movieSmallCoverImage: json['small_cover_image'] ?? '',
      movieMediumCoverImage: json['medium_cover_image'] ?? '',
      movieLargeCoverImage: json['large_cover_image'] ?? '',
      movieCast: parsedCast,
      movieScreenshots: parsedScreenshots,
      movieLikeCount: json['like_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': movieId,
      'url': movieUrl,
      'title': movieTitle,
      'title_english': movieTitleEnglish,
      'title_long': movieTitleLong,
      'year': movieYear,
      'rating': movieRating,
      'runtime': movieRuntime,
      'genres': movieGenres,
      'summary': movieSummary,
      'description_full': movieDescriptionFull,
      'synopsis': movieSynopsis,
      'yt_trailer_code': movieYtTrailerCode,
      'language': movieLanguage,
      'mpa_rating': movieMpaRating,
      'background_image': movieBackgroundImage,
      'background_image_original': movieBackgroundImageOriginal,
      'small_cover_image': movieSmallCoverImage,
      'medium_cover_image': movieMediumCoverImage,
      'large_cover_image': movieLargeCoverImage,
      'cast': movieCast.map((c) => {
        'name': c.name,
        'character_name': c.characterName,
        'url_small_image': c.urlSmallImage,
        'imdb_code': c.imdbCode,
      }).toList(),
    };
  }
}
