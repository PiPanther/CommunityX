import 'package:flutter/material.dart';
import 'package:reddit/features/feeds/screens/feed_screen.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/features/posts/screen/add_post_screen.dart';

class Constants {
  static const logoPath = 'assets/images/logo.png';
  static const googlePath = 'assets/images/google.png';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const pfp =
      'https://i.pinimg.com/236x/bf/f5/d0/bff5d074d399bdfec6071e9168398406.jpg';
  static const banner =
      'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI';

  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
  ];

  static const IconData up = IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down = IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
