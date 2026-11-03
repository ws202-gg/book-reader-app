import 'package:otp/otp.dart';

String generateTotp(String secret, {DateTime? at}) {
  final time = at ?? DateTime.now();
  return OTP.generateTOTPCodeString(
    secret,
    time.millisecondsSinceEpoch,
    length: 6,
    interval: 30,
    algorithm: Algorithm.SHA1,
    isGoogle: true,
  );
}

bool verifyTotp(String secret, String input, {DateTime? at}) {
  if (input.length != 6 || int.tryParse(input) == null) return false;
  final time = at ?? DateTime.now();
  for (final drift in [-1, 0, 1]) {
    if (generateTotp(secret, at: time.add(Duration(seconds: drift * 30))) ==
        input) {
      return true;
    }
  }
  return false;
}

String authenticatorUri(String secret, String email) {
  const issuer = 'Nom Unsh';
  final label = Uri.encodeComponent('$issuer:$email');
  return 'otpauth://totp/$label?secret=$secret&issuer=${Uri.encodeComponent(issuer)}&algorithm=SHA1&digits=6&period=30';
}
