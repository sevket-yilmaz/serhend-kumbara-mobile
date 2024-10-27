import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serhend_map/data/datasource/models/placemark.dart';
import 'package:serhend_map/data/datasource/placemark_datasource.dart';
import 'package:serhend_map/data/enums.dart';
import 'package:geolocator/geolocator.dart';
import 'package:label_marker/label_marker.dart';
import 'package:serhend_map/helpers/map_helper.dart';
import 'package:serhend_map/helpers/progress_indicator.dart';

import 'helpers/alert_helper.dart';

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
  var today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getUserLocation().then((value) => fillMarkers());
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return drawProgressIndicator();
    }

    return Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: selectedPlacemark != null ? getBottomAppBar() : null,
      body: GoogleMap(
          mapType: MapType.hybrid,
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
                color: MapPinColor.green.index,
                lastVisit: DateTime.now(),
                status: 1,
                visitPeriod: 30);

            await markerList.addLabelMarker(LabelMarker(
              label: newPlacemarkSelection!.name!,
              textStyle: TextStyle(fontSize: 33, color: Colors.white),
              backgroundColor: getBgColor(
                  today,
                  newPlacemarkSelection!.lastVisit!,
                  newPlacemarkSelection!.visitPeriod!),
              markerId: MarkerId(newPlacemarkSelection!.placemarkID.toString()),
              position: LatLng(newPlacemarkSelection!.latitude ?? 0,
                  newPlacemarkSelection!.longitude ?? 0),
              onTap: () {
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
      await markerList.addLabelMarker(LabelMarker(
        label: placemark.name!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        textStyle: TextStyle(fontSize: 33, color: Colors.black),
        backgroundColor:
            getBgColor(today, placemark.lastVisit!, placemark.visitPeriod!),
        markerId: MarkerId(placemark.placemarkID.toString()),
        position: LatLng(placemark.latitude ?? 0, placemark.longitude ?? 0),
        onTap: () {
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
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      loaded = true;
    });
  }

  BottomAppBar getBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(selectedPlacemark!.name!)],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                  minWidth: 50,
                  onPressed: () {},
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    ],
                  ),
                ),
                MaterialButton(
                  minWidth: 50,
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [buildPopupMenuItem()],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  PopupMenuButton buildPopupMenuItem() {
    return PopupMenuButton(
        itemBuilder: (ctx) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    Text(" Düzenle"),
                  ],
                ),
                onTap: () {
                  showEditForm();
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.black,
                    ),
                    Text(" Sil"),
                  ],
                ),
                onTap: () {
                  deletePlacemark();
                },
              ),
            ]);
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
                        controller: TextEditingController(
                            text: selectedPlacemark!.name),
                        onChanged: (value) => setState(() {
                          selectedPlacemark!.name = value;
                        }),
                      )),
                  field(
                      "Renk",
                      CupertinoSegmentedControl<MapPinColor>(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        groupValue:
                            MapPinColor.values[selectedPlacemark!.color!],
                        onValueChanged: (MapPinColor value) {
                          setState(() {
                            selectedPlacemark!.color = value.index;
                          });
                        },
                        children: const <MapPinColor, Widget>{
                          MapPinColor.green: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text('Yeşil'),
                          ),
                          MapPinColor.yellow: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text('Sarı'),
                          )
                        },
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
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('0'),
                          ),
                          7: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('7'),
                          ),
                          15: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('15'),
                          ),
                          30: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
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
  }
}
