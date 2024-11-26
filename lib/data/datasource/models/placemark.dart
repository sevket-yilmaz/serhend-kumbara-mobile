class PlacemarkModel {
  int? placemarkID;
  String? name;
  double? latitude;
  double? longitude;
  int? status;
  DateTime? lastVisit;
  int? visitPeriod;
  int? regionID;

  PlacemarkModel({
    this.placemarkID,
    this.name,
    this.latitude,
    this.longitude,
    this.status,
    this.lastVisit,
    this.visitPeriod,
    this.regionID,
  });

  factory PlacemarkModel.fromJson(Map<String, dynamic> json) => PlacemarkModel(
        placemarkID: json["placemarkID"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        status: json["status"],
        lastVisit: DateTime.parse(json["lastVisit"]),
        visitPeriod: json["visitPeriod"],
        regionID: json["regionID"],
      );

  Map<String, dynamic> toJson() => {
        "placemarkID": placemarkID,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "status": status,
        "lastVisit": lastVisit!.toIso8601String().split('T').first,
        "visitPeriod": visitPeriod,
        "regionID": regionID,
      };
}
