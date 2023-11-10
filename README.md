# StewArt

## Motivation
The main idea was to develop an app to use the Discord-Bot Gruwie on your phone.
This concept was changed pretty soon in order to better match the use-cases.

## Basic Functionality
The backbone of this whole app is build around two major packages:
- Youtube Explode Dart
- Just Audio
this results in the following base concept:
- search Youtube-Videos
- download and save those videos (as audio-files)
- play the saved audio-files
- organize the downloaded files in playlists
- ...

## Roadmap
1. Download and save Youtube-Playlists
2. Last used app-tab should be memorized in order to restore it after the app has been closed
3. Lazy loading for youtube-playlists, load youtube-playlist content only if requested
4. Search/Download videos via a given URL
5. Fix the no-internet banner, in the background of the media-controls
6. Change the system behind shuffle, in order to make it reversible
7. Rebuild the LocalTrackView after a track has been edited/deleted
8. Improve the title-shortening system
9. Add user driven backup
10. Add external audio-files
11. Improve/Add Android-Auto functionality
12. Delete only after confirm
13. Automatic Internet-Mode, save internet if not connected to WIFI