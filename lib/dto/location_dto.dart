class LocationDTO implements Comparable<LocationDTO>{
  final int location;
  final int isInterpret;
  final String playlistName;

  LocationDTO({required this.location, required this.isInterpret, required this.playlistName});

  @override
  int compareTo(LocationDTO other) {
    if(location == other.location && isInterpret == other.isInterpret && playlistName.compareTo(other.playlistName) == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  factory LocationDTO.fromJson(dynamic json) {

    int tempLocation = json['location'];
    String tempPlaylistName = json['playlistName'];
    int tempIsInterpret = 0;

    try {
      tempIsInterpret = json['isInterpret'];
    } catch (_) {}

    return LocationDTO(
      location: tempLocation,
      isInterpret: tempIsInterpret,
      playlistName: tempPlaylistName,

    );
  }

  Map toJson() => {
    'location': location,
    'isInterpret': isInterpret,
    'playlistName': playlistName
  };

}