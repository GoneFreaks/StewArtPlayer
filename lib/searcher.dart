import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/playlist_dto.dart';
import 'package:stew_art_player/minor_widgets/playlist_widget.dart';
import 'package:stew_art_player/minor_widgets/track_container.dart';
import 'package:stew_art_player/minor_widgets/video_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dto/theme_dto.dart';
import 'dto/video_dto.dart';
import 'helper/utils.dart' as utils;
import 'helper/variable_holder.dart';

class Searcher extends StatefulWidget {
  const Searcher({super.key});

  @override
  State<StatefulWidget> createState() => SearcherState();
}

class SearcherState extends State<Searcher> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    if(Holder.searchQuery != null) controller.text = Holder.searchQuery!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () {
                if (Holder.useInternet.value) {
                  setState(() {
                    if (isSearch) {
                      searchVideosByInput();
                    } else {
                      isSearch = true;
                    }
                  });
                }
              },
              iconSize: 40,
            ),
          ],
        ),
        if (isSearch)
          Row(
            children: [
              const SizedBox(width: 15,),
              Expanded(child: TextField(
                controller: controller,
                style: ThemeDTO.getBodyMedium(),
                decoration: InputDecoration(
                  icon: IconButton(
                    icon: Icon(Icons.clear, color: ThemeDTO.getTextColor(),),
                    onPressed: () {
                      controller.text = '';
                    },
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ThemeDTO.getTextColor())),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ThemeDTO.getTextColor())),
                ),
                autocorrect: false,
                autofocus: true,
                onSubmitted: (value) {
                  searchVideosByInput();
                },
                onChanged: (value) {
                  Holder.searchQuery = value;
                },
              )),
              const SizedBox(width: 15,),
            ],
          ),
        if (Holder.searchResultsVideo.isNotEmpty)
          Expanded(
            child: PageView.builder(itemCount: 2, controller: PageController(initialPage: 0),itemBuilder: (context, index) {
              if(index == 0) {
                return TrackContainer(widgets: videoListToWidgetList(Holder.searchResultsVideo),);
              } else {
                return TrackContainer(widgets: playlistToWidgetList(Holder.searchResultsPlaylist),);
              }
            })
          ),
      ],
    );
  }

  void searchVideosByInput() async {
    Holder.searchResultsVideo = [];
    Holder.searchResultsPlaylist = [];
    setState(() {
      isSearch = false;
    });

    if (Holder.searchQuery != null && Holder.searchQuery!.isNotEmpty) {
      YoutubeExplode youtube = YoutubeExplode();
      SearchList searchList = await youtube.search.searchContent(Holder.searchQuery!, filter: const SearchFilter('EgIQAw%253D%253D'));
      for(SearchResult result in searchList) {
        try {
          SearchPlaylist playlist = result as SearchPlaylist;
          Holder.searchResultsPlaylist.add(PlaylistDTO.fromPlaylist(playlist, await youtube.playlists.getVideos(playlist.id).toList()));
        } catch (_) {}
      }
      VideoSearchList search = await youtube.search.search(Holder.searchQuery!);
      for (Video video in search) {
        Holder.searchResultsVideo.add(video);
      }
      youtube.close();
      if (search.isEmpty) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: utils.getDialogBorder(),
                  backgroundColor: Theme.of(context).colorScheme.background,
                  content: SizedBox(
                    width: 350,
                    height: 250,
                    child: Column(
                      children: [
                        Text(
                          "Diese Suche ergab keinen Treffer, ändere die Suche leicht ab!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          'assets/no.gif',
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                );
              });
        }
      }
      setState(() {});
    }
  }

  List<Widget> videoListToWidgetList(List<Video> videos){
    List<Widget> result = [];
    for (Video video in videos) {
      result.add(InkWell(
        onTap: () {
          utils.showLoadingDialog(context, video, true);
        },
        onLongPress: () {
          utils.showLoadingDialog(context, video, false);
        },
        child: VideoWidget(video: VideoDTO.fromVideo(video))
      ));
      result.add(const SizedBox(
        height: 10,
      ));
    }
    return result;
  }

  List<Widget> playlistToWidgetList(List<PlaylistDTO> playlists) {
    List<Widget> result = [];
    for(PlaylistDTO playlist in playlists) {
      result.add(InkWell(
        onTap: () async {
          YoutubeExplode youtube = YoutubeExplode();
          List<Widget> widgets = [];
          for(VideoDTO video in playlist.videos) {
            widgets.add(VideoWidget(video: video));
          }
          if(context.mounted) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    content: SizedBox(
                      height: 500,
                      width: 600,
                      child: ListView(children: widgets,),
                    ),
                  );
                }
            );
          }
          youtube.close();
        },
        onLongPress: () {
          utils.showPlaylistLoadingDialog(context, playlist);
        },
        child: PlaylistWidget(playlist: playlist,),
      ));
      result.add(const SizedBox(
        height: 10,
      ));
    }
    return result;
  }

}
