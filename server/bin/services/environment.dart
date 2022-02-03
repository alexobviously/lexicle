class Environment {
  int port;
  String mongoUser;
  String mongoPass;
  String mongoDb;
  String mongoHost;
  String jwtSecret;

  Environment({
    required this.port,
    required this.mongoUser,
    required this.mongoPass,
    required this.mongoDb,
    required this.mongoHost,
    required this.jwtSecret,
  });
}
