import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:stew_art_player/helper/variable_holder.dart';

class StewArtAudioHandler extends BaseAudioHandler {

  List<VideoDTO> videoDTOQueue = [];
  AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<bool> currentTrackNotifier = ValueNotifier(true);
  VideoDTO? currentTrack;
  bool hasIncremented = false;

  List<int> playedTracks = [];

  @override
  Future<void> play() async {
    audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    audioPlayer.stop;
  }

  @override
  Future<void> skipToNext() async {

    if(Holder.isRandomQueue.value) {
      while(true) {
        int nextIndex = Random().nextInt(videoDTOQueue.length);
        if(!playedTracks.contains(nextIndex)) {
          loadTrack(videoDTOQueue[nextIndex]);
          playedTracks.add(nextIndex);
          break;
        }
      }
      if(playedTracks.length == videoDTOQueue.length) playedTracks = [];
      return;
    }

    if(videoDTOQueue.length > 1) {
      VideoDTO toPlay = videoDTOQueue.removeAt(0);
      if(!toPlay.isQueuedTrack) videoDTOQueue.add(toPlay);
      loadTrack(toPlay);
      return;
    }
    if(videoDTOQueue.length == 1) loadTrack(videoDTOQueue.last);
  }

  Future<void> playNext() async {
    if(Holder.repeatCurrent.value && currentTrack != null) {
      loadTrack(currentTrack!);
      return;
    }
    skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if(videoDTOQueue.length > 1) {
      videoDTOQueue.insert(0, videoDTOQueue.removeLast());
      loadTrack(videoDTOQueue.last);
    }
    if(videoDTOQueue.length == 1) loadTrack(videoDTOQueue.last);
  }

  Future<void> changeShuffleMode() async {
    Holder.isRandomQueue.value = !Holder.isRandomQueue.value;
    if(Holder.isRandomQueue.value) {
      playedTracks = [];
      if(currentTrack != null) playedTracks.add(videoDTOQueue.indexOf(currentTrack!));
    }
    else {
      if(videoDTOQueue.isEmpty || videoDTOQueue.length == 1) return;
      if(currentTrack != null) {
        int currentIndex = videoDTOQueue.indexOf(currentTrack!);
        if(currentIndex == 0) {
          videoDTOQueue.add(videoDTOQueue.removeAt(0));
        }
        else {
          List<VideoDTO> newVideoDTOQueue = [];
          newVideoDTOQueue.addAll(videoDTOQueue.sublist(currentIndex, videoDTOQueue.length));
          newVideoDTOQueue.addAll(videoDTOQueue.sublist(0, currentIndex));
          newVideoDTOQueue.add(newVideoDTOQueue.removeAt(0));
          videoDTOQueue = newVideoDTOQueue;
        }
      }
    }
  }

  Future<void> loadTrack(VideoDTO video) async {
    hasIncremented = false;
    currentTrack = video;
    currentTrackNotifier.value = !currentTrackNotifier.value;
    Holder.newThumbnail.value = !Holder.newThumbnail.value;
    await stop();
    mediaItem.add(video.asMediaItem());
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/${video.id}.m4a");
    await audioPlayer.setUrl(file.path);
    play();
  }

  Future<void> loadTracks(VideoDTO toPlay, List<VideoDTO> videos) async {
    if (videos.length > 1) {
      int index = videos.indexOf(toPlay);
      List<VideoDTO> queue = [];
      if (index + 1 < videos.length) {
        queue.addAll(videos.sublist(index + 1));
      }
      queue.addAll(videos.sublist(0, index));
      queue.add(toPlay);
      videoDTOQueue = queue;
    }
    else {
      videoDTOQueue = [toPlay];
    }
    List<MediaItem> mediaItems = [];
    for (VideoDTO video in videoDTOQueue) {
      mediaItems.add(video.asMediaItem());
    }
    queue.add(mediaItems);
  }

  Future<void> loadTemp(VideoDTO video) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/temp.m4a");
    currentTrack = video;
    currentTrackNotifier.value = !currentTrackNotifier.value;
    await stop();
    audioPlayer.setUrl(file.path);
    mediaItem.add(video.asMediaItem());
    play();
  }

  StewArtAudioHandler() {
    audioPlayer.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[audioPlayer.processingState]!,
      playing: audioPlayer.playing,
      updatePosition: audioPlayer.position,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      queueIndex: event.currentIndex,
    );
  }

}