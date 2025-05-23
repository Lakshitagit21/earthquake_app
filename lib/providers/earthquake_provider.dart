import 'package:earthquake_app/repositories/weather_repostory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/query_params.dart';
import '../utils/helper_functions.dart';

enum OrderFilter {
  magnitude,
  magnitudeAsc,
  time,
  timeAsc,
}

const orderFilterValues = {
  OrderFilter.magnitude: 'magnitude',
  OrderFilter.magnitudeAsc: 'magnitude-asc',
  OrderFilter.time: 'time',
  OrderFilter.timeAsc: 'time-asc',
};

final orderFilterProvider = StateProvider((ref) => OrderFilter.time);

final cityProvider = StateProvider<String?>((ref) => null);

final shouldUseLocationProvider = StateProvider((ref) => false);
final shouldShowLoadingBarProvider = StateProvider((ref) => false);

final weatherRepoProvider = Provider((ref) => WeatherRepository());

final queryParamsProvider =
    NotifierProvider<QueryParamsProvider, QueryParams>(QueryParamsProvider.new);

final weatherProvider = FutureProvider((ref) {
  final repo = ref.watch(weatherRepoProvider);
  final params = ref.watch(queryParamsProvider);
  return repo.getEarthquakeData(params);

});

class QueryParamsProvider extends Notifier<QueryParams> {
  @override
  QueryParams build() {
    final order = orderFilterValues[ref.watch(orderFilterProvider)]!;
    final startTime = getFormattedDateTime(DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch);
    final endTime = getFormattedDateTime(DateTime.now().millisecondsSinceEpoch);

    return QueryParams(
        starttime: startTime,
        endtime: endTime,
        minmagnitude: '4.0',
        orderby: order,
        limit: '500',
        maxradiuskm: '20001.6',
        latitude: '0.0',
        longitude: '0.0');
  }

  void setStartTime(String date) {
    state = state.copyWith(starttime: date);
  }

  void setEndTime(String date) {
    state = state.copyWith(endtime: date);
  }

  Future<void> setLocation(bool value) async {
    ref.read(shouldUseLocationProvider.notifier).state = value;
    if (value) {
      ref.read(shouldShowLoadingBarProvider.notifier).state = true;
      final position = await determinePosition();
      final latitude = position.latitude;
      final longitude = position.longitude;

      ref.read(cityProvider.notifier).state =
          await getCurrentCity(latitude, longitude);
      ref.read(shouldShowLoadingBarProvider.notifier).state = false;
      state = state.copyWith(
          maxradiuskm: '500', latitude: '$latitude', longitude: '$longitude');
    } else {
      state = state.copyWith(
          maxradiuskm: '20001.6', longitude: '0.0', latitude: '0.0');
      ref.read(cityProvider.notifier).state = null;
    }
  }
}
