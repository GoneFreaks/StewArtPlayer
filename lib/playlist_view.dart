import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/location_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:stew_art_player/minor_widgets/track_container.dart';
import 'package:stew_art_player/minor_widgets/video_widget.dart';
import 'helper/db_loader.dart' as db;
import 'helper/utils.dart' as utils;
import 'helper/variable_holder.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => PlaylistState();
}

class PlaylistState extends State<Playlist> {

  @override
  void initState() {
    super.initState();
    getAndBuildPlaylists();
    Holder.theme.addListener(getAndBuildPlaylists);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.theme.removeListener(getAndBuildPlaylists);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (Holder.showPlaylist && Holder.playlistName != null)
          WillPopScope(
            onWillPop: () async {
              Holder.showPlaylist = false;
              Holder.playlistName = null;
              setState(() {});
              return false;
            },
            child: const SizedBox(),
          ),
        Expanded(child: AnimatedCrossFade(
              firstChild: FutureBuilder(builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return SizedBox(height: 200000, child: TrackContainer(widgets: snapshot.data!,),);
                }
                return Container(color: Colors.transparent,);
              },
                future: getTracksOfPlaylist(),
              ),
              firstCurve: Curves.easeIn,
              secondChild: FutureBuilder(builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return SizedBox(height: 200000, child: TrackContainer(widgets: snapshot.data!,),);
                }
                return Container(color: Colors.transparent);
              },
                future: getAndBuildPlaylists(),
              ),
              secondCurve: Curves.easeIn,
              duration: const Duration(milliseconds: 250),
              crossFadeState: Holder.showPlaylist? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
        ),
      ],
    );
  }

  Future<List<Widget>> getTracksOfPlaylist() async {
    List<VideoDTO> videos = [];

    switch (Holder.isInterpret){
      case 0:
        videos = await db.getVideoDTOsByAuthor(Holder.playlistName!, LocationDTO(location: 2, isInterpret: 0, playlistName: ''));
        break;
      case 1:
        videos = await db.getVideoDTOs(Holder.playlistName!, LocationDTO(location: 2, isInterpret: 1, playlistName: Holder.playlistName!));
        break;
      case 2:
        videos = await db.getYTVideoDTOs(Holder.playlistName!, LocationDTO(location: 2, isInterpret: 2, playlistName: Holder.playlistName!));
        break;
    }

    List<Widget> result = [];

    utils.sortTracks(videos, 0);

    for (VideoDTO video in videos) {
      result.add(InkWell(
          onTap: () async {
            if(Holder.handler.currentTrack == null || Holder.handler.currentTrack!.compareTo(video) != 0) {
              Holder.handler.loadTracks(video, videos);
              Holder.handler.loadTrack(video);
              Holder.bigTrackViewPlaylistName = Holder.playlistName;
            }
            else {
              Navigator.pushNamed(context, '/big');
            }
          },
          onLongPress: () {
            if(!(Holder.isInterpret == 0)) {
              db.deletePlaylistEntry(Holder.playlistName!, video.id);
              setState(() {});
            }
          },
          child: VideoWidget(
                  video: video,
                )));
      result.add(const SizedBox(
        height: 10,
      ));
    }

    return result;
  }

  Future<List<Widget>> getAndBuildPlaylists() async {
    List<Widget> widgets = [];
    List<String> names = await db.getPlaylistNames();
    List<String> ytNames = await db.getYoutubePlaylistNames();
    List<String> interprets = await db.getInterprets();

    if(names.isNotEmpty && context.mounted) {
      widgets.add(
        Text('Playlisten',
            style: Theme.of(context).textTheme.titleMedium,)
      );
    }

    for (String s in names) {
      int trackCount = await db.getPlaylistTrackCount(s);
      widgets.add(InkWell(
          onTap: () {
            Holder.isInterpret = 1;
            Holder.playlistName = s;
            Holder.showPlaylist = true;
            setState(() {});
          },
          onLongPress: () {
            db.deletePlaylist(s);
            getAndBuildPlaylists();
            CoolAlert.show(
                context: context,
                type: CoolAlertType.warning,
                title: "Playlist $s wurde gelöscht");
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            color: widgets.length % 2 == 0 ? Colors.black12 : Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\t\t\t\t($trackCount) $s',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          )));
    }

    if(interprets.isNotEmpty && context.mounted) {
      widgets.add(const SizedBox(
        height: 20,
      ));
      widgets.add(
          Text("Interpreten",
            style: Theme.of(context).textTheme.titleMedium,)
      );
    }

    for (String s in interprets) {
      int trackCount = await db.getInterpretTrackCount(s);
      widgets.add(InkWell(
          onTap: () {
            Holder.isInterpret = 0;
            Holder.playlistName = s;
            Holder.showPlaylist = true;
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            color: widgets.length % 2 == 0 ? Colors.black12 : Colors.white12,
            child: Text('\t\t\t\t($trackCount) $s',
                style: Theme.of(context).textTheme.bodyMedium),
          )));
    }

    if(ytNames.isNotEmpty && context.mounted) {
      widgets.add(const SizedBox(
        height: 20,
      ));
      widgets.add(
          Text("Youtube-Playlists",
            style: Theme.of(context).textTheme.titleMedium,)
      );
    }

    for (String s in ytNames) {
      int trackCount = await db.getYTPlaylistTrackCount(s);
      widgets.add(InkWell(
          onTap: () {
            Holder.isInterpret = 2;
            Holder.playlistName = s;
            Holder.showPlaylist = true;
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            color: widgets.length % 2 == 0 ? Colors.black12 : Colors.white12,
            child: Text('\t\t\t\t($trackCount) $s',
                style: Theme.of(context).textTheme.bodyMedium),
          )));
    }

    return widgets;
  }
}
