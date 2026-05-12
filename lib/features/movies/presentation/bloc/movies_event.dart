import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

class FetchMoviesEvent extends MoviesEvent {
  final int page;
  final String? genre;
  final String? query;

  const FetchMoviesEvent({this.page = 1, this.genre, this.query});

  @override
  List<Object?> get props => [page, genre, query];
}

class FetchMovieDetailsEvent extends MoviesEvent {
  final int movieId;

  const FetchMovieDetailsEvent(this.movieId);

  @override
  List<Object> get props => [movieId];
}
