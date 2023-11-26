import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stew_art_player/dto/persist_state_dto.dart';
import 'package:stew_art_player/dto/video_dto.dart';
import 'package:stew_art_player/helper/variable_holder.dart';
import '../dto/playlist_dto.dart';
import 'utils.dart' as utils;
import '../dto/location_dto.dart';
import 'dart:convert';

late Database db;
late SharedPreferences pref;

Future<void> initDataBase() async {
  String defaultPath = await getDatabasesPath();
  String path = '$defaultPath/data.db';
  db = await openDatabase(path, version: 3, onCreate: (Database db, int version) {
    String videosDDL = 'CREATE TABLE tracks (title TEXT, id TEXT primary key, viewCount INTEGER DEFAULT 0, duration INTEGER, thumbnailURL TEXT, thumbnailURLHR TEXT, author TEXT, upload INTEGER)';
    db.execute(videosDDL);
    String playlistsDDL = 'CREATE TABLE playlists (name TEXT, id TEXT)';
    db.execute(playlistsDDL);

    String pVideosDDL = 'CREATE TABLE pTracks (title TEXT, id TEXT primary key, viewCount INTEGER DEFAULT 0, duration INTEGER, thumbnailURL TEXT, thumbnailURLHR TEXT, author TEXT, upload INTEGER)';
    db.execute(pVideosDDL);
    String pPlaylistsDDL = 'CREATE TABLE pPlaylists (name TEXT, playlistID TEXT, id TEXT)';
    db.execute(pPlaylistsDDL);

  }, onUpgrade: (Database db, int oldVersion, int newVersion) async {

    if(oldVersion == 1 && newVersion == 2) {

      String videosDDL = 'CREATE TABLE tracks (title TEXT, id TEXT primary key, viewCount INTEGER DEFAULT 0, duration INTEGER, thumbnailURL TEXT, thumbnailURLHR TEXT, author TEXT, upload INTEGER)';
      await db.execute(videosDDL);

      String fillNewTableDDL = 'INSERT INTO tracks (title, id, duration, thumbnailURL, thumbnailURLHR, author, upload, viewCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
      List<Map<String, Object?>> allVideoEntries = await db.rawQuery('SELECT * FROM videos');
      Batch batchFill = db.batch();
      for (Map<String, Object?> map in allVideoEntries) {
        db.rawInsert(fillNewTableDDL, [map['title'], map['id'], map['duration'], map['thumbnailURL'], map['thumbnailURLHR'], map['author'], map['upload'], 0]);
      }
      await batchFill.commit();

      await db.execute('DROP TABLE videos');
    }

    if(oldVersion == 2 && newVersion == 3) {
      String pVideosDDL = 'CREATE TABLE pTracks (title TEXT, id TEXT primary key, viewCount INTEGER DEFAULT 0, duration INTEGER, thumbnailURL TEXT, thumbnailURLHR TEXT, author TEXT, upload INTEGER)';
      db.execute(pVideosDDL);
      String pPlaylistsDDL = 'CREATE TABLE pPlaylists (name TEXT, playlistID TEXT, id TEXT)';
      db.execute(pPlaylistsDDL);
    }
    
  });
}

void saveVideoDTO(VideoDTO video) async {
  db.insert("tracks", {"title": video.title, "id": video.id, "duration": video.duration!.inSeconds, "thumbnailURL": video.thumbnailURL, "author": video.author, "thumbnailURLHR": video.thumbnailURLHR, "upload": DateTime.now().millisecondsSinceEpoch, "viewCount": 0});
}

Future<void> saveYoutubePlaylist(PlaylistDTO youtubePlaylist, List<VideoDTO> videos) async {
  Batch batch = db.batch();
  for(VideoDTO video in videos) {
    if(!youtubePlaylist.knownIds.contains(video.id)) batch.insert("pTracks", {"title": video.title, "id": video.id, "duration": video.duration!.inSeconds, "thumbnailURL": video.thumbnailURL, "author": video.author, "thumbnailURLHR": video.thumbnailURLHR, "upload": DateTime.now().millisecondsSinceEpoch, "viewCount": 0});
    batch.insert("pPlaylists", {"name" : youtubePlaylist.title, "id": video.id, "playlistID": youtubePlaylist.id});
  }
  await batch.commit(noResult: true);
}

Future<VideoDTO?> getVideoDTO(String id, LocationDTO location) async {
  List<Map<String, Object?>> result = await db.rawQuery("SELECT * FROM tracks WHERE id=?", [id]);
  if(result.isNotEmpty) {
    Map<String, Object?> map = result[0];
    VideoDTO newDTO = VideoDTO(title: map["title"] as String, id: id, views: map["viewCount"] as int, duration: Duration(seconds: map["duration"] as int), thumbnailURL: map["thumbnailURL"] as String, author: map["author"] as String, thumbnailURLHR: map["thumbnailURLHR"] as String, uploadDate: DateTime.fromMillisecondsSinceEpoch(map["upload"] as int), location: location);
    return newDTO;
  }
  return null;
}

