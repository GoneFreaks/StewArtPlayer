class DownloadDTO implements Comparable<DownloadDTO> {
  Stream<double> stream;
  final String name;
  final String id;

  DownloadDTO({required this.name, required this.stream, required this.id}) {
    stream = stream.asBroadcastStream();
  }

  @override
  int compareTo(DownloadDTO other) {
    return other.id.compareTo(id);
  }
}