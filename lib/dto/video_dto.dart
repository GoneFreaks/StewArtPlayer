import 'package:audio_service/audio_service.dart';
import 'package:stew_art_player/dto/location_dto.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:stew_art_player/helper/utils.dart' as utils;

class VideoDTO implements Comparable<VideoDTO>{

  final String title;
  final String id;
  final int views;
  final Duration? duration;
  final String thumbnailURL;
  final String thumbnailURLHR;
  final String author;
  final DateTime uploadDate;
  final LocationDTO location;
  bool isQueuedTrack = false;

  VideoDTO({required this.title, required this.id, required this.views, required this.duration, required this.thumbnailURL, required this.thumbnailURLHR,required this.author, required this.uploadDate, required this.location});

  @override
  String toString(){
    return title;
  }

  MediaItem asMediaItem() {
    return MediaItem(
      id: id,
      title: utils.shortMusicTitle(this),
      artist: author,
      duration: duration,
      artUri: Uri.parse(thumbnailURL),
      album: 'StewArt',
    );
  }

  @override
  int compareTo(VideoDTO other) {
    int result;
    result = title.compareTo(other.title);
    if(result == 0) return location.compareTo(other.location);
    return result;
  }

  static VideoDTO fromVideoWithLocation(Video video, LocationDTO location) {
    DateTime? videoUpload = video.uploadDate;
    videoUpload ??= DateTime.now();

    return VideoDTO(title: video.title, id: video.id.toString(), views: video.engagement.viewCount, duration: video.duration, thumbnailURL: video.thumbnails.lowResUrl, author: video.author, thumbnailURLHR: video.thumbnails.highResUrl, uploadDate: videoUpload, location: location);
  }

  static VideoDTO fromVideo(Video video) {
    DateTime? videoUpload = video.uploadDate;
    videoUpload ??= DateTime.now();

    return VideoDTO(title: video.title, id: video.id.toString(), views: video.engagement.viewCount, duration: video.duration, thumbnailURL: video.thumbnails.lowResUrl, author: video.author, thumbnailURLHR: video.thumbnails.highResUrl, uploadDate: videoUpload, location: LocationDTO(location: 0, isInterpret: 1, playlistName: ''));
  }

}