import 'package:flutter/material.dart';
import 'package:reddit/core/constants/constants.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: const Text('Continue with Google'),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
      ),
    );
  }
}
