import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/sign_in_button.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              Constants.logoPath,
              height: 45,
            ),
            const SizedBox(width: 10),
            const Text(
              'CommunityX',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
      body: isLoading
          ? const Loader()
          : Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      colors: [Colors.grey.shade100, Colors.white])),
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Connect Engage Inspire',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      Constants.loginEmotePath,
                      height: 420,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SignInButton(),
                ],
              ),
            ),
    );
  }
}
