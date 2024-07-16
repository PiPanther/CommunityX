import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:reddit/theme/pallete.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 150,
        width: 150,
        child: LoadingIndicator(
            indicatorType: Indicator.orbit,
            colors: [Pallete.blueColor, Pallete.whiteColor]),
      ),
    );
  }
}