Future<List<VideoDTO>> getVideoDTOs(String playlistName, LocationDTO location) async {
  List<VideoDTO> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery("SELECT v.* FROM tracks v JOIN playlists p USING (id) WHERE p.name = ?", [playlistName]);
  for (Map<String, Object?> map in result) {
    VideoDTO newDTO = VideoDTO(title: map["title"] as String, id: map["id"] as String, views: map["viewCount"] as int, duration: Duration(seconds: map["duration"] as int), thumbnailURL: map["thumbnailURL"] as String, author: map["author"] as String, thumbnailURLHR: map["thumbnailURLHR"] as String, uploadDate: DateTime.fromMillisecondsSinceEpoch(map["upload"] as int), location: location);
    temp.add(newDTO);
  }
  return temp;
}

Future<List<VideoDTO>> getYTVideoDTOs(String playlistName, LocationDTO location) async {
  List<VideoDTO> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery("SELECT v.* FROM pTracks v JOIN pPlaylists p USING (id) WHERE p.name = ?", [playlistName]);
  for (Map<String, Object?> map in result) {
    VideoDTO newDTO = VideoDTO(title: map["title"] as String, id: map["id"] as String, views: map["viewCount"] as int, duration: Duration(seconds: map["duration"] as int), thumbnailURL: map["thumbnailURL"] as String, author: map["author"] as String, thumbnailURLHR: map["thumbnailURLHR"] as String, uploadDate: DateTime.fromMillisecondsSinceEpoch(map["upload"] as int), location: location);
    temp.add(newDTO);
  }
  return temp;
}

Future<List<VideoDTO>> getVideoDTOsByAuthor(String author, LocationDTO location) async {
  List<VideoDTO> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery("SELECT * FROM tracks WHERE author=?", [author]);
  for (Map<String, Object?> map in result) {
    VideoDTO newDTO = VideoDTO(title: map["title"] as String, id: map["id"] as String, views: map["viewCount"] as int, duration: Duration(seconds: map["duration"] as int), thumbnailURL: map["thumbnailURL"] as String, author: map["author"] as String, thumbnailURLHR: map["thumbnailURLHR"] as String, uploadDate: DateTime.fromMillisecondsSinceEpoch(map["upload"] as int), location: location);
    temp.add(newDTO);
  }
  return temp;
}

Future<List<String>> getPlaylistNames() async {
  List<String> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery('SELECT name FROM playlists GROUP BY name ORDER BY NAME ASC');
  for (Map<String, Object?> name in result) {
    temp.add(name["name"] as String);
  }
  return temp;
}

Future<List<String>> getYoutubePlaylistNames() async {
  List<String> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery('SELECT name FROM pPlaylists GROUP BY name ORDER BY NAME ASC');
  for (Map<String, Object?> name in result) {
    temp.add(name["name"] as String);
  }
  return temp;
}

Future<void> createPlaylist(List<String> ids, String playlistName) async {
  Batch insertBatch = db.batch();
  for (String id in ids) {
    insertBatch.rawInsert('INSERT INTO playlists (name, id) SELECT ?, ? WHERE 0 = (SELECT COUNT(*) FROM playlists WHERE name = ? AND id = ?)', [playlistName, id, playlistName, id]);
  }
  insertBatch.commit(noResult: true);
}

Future<int> getPlaylistTrackCount(String name) async {
  List<Map<String, Object?>> result = await db.rawQuery("SELECT COUNT(*) as count FROM playlists WHERE name=?", [name]);
  if(result.isNotEmpty) {
    return result[0]["count"] as int;
  }
  else {
    return 0;
  }
}

Future<int> getYTPlaylistTrackCount(String name) async {
  List<Map<String, Object?>> result = await db.rawQuery("SELECT COUNT(*) as count FROM pPlaylists WHERE name=?", [name]);
  if(result.isNotEmpty) {
    return result[0]["count"] as int;
  }
  else {
    return 0;
  }
}

Future<int> getInterpretTrackCount(String author) async {
  List<Map<String, Object?>> result = await db.rawQuery("SELECT COUNT(*) as count FROM tracks WHERE author=?", [author]);
  if(result.isNotEmpty) {
    return result[0]["count"] as int;
  }
  else {
    return 0;
  }
}

void deleteIDEntry(String id) async {
  await db.rawDelete("DELETE FROM tracks WHERE id=?", [id]);
  await db.rawDelete("DELETE FROM playlists WHERE id=?", [id]);
}

Future<void> deletePlaylist(String name) async {
  await db.rawDelete("DELETE FROM playlists WHERE name=?", [name]);
}

Future<void> deletePlaylistEntry(String name, String id) async {
  await db.rawDelete("DELETE from playlists WHERE name=? AND id=?", [name, id]);
}

//SELECT t.id FROM pPlaylists pP LEFT JOIN tracks t ON pP.id == t.id WHERE t.id IS NOT NULL
Future<void> deleteYTPlaylist(String playlistID) async {
  await db.rawDelete("DELETE FROM pPlaylists WHERE playlistID=?", [playlistID]);
}

