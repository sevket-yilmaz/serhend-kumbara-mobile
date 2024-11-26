import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:serhend_map/data/constants.dart';
import 'package:serhend_map/data/datasource/models/region.dart';

class RegionDatasource {
  Future<List<RegionModel>> getRegions() async {
    var url = "$API_URL/region";
    List<RegionModel> regionList = [];
    Response response = await Dio().get(url);

    for (var element in response.data["data"]) {
      regionList.add(RegionModel.fromJson(element));
    }

    return regionList;
  }

  Future<bool> delete(int regionID) async {
    Response response =
        await Dio().delete("$API_URL/region", data: "[$regionID]");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<RegionModel> upsert(RegionModel region) async {
    var url = "$API_URL/region";
    var response = await Dio().post(
      url,
      data: jsonEncode(region.toJson()),
    );
    if (response.statusCode != 200) {
      //TODO snacbar
    }
    region =
        RegionModel.fromJson(Map<String, dynamic>.from(response.data));
    return region;
  }
}


