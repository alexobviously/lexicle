RegExp _username = RegExp(r'^[a-zA-Z0-9-_]+$');
const usernameMinLength = 3;
const usernameMaxLength = 16;

isValidUsername(String username) =>
    _username.hasMatch(username) && username.length >= usernameMinLength && username.length <= usernameMaxLength;
