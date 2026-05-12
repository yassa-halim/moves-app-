import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();
  
  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const MoviesLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class MovieDetailsLoaded extends MoviesState {
  final Movie movie;
  final List<Movie> suggestions;

  const MovieDetailsLoaded(this.movie, this.suggestions);

  @override
  List<Object> get props => [movie, suggestions];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object> get props => [message];
}
