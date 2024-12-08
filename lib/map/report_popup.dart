import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:serhend_map/region/regions_page.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> reportDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        alignment: Alignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            GestureDetector(
                onTap: () async {
                  await launchUrl((Uri(
                      scheme: 'https',
                      host: 'kumbara-api.nohci.com',
                      path: 'Report')));
                  Navigator.pop(context);
                },
                child: Row(children: [
                  Text(
                    "Kumbara Listesini İndir",
                    style: TextStyle(fontSize: 17),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Icon(
                    Icons.download_for_offline,
                    color: Colors.green,
                    size: 30,
                  )
                ]))
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Kapat'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

getFloatActionButton(BuildContext context) {
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    direction: SpeedDialDirection.down,
    switchLabelPosition: true,
    animatedIconTheme: IconThemeData(size: 22.0),
    curve: Curves.bounceIn,
    overlayColor: Colors.black,
    overlayOpacity: 0.5,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 8.0,
    shape: CircleBorder(),
    children: [
      SpeedDialChild(
        child: Icon(Icons.map_sharp),
        backgroundColor: Colors.blue.shade200,
        label: 'Bölgeler',
        labelStyle: TextStyle(fontSize: 18.0),
        labelBackgroundColor: Colors.blue.shade200,
        onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RegionPage()),
            (Route<dynamic> route) => true),
      ),
      SpeedDialChild(
        child: Icon(Icons.receipt_long_rounded),
        backgroundColor: Colors.green.shade200,
        label: 'Rapor',
        labelStyle: TextStyle(fontSize: 18.0),
        labelBackgroundColor: Colors.green.shade200,
        onTap: () {
          reportDialog(context);
        },
      ),
    ],
  );
}
