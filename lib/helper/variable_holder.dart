import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/download_dto.dart';
import 'package:stew_art_player/dto/playlist_dto.dart';
import 'package:stew_art_player/helper/stewart_audio_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Holder {

//Main
  static late StewArtAudioHandler handler;
  static final ValueNotifier<bool> useInternet = ValueNotifier(true);
  static final ValueNotifier<bool> animateText = ValueNotifier(true);
  static final ValueNotifier<bool> shortenText = ValueNotifier(true);
  static final ValueNotifier<bool> showVolume = ValueNotifier(false);
  static final ValueNotifier<int> theme = ValueNotifier(0);
  static final ValueNotifier<double> volume = ValueNotifier(0.0);

//Internet
  static List<Video> searchResultsVideo = [];
  static List<PlaylistDTO> searchResultsPlaylist = [];
  static String? searchQuery;

//Lokal
  static final ValueNotifier<int> filter = ValueNotifier(0);
  static final ValueNotifier<String> localSearch = ValueNotifier('');
  static final ValueNotifier<int> trueCounter = ValueNotifier(0);
  static final ValueNotifier<bool> isEditingMode = ValueNotifier(false);
  static Map<String, bool> checkedBoxes = {};

//Playlist
  static bool showPlaylist = false;
  static int isInterpret = 0;
  static String? playlistName;
  static String? bigTrackViewPlaylistName;

//ColorCustomizer
  static final ValueNotifier<int> currentPosition = ValueNotifier(0);

//Handler
  static final ValueNotifier<bool> newThumbnail = ValueNotifier(false);
  static final ValueNotifier<bool> repeatCurrent = ValueNotifier(false);

//Download-Center
  static final ValueNotifier<bool> newDownload = ValueNotifier(false);
  static final List<DownloadDTO> downloads = [];
}