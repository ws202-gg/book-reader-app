import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_theme.dart';
import '../data/reader_store.dart';
import '../services/totp_service.dart';
import '../widgets/reader_widgets.dart';

typedef Authenticated = void Function(BuildContext context);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.store,
    required this.onAuthenticated,
  });

  final ReaderStore store;
  final Authenticated onAuthenticated;

  void _showAuth(BuildContext context, {bool register = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => register
            ? RegisterScreen(store: store, onAuthenticated: onAuthenticated)
            : LoginScreen(store: store, onAuthenticated: onAuthenticated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 168,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFC66C4A), Color(0xFF623D33)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.terracotta.withValues(alpha: .22),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Read. Upload. Share.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Novels, manga and light novels in one reading library.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppPalette.muted, height: 1.45),
                ),
                const SizedBox(height: 34),
                PrimaryButton(
                  label: 'Get started',
                  onPressed: () => _showAuth(context, register: true),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'I already have an account',
                  onPressed: () => _showAuth(context),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: index == 1 ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == 1
                            ? AppPalette.terracotta
                            : AppPalette.terracotta.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Flutter course project · demo authentication',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppPalette.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.store,
    required this.onAuthenticated,
  });

  final ReaderStore store;
  final Authenticated onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email = TextEditingController(
    text: widget.store.email,
  );
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final email = _email.text.trim();
    if (!email.contains('@') || _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid email and a password with 8+ characters.',
          ),
        ),
      );
      return;
    }
    await widget.store.setIdentity(
      name: widget.store.name == 'Reader'
          ? email.split('@').first
          : widget.store.name,
      email: email,
    );
    if (!mounted) return;
    _continueToVerification();
  }

  void _continueToVerification() {
    final Widget destination =
        widget.store.twoFactorEnabled && widget.store.totpSecret != null
        ? TotpChallengeScreen(
            store: widget.store,
            onAuthenticated: widget.onAuthenticated,
          )
        : AuthenticatorSetupScreen(
            store: widget.store,
            onAuthenticated: widget.onAuthenticated,
          );
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) => _AuthLayout(
    title: 'Hello, welcome back!',
    subtitle: 'Sign in to continue reading',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Email',
          hint: 'you@email.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        LabeledField(
          label: 'Password',
          hint: 'At least 8 characters',
          controller: _password,
          obscureText: true,
          prefixIcon: Icons.lock_outline,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ForgotPasswordScreen(store: widget.store),
              ),
            ),
            child: const Text('Forgot your password?'),
          ),
        ),
        PrimaryButton(label: 'Login', onPressed: _continue),
        const SizedBox(height: 22),
        const _OrDivider(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed: () => _socialDemo('reader@gmail.com'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'Apple',
                icon: Icons.apple,
                onPressed: () => _socialDemo('reader@icloud.com'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => RegisterScreen(
                  store: widget.store,
                  onAuthenticated: widget.onAuthenticated,
                ),
              ),
            ),
            child: const Text('New here?  Create an account'),
          ),
        ),
      ],
    ),
  );

  Future<void> _socialDemo(String email) async {
    await widget.store.setIdentity(name: 'Reader', email: email);
    if (mounted) _continueToVerification();
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.store,
    required this.onAuthenticated,
  });

  final ReaderStore store;
  final Authenticated onAuthenticated;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_name.text.trim().isEmpty ||
        !_email.text.contains('@') ||
        _password.text.length < 8 ||
        _password.text != _confirm.text ||
        !_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check your details, password match and terms consent.',
          ),
        ),
      );
      return;
    }
    await widget.store.setIdentity(name: _name.text, email: _email.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AuthenticatorSetupScreen(
          store: widget.store,
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _AuthLayout(
    title: 'Create account',
    subtitle: 'Start your reading library',
    child: Column(
      children: [
        LabeledField(label: 'Full name', controller: _name, hint: 'Your name'),
        LabeledField(
          label: 'Email',
          controller: _email,
          hint: 'you@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        LabeledField(
          label: 'Password',
          controller: _password,
          hint: 'At least 8 characters',
          obscureText: true,
        ),
        LabeledField(
          label: 'Confirm password',
          controller: _confirm,
          hint: 'Repeat password',
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'I like to read',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 7,
          children: [
            CategoryChip(label: 'Novels', selected: true),
            CategoryChip(label: 'Manga'),
            CategoryChip(label: 'Light Novels'),
            CategoryChip(label: 'Webtoons'),
          ],
        ),
        CheckboxListTile(
          value: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I agree to the Terms of Service and Privacy Policy',
          ),
        ),
        const SizedBox(height: 4),
        PrimaryButton(label: 'Create account', onPressed: _createAccount),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => LoginScreen(
                store: widget.store,
                onAuthenticated: widget.onAuthenticated,
              ),
            ),
          ),
          child: const Text('Already have an account? Login'),
        ),
      ],
    ),
  );
}

class AuthenticatorSetupScreen extends StatefulWidget {
  const AuthenticatorSetupScreen({
    super.key,
    required this.store,
    required this.onAuthenticated,
  });

  final ReaderStore store;
  final Authenticated onAuthenticated;

  @override
  State<AuthenticatorSetupScreen> createState() =>
      _AuthenticatorSetupScreenState();
}

