import 'package:flutter/material.dart';

import '../dto/playlist_dto.dart';
import '../helper/db_loader.dart' as db;

class PlaylistWidget extends StatefulWidget {
  final PlaylistDTO playlist;

  const PlaylistWidget({super.key, required this.playlist});

  @override
  State<PlaylistWidget> createState() => PlaylistWidgetState();
}

class PlaylistWidgetState extends State<PlaylistWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      ),
      height: 80,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.network(widget.playlist.videos.first.thumbnailURL),
              FutureBuilder<bool>(
                future: db.ytPlaylistExists(widget.playlist.id),
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
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  widget.playlist.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text('${widget.playlist.videoCount} Tracks', style: Theme.of(context).textTheme.bodySmall,),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 10,),
        ],
      ),
    );
  }
}