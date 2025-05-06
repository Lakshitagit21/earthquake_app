import 'dart:convert';

import 'package:earthquake_app/models/earthquake_model.dart';
import 'package:earthquake_app/models/query_params.dart';
import 'package:http/http.dart' as http;

class WeatherRepository {
  //repository is used to fetch data from data source CRUD methods usually
  final baseUrl = Uri.parse('https://earthquake.usgs.gov/fdsnws/event/1/query');

  Future<EarthquakeModel> getEarthquakeData(QueryParams queryParams) async {
    final uri = Uri.http(baseUrl.authority, baseUrl.path, queryParams.toJson());

    final response = await http.get(uri);

    final json = jsonDecode(response.body);
    return EarthquakeModel.fromJson(json);
  }
}
