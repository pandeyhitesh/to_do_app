import 'package:flutter/material.dart';

Widget emptyListMessage() {
  return Center(
    child: Container(
      height: 300.0,
      child: Column(
        children: [
          SizedBox(
            height: 250.0,
          ),
          Text(
            'Create a ToDo...',
            style: TextStyle(
              fontSize: 20.0,
              letterSpacing: 1.2,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    ),
  );
}
