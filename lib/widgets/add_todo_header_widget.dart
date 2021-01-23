import 'package:flutter/material.dart';

import '../constants.dart';

Widget addToDoHeader() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 15.0),
    child: Center(
      child: Text(
        'Add New ToDo',
        style: addToDoHeadingTextStyle,
      ),
    ),
  );
}
