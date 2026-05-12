import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/movie_model.dart';

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getMovies({int page = 1, String? genre, String? query});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getMovieSuggestions(int movieId);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final http.Client client;

  MoviesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getMovies({int page = 1, String? genre, String? query}) async {
    String url = '${ApiConstants.listMovies}?page=$page';
    if (genre != null && genre.isNotEmpty) {
      url += '&genre=$genre';
    }
    if (query != null && query.isNotEmpty) {
      url += '&query_term=$query';
    }

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['status'] == 'ok') {
        final List<dynamic> moviesList = decoded['data']['movies'] ?? [];
        return moviesList.map((movie) => MovieModel.fromJson(movie)).toList();
      } else {
        throw ServerException(decoded['status_message']);
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await client.get(Uri.parse('${ApiConstants.movieDetails}?movie_id=$movieId&with_images=true&with_cast=true'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['status'] == 'ok') {
        return MovieModel.fromJson(decoded['data']['movie']);
      } else {
        throw ServerException(decoded['status_message']);
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    final response = await client.get(Uri.parse('${ApiConstants.movieSuggestions}?movie_id=$movieId'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['status'] == 'ok') {
        final List<dynamic> moviesList = decoded['data']['movies'] ?? [];
        return moviesList.map((movie) => MovieModel.fromJson(movie)).toList();
      } else {
        throw ServerException(decoded['status_message']);
      }
    } else {
      throw ServerException();
    }
  }
}
