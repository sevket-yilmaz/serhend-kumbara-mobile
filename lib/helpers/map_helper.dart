import 'package:google_maps_flutter/google_maps_flutter.dart';

BitmapDescriptor getIconColor(
    DateTime today, DateTime lastVisitDate, int visitPeriod, bool isAuthorized) {
  if (today.isBefore(lastVisitDate.add(Duration(days: visitPeriod)))) {
    return isAuthorized
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }
  return  isAuthorized
      ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
      : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
}
