import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stew_art_player/dto/persist_state_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:stew_art_player/helper/network_image.dart';
import 'dto/location_dto.dart';
import 'dto/theme_dto.dart';
import 'helper/utils.dart' as utils;
import 'helper/db_loader.dart' as db;
import 'helper/variable_holder.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool isPlaying = false;
  Duration duration = const Duration(hours: 500);
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    Holder.handler.audioPlayer.playerStateStream.listen((event) {
      setState(() {
        isPlaying = event.playing;
      });
    });

    Holder.handler.audioPlayer.durationStream.listen((event) {
      if(event != null) {
        setState(() {
          duration = event;
        });
      }
    });

    int lastPosition = 0;
    Holder.handler.audioPlayer.positionStream.listen((event) {
      setState(() {
        if(!Holder.handler.hasIncremented && event.inSeconds > 30) db.incrementPlayedTrack(Holder.handler.currentTrack!);
        position = event;
      });
      if((lastPosition != event.inSeconds || event.inSeconds == 0) && Holder.handler.currentTrack != null) {
        lastPosition = event.inSeconds;
        List<String> queueIds = Holder.handler.videoDTOQueue.map((e) => e.id).toList();
        String currentTrackId = Holder.handler.currentTrack!.id;
        LocationDTO location = Holder.handler.currentTrack!.location;
        PersistStateDTO stateDTO = PersistStateDTO(queueIds: queueIds, currentTrackId: currentTrackId, currentTrackPosition: lastPosition, location: location);
        db.persistMusicState(stateDTO);
      }
    });

    Holder.handler.audioPlayer.playbackEventStream.listen((event) async {
      if(event.processingState == ProcessingState.completed) {
        if(Holder.handler.videoDTOQueue.isNotEmpty) {
          position = Duration.zero;
          await Holder.handler.playNext();
        }
      }
    });
    Holder.repeatCurrent.addListener(() {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 3,
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: animatedPlayerControls(),
          crossFadeState: Holder.handler.currentTrack == null? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(seconds: 1),
        ),
      ],
    );
  }

  Widget animatedPlayerControls() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/big');
          },
          child: getDefaultControls(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: getSmallControls(),
        )
      ],
    );
  }

  Widget getDefaultControls() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      height: 140,
      child: Stack(
        children: [
          const CustomNetworkImage(isHighRes: false),
          Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Text(
                  Holder.handler.currentTrack == null ? "Kein Track ausgewählt" : utils.shortMusicTitle(Holder.handler.currentTrack!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Text(Holder.repeatCurrent.value? "REPEAT" : Holder.handler.videoDTOQueue.isNotEmpty? "Up next ${utils.shortMusicTitle(Holder.handler.videoDTOQueue.first)}" : "", style: Theme.of(context).textTheme.bodySmall,),
              ),
              Row(
                children: [
                  const SizedBox(width: 5,),
                  Text(
                    utils.formatTime(position.inSeconds),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      inactiveColor: Theme.of(context).colorScheme.tertiary,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final pos = Duration(seconds: value.toInt());
                        await Holder.handler.audioPlayer.seek(pos);
                      },
                    ),
                  ),
                  Text(
                    utils.formatTime(duration.inSeconds),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 5,),
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: Icon(Holder.repeatCurrent.value? Icons.repeat_one : Icons.repeat, size: 25, color: ThemeDTO.getTextColor(),),
                      onPressed: () {
                        setState(() {
                          if(Holder.handler.currentTrack != null) {
                            Holder.repeatCurrent.value = !Holder.repeatCurrent.value;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 5,),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: Icon(Icons.shuffle, size: 25, color: ThemeDTO.getTextColor()),
                      onPressed: () {
                        setState(() {
                          VideoDTO? temp;
                          if(Holder.handler.currentTrack != null) {
                            temp = Holder.handler.currentTrack;
                            Holder.handler.videoDTOQueue.remove(Holder.handler.currentTrack);
                          }
                          Holder.handler.videoDTOQueue.shuffle();
                          if(temp != null) Holder.handler.videoDTOQueue.add(temp);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 5,),
                ],
              ),
              const SizedBox(height: 10,),
            ],
          ),
        ],
      ),
    );
  }

  Widget getSmallControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: IconButton(
              icon: Icon(
                Icons.navigate_before,
                size: 25,
                  color: ThemeDTO.getTextColor()
              ),
              onPressed: () async {
                if (Holder.handler.videoDTOQueue.isNotEmpty) {
                  Holder.handler.skipToPrevious();
                }
              },
            ),
          ),
          const SizedBox(width: 10,),
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 25,
                  color: ThemeDTO.getTextColor()
              ),
              onPressed: () async {
                if (isPlaying) {
                  Holder.handler.pause();
                } else {
                  Holder.handler.play();
                }
              },
            ),
          ),
          const SizedBox(width: 10,),
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: IconButton(
              icon: Icon(
                Icons.navigate_next,
                size: 25,
                  color: ThemeDTO.getTextColor()
              ),
              onPressed: () async {
                if (Holder.handler.videoDTOQueue.isNotEmpty) {
                  Holder.handler.skipToNext();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}