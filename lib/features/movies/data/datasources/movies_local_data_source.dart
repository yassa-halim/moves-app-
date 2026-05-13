import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/movie_model.dart';

abstract class MoviesLocalDataSource {
  Future<List<MovieModel>> getCachedMovies();
  Future<void> cacheMovies(List<MovieModel> moviesToCache);
}

const String cachedMoviesBox = 'CACHED_MOVIES';

class MoviesLocalDataSourceImpl implements MoviesLocalDataSource {
  final HiveInterface hive;

  MoviesLocalDataSourceImpl({required this.hive});

  @override
  Future<List<MovieModel>> getCachedMovies() async {
    try {
      final box = await hive.openBox<MovieModel>(cachedMoviesBox);
      final movies = box.values.toList();
      return movies;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMovies(List<MovieModel> moviesToCache) async {
    try {
      final box = await hive.openBox<MovieModel>(cachedMoviesBox);
      await box.clear(); 
      
      
      final topMovies = moviesToCache.take(20).toList();
      await box.addAll(topMovies);
    } catch (e) {
      throw CacheException();
    }
  }
}
