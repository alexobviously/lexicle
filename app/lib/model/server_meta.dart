class ServerMeta {
  final bool loaded;
  final String serverVersion;
  final String appCurrentVersion;
  final String appMinVersion;
  ServerMeta({
    this.loaded = true,
    required this.serverVersion,
    required this.appCurrentVersion,
    required this.appMinVersion,
  });
  factory ServerMeta.initial() => ServerMeta(
        loaded: false,
        serverVersion: '0.0.0',
        appCurrentVersion: '0.0.0',
        appMinVersion: '0.0.0',
      );
  factory ServerMeta.fromJson(Map<String, dynamic> doc) => ServerMeta(
        serverVersion: doc['version'],
        appCurrentVersion: doc['appCurrentVersion'],
        appMinVersion: doc['appMinVersion'],
      );
}
