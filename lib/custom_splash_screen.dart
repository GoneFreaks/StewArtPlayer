import 'dart:io';

import 'package:animated_icon/animated_icon.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stew_art_player/dto/theme_dto.dart';
import 'dto/video_dto.dart';
import 'helper/db_loader.dart' as db;
import 'helper/stewart_audio_handler.dart';
import 'helper/variable_holder.dart';

class CustomSplashScreen extends StatefulWidget {

  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => CustomSplashScreenState();
}

class CustomSplashScreenState extends State<CustomSplashScreen>{

  static const int colorCode = 50;
  static const waitTimer = 1;
  String loadText = '';

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {


    setState(() {
      loadText = 'Config wird geladen ...';
    });
    await db.initPreferences();
    await db.readUseInternet().then((value) => Holder.useInternet.value = value);
    await db.readAnimateText().then((value) => Holder.animateText.value = value);
    await db.readShortenText().then((value) => Holder.shortenText.value = value);
    await db.readShowVolume().then((value) => Holder.showVolume.value = value);
    await db.readTheme().then((value) {
      Holder.theme.value = value;
      Holder.currentPosition.value = value;
    });
    await Future.delayed(const Duration(seconds: waitTimer));


    setState(() {
      loadText = 'Datenbank wird initialisiert ...';
    });
    await db.initDataBase();
    await Future.delayed(const Duration(seconds: waitTimer));


    setState(() {
      loadText = 'Speicherbereinigung wird durchgeführt ...';
    });
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();
    files.retainWhere((element) => element.path.contains('m4a'));
    Set<String> trackIDs = await db.getAllTrackIDs();

    List<FileSystemEntity> tempFiles = List.from(files);

    for (FileSystemEntity file in tempFiles) {
      for (String id in trackIDs) {
        if(file.path.contains(id)) {
          files.remove(file);
          break;
        }
      }
    }
    for (FileSystemEntity file in files) {
      file.deleteSync();
    }


    setState(() {
      loadText = 'AudioPlayer wird gestartet ...';
    });
    Holder.handler = await AudioService.init(
      builder: () => StewArtAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );

    await db.readMusicState().then((value) async {
      if(value != null) {
        List<VideoDTO> videos = [];
        VideoDTO? toPlay;
        for (String s in value.queueIds) {
          VideoDTO? videoDTO = await db.getVideoDTO(s, value.location);
          if(videoDTO != null) {
            videos.add(videoDTO);
            if(s == value.currentTrackId) toPlay = videoDTO;
          }
        }
        if(toPlay != null) {
          Holder.handler.loadTracks(toPlay, videos);
          await Holder.handler.loadTrack(toPlay);
          await Holder.handler.audioPlayer.seek(Duration(seconds: value.currentTrackPosition), index: 0);
          double preVolume = Holder.handler.audioPlayer.volume;
          Holder.handler.audioPlayer.setVolume(0.0);
          await Future.delayed(const Duration(milliseconds: 100));
          await Holder.handler.pause();
          Holder.handler.audioPlayer.setVolume(preVolume);
        }
      }
    });
    await Future.delayed(const Duration(seconds: waitTimer));


    setState(() {
      loadText = '';
    });
    await Future.delayed(const Duration(seconds: waitTimer));


    if(context.mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/main');
    }

  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeDTO.themes[0].asTheme();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, colorCode, colorCode, colorCode),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimateIcon(
              iconType: IconType.continueAnimation,
              animateIcon: AnimateIcons.loading6,
              onTap: () {},
              color: Colors.white,
              width: 300,
              height: 300,
            ),
            Text(loadText, style: theme.textTheme.titleMedium,),
          ],
        ),
      ),
    );
  }
}