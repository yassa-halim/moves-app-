import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie.dart';

abstract class MoviesRepository {
  Future<Either<Failure, List<Movie>>> getMovies({int page = 1, String? genre, String? query});
  Future<Either<Failure, Movie>> getMovieDetails(int movieId);
  Future<Either<Failure, List<Movie>>> getMovieSuggestions(int movieId);
  
  
  Future<Either<Failure, List<Movie>>> getCachedMovies();
  Future<void> cacheMovies(List<Movie> movies);
}
