import 'package:flutter_test/flutter_test.dart';
import 'package:book_reader_app/services/totp_service.dart';

void main() {
  const secret = 'JBSWY3DPEHPK3PXP';
  final instant = DateTime.utc(2026, 1, 12, 9, 30, 0);

  test('accepts the code generated for the current time step', () {
    final code = generateTotp(secret, at: instant);

    expect(code, hasLength(6));
    expect(verifyTotp(secret, code, at: instant), isTrue);
  });

  test('accepts a code during the adjacent time window', () {
    final code = generateTotp(secret, at: instant);

    expect(
      verifyTotp(secret, code, at: instant.add(const Duration(seconds: 30))),
      isTrue,
    );
  });

  test('rejects malformed and incorrect codes', () {
    expect(verifyTotp(secret, '12a456', at: instant), isFalse);
    expect(verifyTotp(secret, '123', at: instant), isFalse);
    expect(verifyTotp(secret, '000000', at: instant), isFalse);
  });
}
