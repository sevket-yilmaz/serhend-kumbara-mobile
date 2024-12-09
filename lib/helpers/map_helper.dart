import 'package:google_maps_flutter/google_maps_flutter.dart';

BitmapDescriptor getIconColor(
    DateTime today, DateTime lastVisitDate, int visitPeriod) {
  if (today.isBefore(lastVisitDate.add(Duration(days: visitPeriod)))) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }
  return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
}
