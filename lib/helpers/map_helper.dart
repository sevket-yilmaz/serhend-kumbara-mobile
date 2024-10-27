import 'package:flutter/material.dart';

Color getBgColor(DateTime today, DateTime lastVisitDate, int visitPeriod) {
  if (today.isBefore(lastVisitDate.add(Duration(days: visitPeriod)))) {
    return Colors.green;
  }
  return Colors.yellowAccent;
}
// Color getBgColor(MapPinColor color) {
//   switch (color) {
//     case MapPinColor.yellow:
//       return Colors.yellowAccent;
//     default:
//       return Colors.green;
//   }
// }