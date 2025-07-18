import 'package:flutter/material.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/widgets/atoms/intro_logo.dart';
import 'package:meetclic/shared/themes/app_spacing.dart';
import 'package:meetclic/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic/domain/models/user_login.dart';
Future<void> showLoginModal(
    BuildContext context,
    Map<String, LoginActionCallback> actions,
    ) {
  final onTapLogin = actions['login'];

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => LoginModalContent(
      onTapLogin: onTapLogin!,
    ),
  );
}
typedef LoginActionCallback = Future<void> Function(UserLoginModel model);
class LoginModalContent extends StatefulWidget {
  final LoginActionCallback onTapLogin;

  const LoginModalContent({required this.onTapLogin, super.key});

  @override
  State<LoginModalContent> createState() => _LoginModalContentState();
}

class _LoginModalContentState extends State<LoginModalContent> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    final passwordValid = password.length >= 6;

    setState(() {
      isButtonEnabled = emailValid && passwordValid;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntroLogo(
              assetPath: 'assets/login/init-login-register.png',
              height: 250,
            ),
            AppSpacing.spaceBetweenInputs,
            Text(
              appLocalizations.translate('loginManagerTitle.hi') +
                  " what: $isButtonEnabled",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.spaceBetweenInputs,
            Text(
              appLocalizations.translate('loginManagerTitle.welcome'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            AppSpacing.spaceBetweenSections,
            InputTextAtom(
              label: appLocalizations.translate('loginManagerTitle.fieldEmail'),
              controller: emailController,
            ),
            AppSpacing.spaceBetweenInputs,
            InputTextAtom(
              label: appLocalizations.translate('loginManagerTitle.fieldPassword'),
              controller: passwordController,
              obscureText: true,
            ),
            AppSpacing.spaceBetweenInputs,
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () async {
                  final model = UserLoginModel(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );
                  await widget.onTapLogin(model);
                  Navigator.pop(context);
                }
                    : null,
                child: Text(appLocalizations.translate('loginManagerTitle.singInButton')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
