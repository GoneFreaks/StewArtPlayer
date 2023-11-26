import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistDTO {

    final String title;
    final String id;
    final int videoCount;
    final List<String> knownIds = [];
    final String thumbnail;

    PlaylistDTO({required this.title, required this.videoCount, required this.id, required this.thumbnail});

    static PlaylistDTO fromPlaylist(SearchPlaylist playlist) {
        return PlaylistDTO(title: playlist.title, videoCount: playlist.videoCount, id: playlist.id.toString(), thumbnail: playlist.thumbnails.first.url.toString());
    }

}