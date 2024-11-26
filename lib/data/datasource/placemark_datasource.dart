import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:flutter/services.dart';
import 'package:serhend_map/data/constants.dart';
import 'package:serhend_map/data/datasource/models/placemark.dart';

class PlacemarkDatasource {
  Future<List<PlacemarkModel>> getPlacemarks() async {
    var url = "$API_URL/placemark";
    List<PlacemarkModel> placemarkList = [];
    Response response = await Dio().get(url);

    for (var element in response.data["data"]) {
      placemarkList.add(PlacemarkModel.fromJson(element));
    }

    return placemarkList;
    // return getElements(placemarkList, 25);
  }

  Future<bool> delete(int placemarkID) async {
    Response response =
        await Dio().delete("$API_URL/placemark", data: "[$placemarkID]");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<PlacemarkModel> upsert(PlacemarkModel placemark) async {
    var url = "$API_URL/placemark";
    var response = await Dio().post(
      url,
      data: jsonEncode(placemark.toJson()),
    );
    if (response.statusCode != 200) {
      //TODO snacbar
    }
    placemark =
        PlacemarkModel.fromJson(Map<String, dynamic>.from(response.data));
    return placemark;
  }

  // Future<List<PlacemarkModel>> getPlacemarksFromJson() async {
  //   final String response =
  //       await rootBundle.loadString('assets/placemark.json');
  //   List<PlacemarkModel> placemarkList = (jsonDecode(response) as List)
  //       .map((data) => PlacemarkModel.fromJson(data))
  //       .toList();

  //   // return placemarkList;
  //   return getElements(placemarkList, 25);
  // }

  // //TODO delete
  // List<PlacemarkModel> getElements(List<PlacemarkModel> userInput, nIndex) {
  //   List<PlacemarkModel> elements = [];
  //   for (int x = 0; x < userInput.length; x++) {
  //     if (x % nIndex == 0) {
  //       elements.add(userInput[x]);
  //     }
  //   }
  //   return elements;
  // }
}


