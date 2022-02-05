RegExp usernameRegex = RegExp(r'^[a-z0-9-_]+$');
const usernameMinLength = 3;
const usernameMaxLength = 16;
const passwordMinLength = 4;
const passwordMaxLength = 64;

isValidUsername(String username) =>
    usernameRegex.hasMatch(username) && username.length >= usernameMinLength && username.length <= usernameMaxLength;
