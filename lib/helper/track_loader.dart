import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/playlist_stream_dto.dart';
import 'package:stew_art_player/dto/stream_dto.dart';
import 'package:stew_art_player/helper/variable_holder.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../dto/playlist_dto.dart';
import '../dto/video_dto.dart';
import 'db_loader.dart' as db_loader;

Stream<double> saveAudioAsTemporary(Video video, BuildContext dialogContext) async* {
  try {
    if(await db_loader.trackExists(video.id.toString())) {
      Holder.handler.loadTrack(VideoDTO.fromVideo(video));
      if(dialogContext.mounted) Navigator.pop(dialogContext);
      return;
    }
    else {
      List<int> data = [];
      StreamDTO stream = await _saveAudio(video.id.toString());

      await for (final temp in stream.data) {
        data.addAll(temp);
        yield (data.length.toDouble()) / (stream.fileSize * 1024 * 1024);
      }
      if(data.isNotEmpty) {
        Directory directory = await getApplicationDocumentsDirectory();
        File file = File("${directory.path}/temp.m4a");
        IOSink fileStream = file.openWrite();
        fileStream.add(data);
        await fileStream.flush();
        await fileStream.close();
        Holder.handler.loadTemp(VideoDTO.fromVideo(video));
      }
    }
  } catch (e) {
    Navigator.pop(dialogContext);
    CoolAlert.show(context: dialogContext, type: CoolAlertType.error, title: 'Track konnte nicht heruntergeladen werden, bitte probiere es erneut');
    return;
  }
}

Stream<double> saveAudioAsPermanent(Video video, BuildContext dialogContext, BuildContext context) async* {

  Directory directory = await getApplicationDocumentsDirectory();
  File file = File("${directory.path}/${video.id}.m4a");

  try {
    if(await db_loader.trackExists(video.id.toString())) {
      if(dialogContext.mounted) Navigator.pop(dialogContext);
      return;
    }

    bool trackOnDisk = await trackExists(video.id.toString());

    if(trackOnDisk) {
      db_loader.saveVideoDTO(VideoDTO.fromVideo(video));
      yield 1.0;
    }
    else {
      List<int> data = [];
      StreamDTO stream = await _saveAudio(video.id.toString());

      await for (final temp in stream.data) {
        data.addAll(temp);
        yield (data.length.toDouble()) / (stream.fileSize * 1024 * 1024);
      }

      if(data.isNotEmpty) {
        db_loader.saveVideoDTO(VideoDTO.fromVideo(video));
        IOSink fileStream = file.openWrite();
        fileStream.add(data);
        await fileStream.flush();
        await fileStream.close();
      }
    }

  } catch (e) {
    db_loader.deleteIDEntry(video.id.toString());
    if(file.existsSync()) file.delete();
    if(dialogContext.mounted) Navigator.pop(dialogContext);
    if(dialogContext.mounted) CoolAlert.show(context: dialogContext, type: CoolAlertType.error, title: 'Track konnte nicht heruntergeladen werden, bitte probiere es erneut');
  }
}

Stream<double> savePlaylist(PlaylistDTO playlist, BuildContext dialogContext, BuildContext context) async* {

  if(await db_loader.ytPlaylistExists(playlist.id)) return;
  List<PlaylistStreamDTO> streams = [];
  YoutubeExplode youtube = YoutubeExplode();
  Directory directory = await getApplicationDocumentsDirectory();

  double playlistSize = 0.0;

  yield 0.0;

  List<VideoDTO> videos = VideoDTO.fromVideos(await youtube.playlists.getVideos(playlist.id).toList());

  for(VideoDTO video in videos) {

    bool trackOnDisk = await trackExists(video.id);
    if(trackOnDisk) {
      playlist.knownIds.add(video.id);
      continue;
    }
    StreamManifest temp = await youtube.videos.streamsClient.getManifest(video.id);
    AudioOnlyStreamInfo info = temp.audioOnly.withHighestBitrate();
    Stream<List<int>> stream = youtube.videos.streamsClient.get(info);
    StreamDTO streamDTO = StreamDTO(data: stream, fileSize: info.size.totalMegaBytes);
    streams.add(PlaylistStreamDTO(stream: streamDTO, video: video));
    playlistSize += streamDTO.fileSize;
  }

  double downloadSize = 0.0;
  for(PlaylistStreamDTO pStream in streams) {
    StreamDTO stream = pStream.stream;
    List<int> data = [];
    await for (final temp in stream.data) {
      data.addAll(temp);
      double percentage = (downloadSize + data.length.toDouble()) / (playlistSize * 1024 * 1024);
      yield percentage;
    }
    downloadSize += data.length.toDouble();

    if(data.isNotEmpty) {
      File file = File("${directory.path}/${pStream.video.id}.m4a");
      IOSink fileStream = file.openWrite();
      fileStream.add(data);
      await fileStream.flush();
      await fileStream.close();
    }
  }
  await db_loader.saveYoutubePlaylist(playlist, videos);
  youtube.close();
}

Future<StreamDTO> _saveAudio(String id) async {
  YoutubeExplode youtube = YoutubeExplode();
  StreamManifest temp = await youtube.videos.streamsClient.getManifest(id);
  AudioOnlyStreamInfo info = temp.audioOnly.withHighestBitrate();
  Stream<List<int>> stream = youtube.videos.streamsClient.get(info);
  return StreamDTO(data: stream, fileSize: info.size.totalMegaBytes);
}

Directory? appDirectory;
Future<bool> trackExists(String id) async {
  appDirectory ??= await getApplicationDocumentsDirectory();
  File potFile = File("${appDirectory!.path}/$id.m4a");
  return potFile.exists();
}

Future<void> deleteTrack(String path, String id) async {
  File file = File(path);
  if(file.existsSync()) file.deleteSync();
  db_loader.deleteIDEntry(id);
}