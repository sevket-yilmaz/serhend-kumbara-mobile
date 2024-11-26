import 'package:flutter/material.dart';
import 'package:serhend_map/data/datasource/models/region.dart';
import 'package:serhend_map/data/datasource/region_datasource.dart';
import 'package:serhend_map/helpers/alert_helper.dart';
import 'package:serhend_map/helpers/progress_indicator.dart';

class RegionPage extends StatefulWidget {
  const RegionPage({super.key});

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  List<RegionModel> regions = [];
  bool loaded = false;
  final formKey = GlobalKey<FormState>();
  RegionModel selectedRegion = RegionModel(regionID: 0);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return drawProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bölgeler"), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            showForm();
          },
        )
      ]),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: regions.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 0,
                shadowColor: Colors.grey,
                child: ListTile(
                    title: Row(
                  children: [
                    Text(regions[index].name!),
                    const Spacer(),
                    IconButton(
                        onPressed: () async {
                          selectedRegion = regions[index];
                          showForm();
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () async {
                          deleteRegion(regions[index]);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                )),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> loadData() async {
    var regionRepository = RegionDatasource();
    regions = await regionRepository.getRegions();
    loaded = true;
    selectedRegion = RegionModel(regionID: 0);
    setState(() {});
  }

  deleteRegion(RegionModel region) async {
    Widget cancelButton = TextButton(
      child: const Text("İptal"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Sil"),
      onPressed: () async {
        var regionDT = RegionDatasource();
        await regionDT.delete(region.regionID!);
        showSnackbar(context, "Bölge silindi.");
        loadData();
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text(""),
      content: const Text("Bu bölgeyi silmek istediğinize emin misiniz?"),
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

  showForm() {
    var dialog = StatefulBuilder(builder: (context, _setState) {
      return Dialog(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(children: [
                  Column(
                    children: [
                      InputDecorator(
                          decoration: InputDecoration(
                              labelText: "Bölge Adı",
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.yellow))),
                          child: TextFormField(
                              controller: TextEditingController(
                                  text: selectedRegion.name),
                              onChanged: (value) async {
                                selectedRegion.name = value;
                              })),
                      SizedBox(height: 20.0),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      saveRegion();
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

  saveRegion() async {
    var regionDT = RegionDatasource();
    await regionDT.upsert(selectedRegion);
    setState(() {
      loadData();
    });
    showSnackbar(context, "Bölge kaydedildi.");
    Navigator.of(context).pop();
  }
}
