import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/download_dto.dart';
import 'package:stew_art_player/dto/playlist_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:stew_art_player/helper/variable_holder.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'track_loader.dart' as loader;

String intToFormattedString (int number) {
  String asString = '$number';
  int counter = 0;
  String result = '';
  for(int i = asString.length-1; i >= 0; i--) {
    counter++;
    result = '${asString[i]}$result';
    if(counter % 3 == 0 && i != 0) {
      counter = 0;
      result = '.$result';
    }
  }
  return '$result Aufrufe';
}

String formatTime(int duration) {

  int h = duration ~/ 3600;
  duration -= h * 3600;
  int m = duration ~/ 60;
  duration -= m * 60;
  int s = duration;

  String hours = h > 0? '$h:' : '';
  String minutes = m > 0? '$m:' : '0:';
  String seconds = s > 9? '$s' : '0$s';

  return "$hours$minutes$seconds";
}

String dateTimeAsString(DateTime input) {
  int years = DateTime.now().year - input.year;
  int months = DateTime.now().month - input.month;
  int days = DateTime.now().day - input.day;
  if(years > 0) {
    if(years == 1) return 'vor einem Jahr';
    return 'vor $years Jahren';
  }
  if(months > 0) {
    if(months == 1) return 'vor einem Monat';
    return 'vor $months Monaten';
  }
  if(days == 0) {
    return 'vor weniger als einem Tag';
  }
  else {
    if(days == 1) {
      return 'vor einem Tag';
    } else {
      return 'vor $days Tagen';
    }
  }
}

String shortMusicTitle(VideoDTO video){
  if(Holder.shortenText.value) {
    String shortTitle = video.title;
    List<String> splitted = shortTitle.split("-");
    shortTitle = splitted.length > 1? splitted[1].trim() : splitted[0].trim();
    int index = shortTitle.indexOf("(");
    if(index > 0) shortTitle = shortTitle.substring(0, index);
    index = shortTitle.indexOf("[");
    if(index > 0) shortTitle = shortTitle.substring(0, index);
    return shortTitle;
  }
  else {
    return video.title;
  }
}

void showLoadingDialog(BuildContext context, Video video, bool tempFile) {

  String downloadID = 'v ${video.id.toString()}';

  for (DownloadDTO downloadDTO in Holder.downloads) {
    print("NOP");
    if(downloadDTO.id.compareTo(downloadID) == 0) return;
  }

  Stream<double> stream = tempFile? loader.saveAudioAsTemporary(video, context) : loader.saveAudioAsPermanent(video, context, context);
  Holder.downloads.add(DownloadDTO(stream: stream, name: video.title, id: downloadID));
  Holder.newDownload.value = !Holder.newDownload.value;
}

void showPlaylistLoadingDialog(BuildContext context, PlaylistDTO playlist) {

  String downloadID = 'p ${playlist.id}';

  for (DownloadDTO downloadDTO in Holder.downloads) {
    print("NOP");
    if(downloadDTO.id.compareTo(downloadID) == 0) return;
  }

  Stream<double> stream = loader.savePlaylist(playlist, context, context);
  Holder.downloads.add(DownloadDTO(stream: stream, name: playlist.title, id: downloadID));
  Holder.newDownload.value = !Holder.newDownload.value;
}

void sortTracks(List<VideoDTO> videos, int filter) {
  switch (filter) {
    case 0:
      videos.sort((a,b) => shortMusicTitle(a).toLowerCase().compareTo(shortMusicTitle(b).toLowerCase()));
      break;
    case 1:
      videos.sort((a,b) => -shortMusicTitle(a).toLowerCase().compareTo(shortMusicTitle(b).toLowerCase()));
      break;
    case 2:
      videos.sort((a,b) => authorSort(a,b));
      break;
    case 3:
      videos.sort((a,b) => -authorSort(a,b));
      break;
    case 4:
      videos.sort((a,b) => -a.uploadDate.compareTo(b.uploadDate));
      break;
    case 5:
      videos.sort((a,b) => -a.views + b.views);
      break;
    case 6:
      videos.sort((a,b) => a.views - b.views);
      break;
  }
}

List<DropdownMenuItem<int>> getFilterNames() {

  List<DropdownMenuItem<int>> result = [];

  result.add(const DropdownMenuItem<int>(
    value: 0,
    child: Text('Alphabetisch A-Z'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 1,
    child: Text('Alphabetisch Z-A'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 2,
    child: Text('Interpret A-Z'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 3,
    child: Text('Interpret Z-A'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 4,
    child: Text('Zuletzt hinzugefügt'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 5,
    child: Text('Aufrufe TOP'),
  ));

  result.add(const DropdownMenuItem<int>(
    value: 6,
    child: Text('Aufrufe LOW'),
  ));

  return result;
}

int authorSort(VideoDTO a, VideoDTO b) {
  int result = a.author.compareTo(b.author);
  if(result == 0) {
    return shortMusicTitle(a).compareTo(shortMusicTitle(b));
  } else {
    return result;
  }
}

void showSnackBar(int duration, String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center,),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.black54,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    duration: Duration(seconds: duration),
  ));
}

RoundedRectangleBorder getDialogBorder() {
  return const RoundedRectangleBorder(
    side: BorderSide(width: 3, color: Colors.white30),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
}

String formatDateTime(DateTime dateTime) {

  String time = '${dateTime.hour < 10? '0' : ''}${dateTime.hour}:${dateTime.minute < 10? '0' : ''}${dateTime.minute}';
  String date = '${dateTime.day < 10? '0' : ''}${dateTime.day}.${dateTime.month < 10? '0' : ''}${dateTime.month}.${dateTime.year < 10? '0' : ''}${dateTime.year}';

  return '$time $date';
}