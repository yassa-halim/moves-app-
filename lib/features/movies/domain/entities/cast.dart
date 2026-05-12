import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final String name;
  final String characterName;
  final String urlSmallImage;
  final String imdbCode;

  const Cast({
    required this.name,
    required this.characterName,
    required this.urlSmallImage,
    required this.imdbCode,
  });

  @override
  List<Object?> get props => [name, characterName, urlSmallImage, imdbCode];
}