Future<Set<String>> getAllTrackIDs() async {
  Set<String> result = {};
  for (Map<String, Object?> map in await db.rawQuery("SELECT id FROM tracks")) {
    result.add(map["id"] as String);
  }
  for (Map<String, Object?> map in await db.rawQuery("SELECT id FROM pTracks")) {
    result.add(map["id"] as String);
  }
  return result;
}

Future<List<VideoDTO>> getAllLocalTracks(BuildContext context) async {
  List<VideoDTO> temp = [];
  List<Map<String, Object?>> result = await db.rawQuery("SELECT * FROM tracks");
  for (Map<String, Object?> map in result) {
    VideoDTO newDTO = VideoDTO(title: map["title"] as String, id: map["id"] as String, views: map["viewCount"] as int, duration: Duration(seconds: map["duration"] as int), thumbnailURL: map["thumbnailURL"] as String, author: map["author"] as String, thumbnailURLHR: map["thumbnailURLHR"] as String, uploadDate: DateTime.fromMillisecondsSinceEpoch(map["upload"] as int), location: LocationDTO(location: 1, isInterpret: 1, playlistName: ''));
    temp.add(newDTO);
  }

  if(Holder.localSearch.value.isNotEmpty) {
    temp.retainWhere((element) {
      return utils.shortMusicTitle(element).toLowerCase().contains(Holder.localSearch.value.toLowerCase());
    });
  }

  return temp;
}

Future<List<String>> getInterprets() async {
  List<String> result = [];
  List<Map<String, Object?>> resultSet = await db.rawQuery("SELECT author FROM tracks GROUP BY author ORDER BY author ASC");
  for (Map<String, Object?> map in resultSet) {
    result.add(map["author"] as String);
  }
  return result;
}

Future<bool> trackExists(String id) async {
  return (await getVideoDTO(id, LocationDTO(location: 1, isInterpret: 1, playlistName: ''))) != null;
}

Future<bool> ytPlaylistExists(String id) async {
  List<Map<String, Object?>> result = await db.rawQuery("SELECT v.* FROM pTracks v JOIN pPlaylists p USING (id) WHERE p.playlistID = ?", [id]);
  return result.isNotEmpty;
}

Future<void> initPreferences() async {
  pref = await SharedPreferences.getInstance();
}

Future<bool> readUseInternet() async {
  bool? result = pref.getBool("useInternet");
  if(result == null) {
    return true;
  } else {
    return result;
  }
}

void writeUseInternet(bool value) async {
  pref.setBool("useInternet", value);
}

Future<bool> readAnimateText() async {
  bool? result = pref.getBool("animateText");
  if(result == null) {
    return true;
  } else {
    return result;
  }
}

void writeAnimateText(bool value) async {
  pref.setBool("animateText", value);
}

Future<bool> readShortenText() async {
  bool? result = pref.getBool("shortenText");
  if(result == null) {
    return true;
  } else {
    return result;
  }
}

void writeShortenText(bool value) async {
  pref.setBool("shortenText", value);
}

Future<bool> readShowVolume() async {
  bool? result = pref.getBool("showVolume");
  if(result == null) {
    return false;
  } else {
    return result;
  }
}

void writeShowVolume(bool value) async {
  pref.setBool("showVolume", value);
}

Future<void> renameTrack(String id, String title) async {
  await db.rawUpdate('UPDATE tracks SET title=? WHERE id=?', [title, id]);
}

Future<void> renameInterpret(List<String> ids, String newInterpret) async {
  Batch batch = db.batch();
  for (String id in ids) {
    batch.rawUpdate("UPDATE tracks SET author=? WHERE id=?", [newInterpret, id]);
  }
  await batch.commit(noResult: true);
}

Future<void> incrementPlayedTrack(VideoDTO video) async {
  await db.rawUpdate('UPDATE tracks SET viewCount = ? WHERE id=?', [video.views + 1, video.id]);
}

Future<void> writeTheme(int theme) async {
  await pref.setInt('theme', theme);
}

Future<int> readTheme() async {
  int? temp = pref.getInt('theme');
  if(temp == null) {
    return 0;
  } else {
    return temp;
  }
}

Future<void> persistMusicState(PersistStateDTO stateDTO) async {
  await pref.setString('persistMusic', jsonEncode(stateDTO));
}

Future<PersistStateDTO?> readMusicState() async {
  String? jsonString = pref.getString('persistMusic');
  if(jsonString == null) return null;
  return PersistStateDTO.fromJson(jsonDecode(jsonString));
}

Future<int> getAllPlaylistEntries(String id) async {
  List<Map<String, Object?>> resultSet = await db.rawQuery('SELECT * FROM playlists WHERE id = ?', [id]);
  return resultSet.length;
}

Future<int> getViewRank(int viewCount) async {
  List<Map<String, Object?>> resultSet = await db.rawQuery('SELECT COUNT(*) as count FROM tracks WHERE viewCount > ?', [viewCount]);
  return (resultSet[0]['count'] as int) + 1;
}