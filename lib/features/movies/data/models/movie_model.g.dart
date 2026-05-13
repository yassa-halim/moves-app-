

part of 'movie_model.dart';





class MovieModelAdapter extends TypeAdapter<MovieModel> {
  @override
  final int typeId = 0;

  @override
  MovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieModel(
      movieId: fields[0] as int,
      movieUrl: fields[1] as String,
      movieTitle: fields[2] as String,
      movieTitleEnglish: fields[3] as String,
      movieTitleLong: fields[4] as String,
      movieYear: fields[5] as int,
      movieRating: fields[6] as double,
      movieRuntime: fields[7] as int,
      movieGenres: (fields[8] as List).cast<String>(),
      movieSummary: fields[9] as String,
      movieDescriptionFull: fields[10] as String,
      movieSynopsis: fields[11] as String,
      movieYtTrailerCode: fields[12] as String,
      movieLanguage: fields[13] as String,
      movieMpaRating: fields[14] as String,
      movieBackgroundImage: fields[15] as String,
      movieBackgroundImageOriginal: fields[16] as String,
      movieSmallCoverImage: fields[17] as String,
      movieMediumCoverImage: fields[18] as String,
      movieLargeCoverImage: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovieModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.movieUrl)
      ..writeByte(2)
      ..write(obj.movieTitle)
      ..writeByte(3)
      ..write(obj.movieTitleEnglish)
      ..writeByte(4)
      ..write(obj.movieTitleLong)
      ..writeByte(5)
      ..write(obj.movieYear)
      ..writeByte(6)
      ..write(obj.movieRating)
      ..writeByte(7)
      ..write(obj.movieRuntime)
      ..writeByte(8)
      ..write(obj.movieGenres)
      ..writeByte(9)
      ..write(obj.movieSummary)
      ..writeByte(10)
      ..write(obj.movieDescriptionFull)
      ..writeByte(11)
      ..write(obj.movieSynopsis)
      ..writeByte(12)
      ..write(obj.movieYtTrailerCode)
      ..writeByte(13)
      ..write(obj.movieLanguage)
      ..writeByte(14)
      ..write(obj.movieMpaRating)
      ..writeByte(15)
      ..write(obj.movieBackgroundImage)
      ..writeByte(16)
      ..write(obj.movieBackgroundImageOriginal)
      ..writeByte(17)
      ..write(obj.movieSmallCoverImage)
      ..writeByte(18)
      ..write(obj.movieMediumCoverImage)
      ..writeByte(19)
      ..write(obj.movieLargeCoverImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
