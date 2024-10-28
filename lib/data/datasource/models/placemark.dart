class PlacemarkModel {
  int? placemarkID;
  String? name;
  double? latitude;
  double? longitude;
  int? status;
  DateTime? lastVisit;
  int? visitPeriod;

  PlacemarkModel({
    this.placemarkID,
    this.name,
    this.latitude,
    this.longitude,
    this.status,
    this.lastVisit,
    this.visitPeriod,
  });

  factory PlacemarkModel.fromJson(Map<String, dynamic> json) => PlacemarkModel(
        placemarkID: json["placemarkID"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        status: json["status"],
        lastVisit: DateTime.parse(json["lastVisit"]),
        visitPeriod: json["visitPeriod"],
      );

  Map<String, dynamic> toJson() => {
        "placemarkID": placemarkID,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "status": status,
        "lastVisit": lastVisit!.toIso8601String().split('T').first,
        "visitPeriod": visitPeriod,
      };
}
