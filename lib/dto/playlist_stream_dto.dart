import 'package:stew_art_player/dto/stream_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';

class PlaylistStreamDTO {

  final StreamDTO stream;
  final VideoDTO video;

  PlaylistStreamDTO({required this.stream, required this.video});

}