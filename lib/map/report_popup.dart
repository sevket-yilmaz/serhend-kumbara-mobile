import 'package:flutter/material.dart';
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
