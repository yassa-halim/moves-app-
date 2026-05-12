import 'package:equatable/equatable.dart';
import 'cast.dart';

class Movie extends Equatable {
  final int id;
  final String url;
  final String title;
  final String titleEnglish;
  final String titleLong;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String descriptionFull;
  final String synopsis;
  final String ytTrailerCode;
  final String language;
  final String mpaRating;
  final String backgroundImage;
  final String backgroundImageOriginal;
  final String smallCoverImage;
  final String mediumCoverImage;
  final String largeCoverImage;
  final int likeCount;
  final List<Cast> cast;
  final List<String> screenshots;

  const Movie({
    required this.id,
    required this.url,
    required this.title,
    required this.titleEnglish,
    required this.titleLong,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.descriptionFull,
    required this.synopsis,
    required this.ytTrailerCode,
    required this.language,
    required this.mpaRating,
    required this.backgroundImage,
    required this.backgroundImageOriginal,
    required this.smallCoverImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    this.likeCount = 0,
    this.cast = const [],
    this.screenshots = const [],
  });

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        titleEnglish,
        titleLong,
        year,
        rating,
        runtime,
        genres,
        summary,
        descriptionFull,
        synopsis,
        ytTrailerCode,
        language,
        mpaRating,
        backgroundImage,
        backgroundImageOriginal,
        smallCoverImage,
        mediumCoverImage,
        largeCoverImage,
        likeCount,
        cast,
        screenshots,
      ];
}
