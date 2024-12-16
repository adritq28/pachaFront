class Url {
  static final Url _instance = Url._internal();

  factory Url() {
    return _instance;
  }

  Url._internal();

  final String apiUrl = 'https://192.168.100.236:8080';
  final String ip = '192.168.100.236:8080';
}
