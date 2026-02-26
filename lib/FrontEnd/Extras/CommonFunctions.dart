import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String capitalizeFirstLetterOfEachWord(String input) {
  List<String> words = input.split(' ');
  List<String> capitalizedWords = words.map((word) {
    if (word.isEmpty) {
      return word; // Return empty string as is
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();
  return capitalizedWords.join(' ');
}

void userNotFound(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFFc61a09),
      elevation: 0,
      content: Text(
        "Some error occurred!",
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.white,
          fontFamily: "Montserrat-SemiBold",
        ),
      ),
    ),
  );
}
