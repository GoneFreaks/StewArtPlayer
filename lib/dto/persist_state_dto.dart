import 'location_dto.dart';

class PersistStateDTO {

  final List<String> queueIds;
  final String currentTrackId;
  final int currentTrackPosition;
  final LocationDTO location;

  PersistStateDTO({required this.queueIds, required this.currentTrackId, required this.currentTrackPosition, required this.location});

  factory PersistStateDTO.fromJson(dynamic json) {
    return PersistStateDTO(
      queueIds: json['queueIds'].cast<String>(),
      currentTrackId: json['currentTrackId'],
      currentTrackPosition: json['currentTrackPosition'],
      location: LocationDTO.fromJson(json['location'])
    );
  }

  Map toJson() => {
    'queueIds': queueIds,
    'currentTrackId': currentTrackId,
    'currentTrackPosition': currentTrackPosition,
    'location': location
  };

}