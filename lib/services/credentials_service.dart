/// Service for managing user credentials.
/// Currently returns hardcoded credentials, but designed to be easily
/// extended with a login page or secure storage in the future.
class CredentialsService {
  // TODO: Replace with login page or secure storage
  String getUsername() => "זמיריא0300";
  String getPassword() => "0542585557";

  // Future implementation example:
  // String? _username;
  // String? _password;
  //
  // Future<void> login(String username, String password) async {
  //   _username = username;
  //   _password = password;
  //   // Validate credentials by attempting login
  // }
  //
  // String getUsername() => _username ?? "";
  // String getPassword() => _password ?? "";
  // bool isLoggedIn() => _username != null && _password != null;
}
