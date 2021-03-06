import 'package:flutter/material.dart';

final githubUrl = 'www.github.com/pandeyhitesh/';
final linkedInUrl = 'www.linkedin.com/in/hitesh-pandey-815324192/';
final instaUrl = 'www.instagram.com/i.m._sherlocked/';
final appDownloadUrl = '';

final black = Color(0xff000000);
final yellow = Color(0xfff9c00e);
final grey = Color(0xff2b2b2b);
final white = Color(0xffffffff);

ThemeData theme = ThemeData(
  primaryColor: black,
  buttonColor: yellow,
  cursorColor: yellow,
  // dividerColor: foregroundColor,
  focusColor: black,
  fontFamily: "Raleway",
  accentColor: yellow,
  textTheme: TextTheme(
    subtitle1: TextStyle(color: white),
  ),
  unselectedWidgetColor: black,
  colorScheme: ColorScheme.dark(primary: yellow),
  // accentColor: foregroundColor,
  splashColor: yellow,
);

final addToDoHeadingTextStyle = TextStyle(
  color: black,
  fontSize: 20,
  letterSpacing: 1.5,
  fontWeight: FontWeight.normal,
);

final inputTextStyle = TextStyle(
  color: grey,
  letterSpacing: 1.0,
);

final labelTextStyle = TextStyle(
  color: black,
  letterSpacing: 1.0,
  fontWeight: FontWeight.bold,
);

final hintTextStyle = TextStyle(
  color: grey,
  letterSpacing: 1.0,
);

final normalTextStyle = TextStyle(
  color: grey,
  letterSpacing: 1.0,
);

final dateTextStyle = TextStyle(
  color: black,
  fontSize: 18.0,
  letterSpacing: 1.0,
);

final aboutNameTextStyle = TextStyle(
  color: grey,
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);

final aboutSubtitleTextStyle = TextStyle(
  color: grey,
  fontSize: 12.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.0,
);

final aboutInfoTextStyle = TextStyle(
  color: grey,
  fontSize: 12.0,
  fontWeight: FontWeight.normal,
  decoration: TextDecoration.underline,
  // letterSpacing: ,
);

final logoSize = 40.0;

final border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),
  borderSide: BorderSide(width: 2.0, color: black),
);

final enabledBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),
  borderSide: BorderSide(width: 2.0, color: black),
);

final focusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),
  borderSide: BorderSide(width: 3.0, color: black),
);
