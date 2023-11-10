import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:text_scroll/text_scroll.dart';
import '../helper/utils.dart' as utils;
import '../helper/db_loader.dart' as db;
import '../helper/variable_holder.dart';

class VideoWidget extends StatefulWidget {
  final VideoDTO video;

  const VideoWidget({super.key, required this.video});


  @override
  State<VideoWidget> createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {

  bool isCurrentTrack = false;

  @override
  void initState() {
    super.initState();
    Holder.useInternet.addListener(saveSetState);
    Holder.animateText.addListener(saveSetState);
    Holder.shortenText.addListener(saveSetState);
    Holder.handler.currentTrackNotifier.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.useInternet.removeListener(saveSetState);
    Holder.animateText.removeListener(saveSetState);
    Holder.shortenText.removeListener(saveSetState);
    Holder.handler.currentTrackNotifier.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    if(Holder.handler.currentTrack != null) isCurrentTrack = Holder.handler.currentTrack!.compareTo(widget.video) == 0;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        border: Border.all(color: isCurrentTrack? Colors.white : Colors.transparent, width: isCurrentTrack? 3 : 0),
      ),
      height: 80,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Holder.useInternet.value? (widget.video.location.location == 0? Image.network(widget.video.thumbnailURL) : CachedNetworkImage(imageUrl: widget.video.thumbnailURL)) : Image.asset('assets/default_image_small.png'),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  utils.formatTime(widget.video.duration!.inSeconds),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              if(widget.video.location.location == 0)
                FutureBuilder<bool>(
                  future: db.trackExists(widget.video.id),
                  builder: (context, snapshot) {
                    if(snapshot.hasData && snapshot.data!) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          color: Colors.black,
                          child: const Icon(Icons.save, color: Colors.white, size: 20,),
                        ),
                      );
                    }
                    else {
                      return const SizedBox();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(Holder.animateText.value) TextScroll(
                  utils.shortMusicTitle(widget.video),
                  intervalSpaces: 10,
                  pauseBetween: const Duration(seconds: 5),
                  style: Theme.of(context).textTheme.titleSmall,
                  velocity: const Velocity(pixelsPerSecond: Offset(20 , 0)),
                )
                else Text(utils.shortMusicTitle(widget.video), style: Theme.of(context).textTheme.titleSmall,),
                Text(
                  widget.video.author,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if(widget.video.location.location == 0) Text(
                  utils.intToFormattedString(widget.video.views),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if(widget.video.location.location == 0) Text(
                  utils.dateTimeAsString(widget.video.uploadDate),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveSetState() {
    try {
      if(context.mounted) setState(() {});
    } catch (_) {}

  }
}
