import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stew_art_player/helper/network_image.dart';
import 'dto/video_dto.dart';
import 'helper/variable_holder.dart';
import 'helper/utils.dart' as utils;
import 'helper/db_loader.dart' as db;

class BigTrackView extends StatefulWidget {
  const BigTrackView({super.key});
  @override
  State<BigTrackView> createState() => BigTrackViewState();
}

class BigTrackViewState extends State<BigTrackView>{

  static const double volumeSize = 90.0;
  int duration = 0;
  int position = 0;
  late StreamSubscription<Duration?> durationSub;
  late StreamSubscription<Duration> positionSub;

  @override
  void initState() {
    super.initState();
    durationSub = Holder.handler.audioPlayer.durationStream.listen(durationListener);
    positionSub = Holder.handler.audioPlayer.positionStream.listen(positionListener);
    Holder.volume.addListener(saveSetState);
    Holder.repeatCurrent.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    durationSub.cancel();
    positionSub.cancel();
    Holder.volume.removeListener(saveSetState);
    Holder.repeatCurrent.removeListener(saveSetState);
  }

  void durationListener(Duration? event) {
    if(event != null) {
      setState(() {
        duration = event.inSeconds;
      });
    }
  }

  void positionListener(Duration event) {
    setState(() {
      position = event.inSeconds;
    });
  }

  void saveSetState() {try {setState(() {});} catch (_) {}}

  @override
  Widget build(BuildContext context) {
    VideoDTO video = Holder.handler.currentTrack!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primary]
          ),
        ),
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              const SizedBox(height: 220, child: CustomNetworkImage(isHighRes: true)),
              const Spacer(flex: 3,),
              Text(utils.shortMusicTitle(video), style: Theme.of(context).textTheme.titleLarge, maxLines: 3, textAlign: TextAlign.center,),
              const Spacer(flex: 1,),
              Text(video.author, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(flex: 1,),
              if(Holder.bigTrackViewPlaylistName != null) Text('Aus Playlist: ${Holder.bigTrackViewPlaylistName!}', style: Theme.of(context).textTheme.titleMedium,),
              const Spacer(flex: 4,),
              Row(
                children: [
                  const Spacer(flex: 4,),
                  CircleAvatar(radius: 30, backgroundColor: Theme.of(context).colorScheme.secondary, child: IconButton(icon: Icon(Holder.repeatCurrent.value? Icons.repeat_one : Icons.repeat, size: 33, color: Theme.of(context).colorScheme.tertiary,), onPressed: () {
                    if(Holder.handler.currentTrack != null) {
                      Holder.repeatCurrent.value = !Holder.repeatCurrent.value;
                    }
                  },),),
                  const Spacer(flex: 10,),
                  CircleAvatar(radius: 35, backgroundColor: Theme.of(context).colorScheme.secondary, child: IconButton(icon: Icon(Icons.skip_previous, size: 40, color: Theme.of(context).colorScheme.tertiary,), onPressed: () {
                    setState(() {
                      if(Holder.handler.videoDTOQueue.isNotEmpty) Holder.handler.skipToPrevious();
                    });
                  },),),
                  const Spacer(flex: 4,),
                  CircleAvatar(radius: 40, backgroundColor: Theme.of(context).colorScheme.secondary, child: IconButton(icon: Icon(Holder.handler.audioPlayer.playing? Icons.pause : Icons.play_arrow, size: 40, color: Theme.of(context).colorScheme.tertiary,), onPressed: () {
                    setState(() {
                      if(Holder.handler.audioPlayer.playing) {
                        Holder.handler.pause();
                      } else {
                        Holder.handler.play();
                      }
                    });
                  },),),
                  const Spacer(flex: 4,),
                  CircleAvatar(radius: 35, backgroundColor: Theme.of(context).colorScheme.secondary, child: IconButton(icon: Icon(Icons.skip_next, size: 40, color: Theme.of(context).colorScheme.tertiary,), onPressed: () {
                    setState(() {
                      if(Holder.handler.videoDTOQueue.isNotEmpty) Holder.handler.skipToNext();
                    });
                  },),),
                  const Spacer(flex: 10,),
                  CircleAvatar(radius: 30, backgroundColor: Theme.of(context).colorScheme.secondary, child: IconButton(icon: Icon(Icons.shuffle, size: 30, color: Theme.of(context).colorScheme.tertiary,), onPressed: () {
                    setState(() {
                      VideoDTO? temp;
                      if(Holder.handler.currentTrack != null) {
                        temp = Holder.handler.currentTrack;
                        Holder.handler.videoDTOQueue.remove(Holder.handler.currentTrack);
                      }
                      Holder.handler.videoDTOQueue.shuffle();
                      if(temp != null) Holder.handler.videoDTOQueue.add(temp);
                    });
                  },),),
                  const Spacer(flex: 4,),
                ],
              ),
              const Spacer(flex: 2,),
              Row(
                children: [
                  const SizedBox(width: 5,),
                  Text(utils.formatTime(position)),
                  Expanded(
                    child: Slider(
                      inactiveColor: Theme.of(context).colorScheme.tertiary,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: position.toDouble(),
                      min: 0,
                      max: duration.toDouble(),
                      onChanged: (value) async {
                        final pos = Duration(seconds: value.toInt());
                        await Holder.handler.audioPlayer.seek(pos);
                      },
                    ),
                  ),
                  Text(utils.formatTime(duration)),
                  const SizedBox(width: 5,),
                ],
              ),
              const Spacer(flex: 5,),
              FutureBuilder<Widget>(
                future: getStats(video),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Row(
                      children: [
                        snapshot.data!,
                        getVolumeDisplayer()
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const Spacer(flex: 20,),
            ],
          ),
        )
      ),
    );
  }

  Future<Widget> getStats(VideoDTO video) async {

    int playlistCount = await db.getAllPlaylistEntries(video.id);
    int rank = await db.getViewRank(video.views);

    List<Widget> widgets = [];

    if(context.mounted) {

      widgets.add(
        Row(children: [
          const Icon(Icons.access_time_rounded),
          const SizedBox(width: 10,),
          Text(utils.formatDateTime(video.uploadDate), style: Theme.of(context).textTheme.titleMedium,),
        ],),
      );
      widgets.add(
        Row(children: [
          const Icon(Icons.bar_chart),
          const SizedBox(width: 10,),
          Text('${video.views} Aufruf${video.views == 1? '' : 'e'}', style: Theme.of(context).textTheme.titleMedium,),
        ],),
      );
      widgets.add(
        Row(children: [
          const Icon(Icons.star_border),
          const SizedBox(width: 10,),
          Text('Rang: $rank', style: Theme.of(context).textTheme.titleMedium,),
        ],),
      );
      widgets.add(
        Row(children: [
          const Icon(Icons.numbers),
          const SizedBox(width: 10,),
          Text('$playlistCount Playlisteintr${playlistCount == 1? 'ag' : 'äge'}', style: Theme.of(context).textTheme.titleMedium,),
        ],),
      );

      return Expanded(flex: 80, child: Column(children: widgets,));
    }
    return const SizedBox();
  }

  Widget getVolumeDisplayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(height: volumeSize, width: volumeSize, padding: const EdgeInsets.all(10.0), child: CircularProgressIndicator(
          value: Holder.volume.value,
          color: Theme.of(context).colorScheme.tertiary,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),),
        Text('${(Holder.volume.value * 15).round()}', style: Theme.of(context).textTheme.titleLarge,),
      ],
    );
  }

}