class _AuthenticatorSetupScreenState extends State<AuthenticatorSetupScreen> {
  final _code = TextEditingController();
  late final String _secret = widget.store.ensureTotpSecret();
  late final String _uri = authenticatorUri(_secret, widget.store.email);

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verifyAndContinue() async {
    if (!verifyTotp(_secret, _code.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That code did not match. Use the current code in your authenticator.',
          ),
        ),
      );
      return;
    }
    await widget.store.enableTwoFactor();
    if (mounted) widget.onAuthenticated(context);
  }

  @override
  Widget build(BuildContext context) => _AuthLayout(
    title: 'Set up two-step verification',
    subtitle: 'Connect an authenticator app to protect your account',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: QrImageView(data: _uri, size: 172),
          ),
        ),
        const SizedBox(height: 18),
        const Text('1. Scan the QR code with an authenticator app.'),
        const SizedBox(height: 8),
        const Text('2. Enter the current six-digit code to confirm setup.'),
        const SizedBox(height: 14),
        SelectableText(
          'Setup key: $_secret',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        LabeledField(
          label: 'Authenticator code',
          hint: '000000',
          controller: _code,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.shield_outlined,
        ),
        _DemoCodeHint(secret: _secret),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Verify and continue',
          onPressed: _verifyAndContinue,
        ),
        const SizedBox(height: 10),
        Text(
          'Demo project: the app verifies TOTP locally. A production app must verify codes on a protected server.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppPalette.muted, height: 1.4),
        ),
      ],
    ),
  );
}

class TotpChallengeScreen extends StatefulWidget {
  const TotpChallengeScreen({
    super.key,
    required this.store,
    required this.onAuthenticated,
  });

  final ReaderStore store;
  final Authenticated onAuthenticated;

  @override
  State<TotpChallengeScreen> createState() => _TotpChallengeScreenState();
}

class _TotpChallengeScreenState extends State<TotpChallengeScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _attempts = 0;
  DateTime? _lockedUntil;

  String get _secret =>
      widget.store.totpSecret ?? widget.store.ensureTotpSecret();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _verify() {
    final now = DateTime.now();
    if (_lockedUntil != null && now.isBefore(_lockedUntil!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too many attempts. Wait before trying again.'),
        ),
      );
      return;
    }
    if (verifyTotp(_secret, _code.text.trim())) {
      widget.onAuthenticated(context);
      return;
    }
    _attempts++;
    if (_attempts >= 5) {
      _attempts = 0;
      _lockedUntil = now.add(const Duration(seconds: 30));
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid code. Check the authenticator and try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondsLeft = 30 - (DateTime.now().second % 30);
    final remaining = _lockedUntil == null
        ? 0
        : max(0, _lockedUntil!.difference(DateTime.now()).inSeconds);
    return _AuthLayout(
      title: 'Verify it’s you',
      subtitle: 'Enter the six-digit code from your authenticator app',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledField(
            label: 'Authenticator code',
            hint: '000000',
            controller: _code,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.shield_outlined,
          ),
          Text(
            'Code refreshes in $secondsLeft seconds',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppPalette.muted),
          ),
          const SizedBox(height: 10),
          _DemoCodeHint(secret: _secret),
          if (_attempts > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${5 - _attempts} attempts remaining',
                style: const TextStyle(color: AppPalette.terracotta),
              ),
            ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: remaining > 0 ? 'Try again in ${remaining}s' : 'Verify code',
            onPressed: remaining > 0 ? null : _verify,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Back to login',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.store});
  final ReaderStore store;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _sent = false;
  static const _demoRecoveryCode = '4821';

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthLayout(
    title: 'Forgot password?',
    subtitle: 'Enter your email and we will send a reset code.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Email',
          hint: 'you@email.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        if (!_sent)
          PrimaryButton(
            label: 'Send code',
            onPressed: () {
              if (!_email.text.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid email address.')),
                );
                return;
              }
              setState(() => _sent = true);
            },
          )
        else ...[
          LabeledField(
            label: 'Enter 4-digit recovery code',
            controller: _code,
            hint: '0000',
            keyboardType: TextInputType.number,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('A new demo code was sent.')),
              ),
              child: const Text('Didn’t get it? Resend'),
            ),
          ),
          LabeledField(
            label: 'New password',
            controller: _password,
            hint: 'At least 8 characters',
            obscureText: true,
          ),
          PrimaryButton(
            label: 'Reset password',
            onPressed: () {
              if (_code.text.trim() != _demoRecoveryCode ||
                  _password.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Use the demo code and enter an 8+ character password.',
                    ),
                  ),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset complete for this demo.'),
                ),
              );
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Demo recovery code: $_demoRecoveryCode',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppPalette.muted),
            ),
          ),
        ],
      ],
    ),
  );
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton()),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppPalette.muted),
                ),
                const SizedBox(height: 25),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DemoCodeHint extends StatelessWidget {
  const _DemoCodeHint({required this.secret});
  final String secret;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppPalette.terracotta.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.developer_mode, color: AppPalette.terracotta),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Demo code: ${generateTotp(secret)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: 'Copy code',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: generateTotp(secret)));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo code copied.')),
              );
            }
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
        ),
      ],
    ),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'or continue with',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppPalette.muted),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}
