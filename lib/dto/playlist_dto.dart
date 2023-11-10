import 'package:stew_art_player/dto/location_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistDTO {

    final String title;
    final String id;
    final int videoCount;
    final List<VideoDTO> videos;
    final List<String> knownIds = [];

    PlaylistDTO({required this.title, required this.videoCount, required this.videos, required this.id});

    static PlaylistDTO fromPlaylist(SearchPlaylist playlist, List<Video> rawVideos) {
        List<VideoDTO> videoDTOs = [];
        for(Video video in rawVideos) {
            videoDTOs.add(VideoDTO.fromVideoWithLocation(video, LocationDTO(location: 1, isInterpret: 1, playlistName: '')));
        }
        return PlaylistDTO(title: playlist.title, videoCount: playlist.videoCount, videos: videoDTOs, id: playlist.id.toString());
    }

}