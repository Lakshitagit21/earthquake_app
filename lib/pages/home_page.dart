import 'dart:io';

import 'package:earthquake_app/providers/app_data_provider.dart';
import 'package:earthquake_app/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    Provider.of<AppDataProvider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake App'),
        actions: [
          IconButton(
            onPressed: _showSortingDialog,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => provider.hasDataLoaded
            ? provider.earthquakeModel!.features!.isEmpty
                ? const Center(
                    child: Text('No record found'),
                  )
                : ListView.builder(
                    itemCount: provider.earthquakeModel!.features!.length,
                    itemBuilder: (context, index) {
                      final data = provider
                          .earthquakeModel!.features![index].properties!;
                      final geometry = provider.earthquakeModel!.features![index].geometry!;
                      final coords = geometry.coordinates!;
                      final lat = coords[1].toDouble(); // Latitude
                      final lng = coords[0].toDouble(); // Longitude
                      return ListTile(
                        onTap: (){
                          _openMapWithCoordinates(lat, lng);
                        },
                        title: Text(data.place ?? data.title ?? 'Unknown'),
                        subtitle: Text(getFormattedDateTime(
                            data.time!, 'EEE MMM dd yyyy hh:mm a')),
                        trailing: Chip(
                          avatar: data.alert == null
                              ? null
                              : CircleAvatar(
                                  backgroundColor:
                                      provider.getAlertColor(data.alert!),
                                ),
                          label: Text('${data.mag}'),
                        ),
                      );
                    },
                  )
            : const Center(
                child: Text('Please wait'),
              ),
      ),
    );
  }

  void _showSortingDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sort by'),
              content: Consumer<AppDataProvider>(
                builder: (context, provider, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioGroup(
                      groupValue: provider.orderBy,
                      value: 'magnitude',
                      label: 'Magnitude-Desc',
                      onChange: (value) {
                        provider.setOrder(value!);
                      },
                    ),
                    RadioGroup(
                      groupValue: provider.orderBy,
                      value: 'magnitude-asc',
                      label: 'Magnitude-Asc',
                      onChange: (value) {
                        provider.setOrder(value!);
                      },
                    ),
                    RadioGroup(
                      groupValue: provider.orderBy,
                      value: 'time',
                      label: 'Time-Desc',
                      onChange: (value) {
                        provider.setOrder(value!);
                      },
                    ),
                    RadioGroup(
                      groupValue: provider.orderBy,
                      value: 'time-asc',
                      label: 'Time-Asc',
                      onChange: (value) {
                        provider.setOrder(value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            ));
  }
  void _openMapWithCoordinates(double lat, double lng) async {
    String url = '';
    if (Platform.isAndroid) {
      url = 'geo:$lat,$lng?q=$lat,$lng';
    } else {
      url = 'http://maps.apple.com/?ll=$lat,$lng';
    }

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Could not open map with coordinates');
    }
  }

}

class RadioGroup extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final Function(String?) onChange;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.value,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChange,
        ),
        Text(label)
      ],
    );
  }
}
