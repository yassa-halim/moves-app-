import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_local_data_source.dart';
import '../datasources/movies_remote_data_source.dart';
import '../models/movie_model.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource remoteDataSource;
  final MoviesLocalDataSource localDataSource;

  MoviesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Movie>>> getMovies({int page = 1, String? genre, String? query}) async {
    try {
      final remoteMovies = await remoteDataSource.getMovies(page: page, genre: genre, query: query);
      
      
      if (page == 1 && (genre == null || genre.isEmpty) && (query == null || query.isEmpty)) {
        await localDataSource.cacheMovies(remoteMovies);
      }
      
      return Right(remoteMovies);
    } on ServerException catch (e) {
      
      try {
        final localMovies = await localDataSource.getCachedMovies();
        if (localMovies.isNotEmpty) {
          return Right(localMovies);
        }
        return Left(ServerFailure(e.message));
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int movieId) async {
    try {
      final remoteMovie = await remoteDataSource.getMovieDetails(movieId);
      return Right(remoteMovie);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getMovieSuggestions(int movieId) async {
    try {
      final remoteMovies = await remoteDataSource.getMovieSuggestions(movieId);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getCachedMovies() async {
    try {
      final localMovies = await localDataSource.getCachedMovies();
      return Right(localMovies);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<void> cacheMovies(List<Movie> movies) async {
    final movieModels = movies.whereType<MovieModel>().toList();
    await localDataSource.cacheMovies(movieModels);
  }
}
