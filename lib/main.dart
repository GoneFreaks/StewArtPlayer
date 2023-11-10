import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:stew_art_player/big_track_view.dart';
import 'package:stew_art_player/color_customizer.dart';
import 'package:stew_art_player/download_center.dart';
import 'package:stew_art_player/dto/theme_dto.dart';
import 'package:stew_art_player/local_searcher.dart';
import 'package:stew_art_player/player_controls.dart';
import 'package:stew_art_player/playlist_view.dart';
import 'package:stew_art_player/searcher.dart';
import 'package:stew_art_player/minor_widgets/settings.dart';
import 'package:stew_art_player/helper/stewart_audio_handler.dart';
import 'package:stew_art_player/minor_widgets/volume_displayer.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dto/video_dto.dart';
import 'helper/db_loader.dart' as db;
import 'helper/utils.dart' as utils;
import 'helper/variable_holder.dart';

void main() async {

  Holder.handler = await AudioService.init(
    builder: () => StewArtAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  await db.initPreferences();
  await db.initDataBase();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StewArt',
      home: const HomePage(),
      routes: {
        '/color': (context) => const ColorCustomizer(),
        '/big': (context) => const BigTrackView(),
        '/download': (context) => const DownloadCenter(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  @override
  void initState() {
    super.initState();
    initConfig();
    Holder.theme.addListener(() {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeDTO.themes[Holder.theme.value].asTheme(),
      initialRoute: '/',
      routes: {
        '/color': (context) => const ColorCustomizer(),
        '/big': (context) => const BigTrackView(),
        '/download': (context) => const DownloadCenter(),
      },
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.download, size: 30, color: ThemeDTO.themes[Holder.theme.value].textColor),
                  onPressed: () {
                    Navigator.pushNamed(context, '/download');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.color_lens_outlined, size: 30, color: ThemeDTO.themes[Holder.theme.value].textColor),
                  onPressed: () async {
                    await precacheImage(const AssetImage('assets/phone-black.png'), context);
                    if(context.mounted) await precacheImage(const AssetImage('assets/tn/02big.jpg'), context);
                    if(context.mounted) Navigator.pushNamed(context, '/color');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 30, color: ThemeDTO.themes[Holder.theme.value].textColor),
                  onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        shape: utils.getDialogBorder(),
                        backgroundColor: Colors.black38,
                        content: const Settings(),
                      );
                    });
                  },
                ),
              ],
              backgroundColor: ThemeDTO.themes[Holder.theme.value].primaryColor,
              title: Text("StewArt", style: ThemeDTO.getTitleLarge(),),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: ThemeDTO.themes[Holder.theme.value].textColor,
                labelColor: ThemeDTO.themes[Holder.theme.value].textColor,
                unselectedLabelColor: const Color.fromARGB(255, 100, 100, 100),
                tabs: const [
                  Tab(icon: Icon(Icons.wifi), text: "Internet",),
                  Tab(icon: Icon(Icons.folder,), text: "Lokal"),
                  Tab(icon: Icon(Icons.playlist_play,), text: "Ansehen"),
                ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ThemeDTO.themes[Holder.theme.value].secondaryColor, ThemeDTO.themes[Holder.theme.value].primaryColor]
                )
              ),
            child: Column(
              children: [
                Container(
                  height: 3,
                  color: Colors.white30,
                ),
                const Expanded(
                  child: Stack(
                    children: [
                      TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Searcher(),
                          LocalSearcher(),
                          Playlist(),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: VolumeDisplayer(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const PlayerControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initConfig() async {
    await db.readUseInternet().then((value) => Holder.useInternet.value = value);
    await db.readAnimateText().then((value) => Holder.animateText.value = value);
    await db.readShortenText().then((value) => Holder.shortenText.value = value);
    await db.readShowVolume().then((value) => Holder.showVolume.value = value);
    await db.readTheme().then((value) {
      Holder.theme.value = value;
      Holder.currentPosition.value = value;
    });
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
    VolumeController().listener((p0) {
      if(p0 != Holder.volume.value) Holder.volume.value = p0;
    });
    setState(() {});
  }
}
