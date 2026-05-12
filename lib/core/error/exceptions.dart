class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error occurred']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication Error occurred']);
}
