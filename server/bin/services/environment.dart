class Environment {
  String version;
  int port;
  String mongoUser;
  String mongoPass;
  String mongoDb;
  String mongoHost;
  String jwtSecret;
  String serverName;

  Environment({
    required this.version,
    required this.port,
    required this.mongoUser,
    required this.mongoPass,
    required this.mongoDb,
    required this.mongoHost,
    required this.jwtSecret,
    required this.serverName,
  });
}
