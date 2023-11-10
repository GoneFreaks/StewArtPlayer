import 'package:flutter/material.dart';
import 'package:stew_art_player/minor_widgets/video_widget.dart';
import '../dto/video_dto.dart';
import '../helper/variable_holder.dart';

class LocalTrackWidget extends StatefulWidget {

  final VideoDTO video;
  final List<VideoDTO> videos;

  const LocalTrackWidget({super.key, required this.video, required this.videos});
  @override
  State<LocalTrackWidget> createState() => LocalTrackWidgetState();
}

class LocalTrackWidgetState extends State<LocalTrackWidget> {

  @override
  void initState() {
    super.initState();
    Holder.isEditingMode.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.isEditingMode.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    bool useDifferentColor = true;
    if(Holder.checkedBoxes[widget.video.id] == null) {
      useDifferentColor = false;
    }
    else {
      useDifferentColor = Holder.checkedBoxes[widget.video.id]!;
    }
    return InkWell(
      onTap: () async {
        if (Holder.isEditingMode.value) {
          setState(() {
            Holder.checkedBoxes[widget.video.id] = !Holder.checkedBoxes[widget.video.id]!;
            if(Holder.checkedBoxes[widget.video.id]!) {
              Holder.trueCounter.value++;
            } else {
              Holder.trueCounter.value--;
            }
          });
        } else {
          if(Holder.handler.currentTrack != null && Holder.handler.currentTrack!.compareTo(widget.video) == 0) {
            Navigator.pushNamed(context, '/big');
          }
          else {
            Holder.handler.loadTracks(widget.video, widget.videos);
            Holder.handler.loadTrack(widget.video);
            Holder.bigTrackViewPlaylistName = null;
          }
        }
      },
      onLongPress: () {
        setState(() {
          Holder.isEditingMode.value = true;
          Holder.checkedBoxes[widget.video.id] = true;
          Holder.trueCounter.value++;
        });
      },
      child: Container(
        color: useDifferentColor? Theme.of(context).colorScheme.background : Colors.transparent,
        height: 80,
        child: Row(
          children: [
            if (Holder.isEditingMode.value)
              Checkbox(
                activeColor: Colors.black,
                value: Holder.checkedBoxes[widget.video.id],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      if(value) {
                        Holder.trueCounter.value++;
                      } else {
                        Holder.trueCounter.value--;
                      }
                      Holder.checkedBoxes[widget.video.id] = value;
                    });
                  }
                },
              ),
            Expanded(child: VideoWidget(video: widget.video))
          ],
        ),
      ),
    );
  }

  void saveSetState() {
    try {
      setState(() {});
    } catch (_){}
  }
}