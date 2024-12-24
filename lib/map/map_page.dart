import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serhend_map/data/datasource/models/placemark.dart';
import 'package:serhend_map/data/datasource/models/region.dart';
import 'package:serhend_map/data/datasource/placemark_datasource.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serhend_map/data/datasource/region_datasource.dart';
import 'package:serhend_map/helpers/map_helper.dart';
import 'package:serhend_map/helpers/progress_indicator.dart';
import 'package:serhend_map/map/bottom_sheet_button.dart';
import 'package:serhend_map/map/report_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../helpers/alert_helper.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController;
  late Position? _currentPosition;
  bool loaded = false;

  LatLng? _center;
  final formKey = GlobalKey<FormState>();
  Set<Marker> markerList = {};
  PlacemarkModel? selectedPlacemark;
  PlacemarkModel? newPlacemarkSelection;
  List<RegionModel> regions = List.empty();
  var today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getUserLocation().then((value) => fillMarkers()).then((value) async {
      RegionDatasource regionDT = RegionDatasource();
      regions = await regionDT.getRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return drawProgressIndicator();
    }

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: getFloatActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: GoogleMap(
          mapType: MapType.normal,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          trafficEnabled: false,
          indoorViewEnabled: true,
          compassEnabled: true,
          buildingsEnabled: true,
          rotateGesturesEnabled: true,
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          onTap: (argument) {
            setState(() {
              selectedPlacemark = null;
            });
          },
          onLongPress: (argument) async {
            newPlacemarkSelection = PlacemarkModel(
                placemarkID: 0,
                name: "YENİ KONUM",
                latitude: argument.latitude,
                longitude: argument.longitude,
                lastVisit: DateTime.now(),
                status: 1,
                visitPeriod: 30);

            markerList.add(Marker(
              markerId: MarkerId(newPlacemarkSelection!.placemarkID.toString()),
              position: LatLng(newPlacemarkSelection!.latitude ?? 0,
                  newPlacemarkSelection!.longitude ?? 0),
              onTap: () {
                showModal();
                setState(() {
                  selectedPlacemark = newPlacemarkSelection;
                });
              },
            ));
            setState(() {
              selectedPlacemark = newPlacemarkSelection;
            });
          },
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center!,
            zoom: 17.0,
          ),
          markers: markerList),
    );
  }

  Future<void> fillMarkers() async {
    var apiPlaceProvider = PlacemarkDatasource();
    var placemarks = await apiPlaceProvider.getPlacemarks();
    for (var placemark in placemarks) {
      markerList.add(Marker(
        icon: getIconColor(today, placemark.lastVisit!, placemark.visitPeriod!),
        markerId: MarkerId(placemark.placemarkID.toString()),
        position: LatLng(placemark.latitude ?? 0, placemark.longitude ?? 0),
        onTap: () {
          showModal();
          setState(() {
            selectedPlacemark = placemark;
          });
        },
      ));
    }
    setState(() {});
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    //Android 6 da forceAndroidLocationManager vermeyince çalışmıyor
    var deviceInfo = DeviceInfoPlugin();
    var info = await deviceInfo.androidInfo;
    if (int.parse(info.version.release) > 6) {
      _currentPosition = await Geolocator.getCurrentPosition();
    } else {
      _currentPosition = await Geolocator.getCurrentPosition(
          forceAndroidLocationManager: true);
    }

    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      loaded = true;
    });
  }

  void showModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      width: 1,
                      color: Colors.black.withAlpha(30),
                    ))),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedPlacemark!.name!,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BottomSheetButton(
                              icon: const Icon(Icons.edit, size: 20),
                              text: const Text("Düzenle"),
                              color: Colors.indigo,
                              isMin: true,
                              onPressed: () {
                                showEditForm();
                              },
                            ),
                            BottomSheetButton(
                              icon: const Icon(Icons.delete_forever, size: 20),
                              text: const Text("Sil"),
                              color: Colors.red,
                              isMin: true,
                              onPressed: () {
                                deletePlacemark();
                              },
                            ),
                            const VerticalDivider(),
                            BottomSheetButton(
                              icon: const Icon(
                                Icons.check_box,
                                size: 27,
                                color: Colors.green,
                              ),
                              text: const Text("Ziyaret Edildi"),
                              color: Colors.green,
                              isMin: false,
                              onPressed: () async {
                                await updateLastVisitPlacemark();
                              },
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      selectedPlacemark = null;
      setState(() {});
    });
  }

  deletePlacemark() async {
    Widget cancelButton = TextButton(
      child: const Text("İptal"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    var placemarkDT = PlacemarkDatasource();
    Widget continueButton = TextButton(
      child: const Text("Sil"),
      onPressed: () async {
        await placemarkDT.delete(selectedPlacemark!.placemarkID!);
        setState(() {
          markerList.remove(markerList
              .where((element) =>
                  element.markerId.value ==
                  selectedPlacemark!.placemarkID!.toString())
              .first);
          selectedPlacemark = null;
        });
        showSnackbar(context, "Konum silindi.");
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      content: const Text("Bu konumu silmek istediğinize emin misiniz?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showEditForm() {
    Widget field(String title, Widget field) {
      return Column(
        children: [
          InputDecorator(
            decoration: InputDecoration(
                labelText: title,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow))),
            child: field,
          ),
          SizedBox(height: 20.0),
        ],
      );
    }

    var dialog = StatefulBuilder(builder: (context, setState) {
      return Dialog(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(children: [
                  field(
                      "İsim",
                      TextFormField(
                        initialValue: selectedPlacemark!.name,
                        onChanged: (value) => setState(() {
                          selectedPlacemark!.name = value;
                        }),
                      )),
                  field(
                      "Bölge",
                      DropdownButton<RegionModel>(
                        value: selectedPlacemark!.regionID != null
                            ? regions.firstWhere((element) {
                                return element.regionID ==
                                    selectedPlacemark!.regionID;
                              })
                            : regions.first,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (RegionModel? value) {
                          setState(() {
                            selectedPlacemark!.regionID = value!.regionID;
                          });
                        },
                        items: regions.map<DropdownMenuItem<RegionModel>>(
                            (RegionModel value) {
                          return DropdownMenuItem<RegionModel>(
                            value: value,
                            child: Text(value.name!),
                          );
                        }).toList(),
                      )),
                  field(
                      "Ziyaret Aralığı (gün)",
                      CupertinoSegmentedControl<int>(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        groupValue: selectedPlacemark!.visitPeriod!,
                        onValueChanged: (int value) {
                          setState(() {
                            selectedPlacemark!.visitPeriod = value;
                          });
                        },
                        children: const <int, Widget>{
                          0: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('0'),
                          ),
                          7: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('7'),
                          ),
                          15: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('15'),
                          ),
                          30: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('30'),
                          ),
                        },
                      )),
                  ElevatedButton(
                    onPressed: () async {
                      savePlacemark();
                    },
                    child: const Text('Kaydet'),
                  ),
                ]),
              )),
        ),
      );
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  savePlacemark() async {
    var placemarkDT = PlacemarkDatasource();
    await placemarkDT.upsert(selectedPlacemark!);
    setState(() {
      markerList = {};
      fillMarkers();
      selectedPlacemark = null;
    });
    showSnackbar(context, "Konum kaydedildi.");
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  updateLastVisitPlacemark() async {
    var placemarkDT = PlacemarkDatasource();
    selectedPlacemark!.lastVisit = DateTime.now();
    await placemarkDT.upsert(selectedPlacemark!);
    setState(() {
      markerList = {};
      fillMarkers();
      selectedPlacemark = null;
    });
    showSnackbar(context, "Ziyaret tarihi güncellendi.");
    Navigator.of(context).pop();
  }
}
