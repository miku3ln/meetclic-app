import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void showLoginModal(
    BuildContext context,
    VoidCallback onTapGoogle,
    VoidCallback onTapFacebook,
    VoidCallback onTapLogin,
    VoidCallback onTapSignUp,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/login/init-login-register.png',
                height: 200,
              ),
              const SizedBox(height: 24),
              const Text(
                'Hello',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome To Little Drop, where\nyou manage your daily tasks',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Botón LOGIN -> onTapLogin
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: onTapLogin,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C4DB1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón SIGN UP -> onTapSignUp
              SizedBox(
                width: double.infinity,
                height: 70,
                child: OutlinedButton(
                  onPressed: onTapSignUp,
                  child: const Text('Sign Up'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: const BorderSide(color: Color(0xFF5C4DB1)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Sign up using',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Íconos sociales
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIcon(FontAwesomeIcons.google, onTap: onTapGoogle),
                  const SizedBox(width: 16),
                  SocialIcon(FontAwesomeIcons.facebookF, onTap: onTapFacebook),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const SocialIcon(this.icon, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFE0E0E0),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}

class StartButtonWidget extends StatelessWidget {
  const StartButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          showLoginModal(
            context,
                () {
              print('Google icon tapped!');
            },
                () {
              print('Facebook icon tapped!');
            },
                () {
              print('Login button tapped!');
            },
                () {
              print('Sign Up button tapped!');
            },
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.circle, size: 90, color: Colors.black26),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star, color: theme.colorScheme.onPrimary, size: 40),
            ),
            Positioned(
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('START', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
