class Url {
  static final Url _instance = Url._internal();

  factory Url() {
    return _instance;
  }

  Url._internal();

  final String apiUrl = 'http://192.168.0.249:8080';
  final String ip = '192.168.0.249:8080';
}
