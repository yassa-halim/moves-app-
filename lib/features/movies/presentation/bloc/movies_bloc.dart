import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/movies_repository.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MoviesRepository repository;

  MoviesBloc({required this.repository}) : super(MoviesInitial()) {
    on<FetchMoviesEvent>(_onFetchMovies);
    on<FetchMovieDetailsEvent>(_onFetchMovieDetails);
  }

  Future<void> _onFetchMovies(FetchMoviesEvent event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    final result = await repository.getMovies(
      page: event.page,
      genre: event.genre,
      query: event.query,
    );

    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(movies)),
    );
  }

  Future<void> _onFetchMovieDetails(FetchMovieDetailsEvent event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    
    
    final detailResult = await repository.getMovieDetails(event.movieId);
    
    await detailResult.fold(
      (failure) async => emit(MoviesError(failure.message)),
      (movie) async {
        
        final suggestionResult = await repository.getMovieSuggestions(event.movieId);
        
        suggestionResult.fold(
          (failure) => emit(MoviesError(failure.message)), 
          (suggestions) => emit(MovieDetailsLoaded(movie, suggestions)),
        );
      },
    );
  }
}
