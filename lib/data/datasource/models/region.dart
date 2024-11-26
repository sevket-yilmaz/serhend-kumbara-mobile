class RegionModel {
  int? regionID;
  String? name;

  RegionModel({
    this.regionID,
    this.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
        regionID: json["regionID"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "regionID": regionID,
        "name": name,
      };
}
