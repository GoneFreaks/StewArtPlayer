import 'package:flutter/material.dart';
import 'package:stew_art_player/editing_controls.dart';
import 'package:stew_art_player/minor_widgets/local_track_widget.dart';
import 'package:stew_art_player/minor_widgets/track_container.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'helper/db_loader.dart' as db;
import 'helper/utils.dart' as utils;
import 'helper/variable_holder.dart';

class LocalSearcher extends StatefulWidget {
  const LocalSearcher({super.key});

  @override
  State<LocalSearcher> createState() => LocalSearcherState();
}

class LocalSearcherState extends State<LocalSearcher> {
  List<String> playlistNames = [];
  List<String> interpretNames = [];
  String? playlistName;

  @override
  void initState() {
    super.initState();
    db.getPlaylistNames().then((value) => playlistNames = value);
    db.getInterprets().then((value) => interpretNames = value);
    Holder.filter.addListener(saveSetState);
    Holder.localSearch.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.filter.removeListener(saveSetState);
    Holder.localSearch.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          height: 45,
          child: const EditingControls(),
        ),
        Expanded(
          child: FutureBuilder(
              future: getAndBuildWidgets(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Widget>> widgets) {
                if (widgets.hasData && widgets.data!.isNotEmpty) {
                  return WillPopScope(
                    onWillPop: () async {
                      setState(() {
                        Holder.isEditingMode.value = false;
                        Holder.checkedBoxes = {};
                        Holder.trueCounter.value = 0;
                      });
                      return false;
                    },
                    child: TrackContainer(widgets: widgets.data!,),
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ),
      ],
    );
  }

  Future<List<Widget>> getAndBuildWidgets() async {

    List<Widget> searchResults = [];
    List<VideoDTO> videos = await db.getAllLocalTracks(context);

    utils.sortTracks(videos, Holder.filter.value);

    for (VideoDTO video in videos) {
      Holder.checkedBoxes[video.id] ??= false;

      searchResults.add(LocalTrackWidget(video: video, videos: videos));
      searchResults.add(const SizedBox(
        height: 10,
      ));
    }
    return searchResults;
  }

  void saveSetState() {
    try {
      setState(() {});
    } catch (_){}
  }
}
