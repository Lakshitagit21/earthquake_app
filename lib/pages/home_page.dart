import 'dart:io';

import 'package:earthquake_app/providers/app_data_provider.dart';
import 'package:earthquake_app/providers/earthquake_provider.dart';
import 'package:earthquake_app/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Earthquake App'),
          actions: [
            IconButton(
              onPressed: _showSortingDialog,
              icon: const Icon(Icons.sort),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage())),
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: weather.when(
            data: (model) => ListView.builder(
                  itemCount: model.features!.length,
                  itemBuilder: (context, index) {
                    final data = model.features![index].properties!;
                    return ListTile(
                      title: Text(data.place ?? data.title ?? 'Unknown'),
                      subtitle: Text(getFormattedDateTime(
                          data.time!, 'EEE MMM dd yyyy hh:mm a')),
                      trailing: Chip(
                        avatar: data.alert == null
                            ? null
                            : CircleAvatar(
                                backgroundColor: getAlertColor(data.alert!),
                              ),
                        label: Text('${data.mag}'),
                      ),
                    );
                  },
                ),
            error: (e, trace) => Center(
                  child: Text('Error : ${e.toString()}'),
                ),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }

  void _showSortingDialog() {
    showDialog(
        context: context,
        builder: (context) {
          final groupValue =orderFilterValues[ref.read(orderFilterProvider)]!;
          return AlertDialog(
            title: const Text('Sort by'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup(
                    groupValue: groupValue,
                    value: 'magnitude',
                    label: 'Magnitude-Desc',
                    onChange: (value) {
                     Navigator.pop(context);
                     ref.read(orderFilterProvider.notifier).update((state)=> state = OrderFilter.magnitude);
                    },
                  ),
                  RadioGroup(
                    groupValue: groupValue,
                    value: 'magnitude-asc',
                    label: 'Magnitude-Asc',
                    onChange: (value) {
                      Navigator.pop(context);
                      ref.read(orderFilterProvider.notifier).update((state)=> state = OrderFilter.magnitudeAsc);
                    },
                  ),
                  RadioGroup(
                    groupValue:groupValue,
                    value: 'time',
                    label: 'Time-Desc',
                    onChange: (value) {
                      Navigator.pop(context);
                      ref.read(orderFilterProvider.notifier).update((state)=> state = OrderFilter.time);
                    },
                  ),
                  RadioGroup(
                    groupValue: groupValue,
                    value: 'time-asc',
                    label: 'Time-Asc',
                    onChange: (value) {
                      Navigator.pop(context);
                      ref.read(orderFilterProvider.notifier).update((state)=> state = OrderFilter.timeAsc);
                    },
                  ),
                ],
              ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            ],
          );
        });
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
