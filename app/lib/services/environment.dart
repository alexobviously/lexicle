class Environment {
  String serverHost;
  String authDomain;
  String authClientId;
  String authRedirectUri;
  String get authIssuer => 'https://$authDomain';
  Environment({
    required this.serverHost,
    required this.authDomain,
    required this.authClientId,
    required this.authRedirectUri,
  });
  factory Environment.def() => Environment(
        serverHost: 'https://word-w7y24cao7q-ew.a.run.app',
        authDomain: 'jauska.eu.auth0.com',
        authClientId: 'gmaEut5WPBkwuds9Ya6a6ip87E70Vvye',
        authRedirectUri: 'com.jauska.lexicle://post-auth',
      );
}
