import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';

/// The outline icon for an OpenWeatherMap icon code such as "01d".
IconData weatherIcon(String code) {
  if (code.contains('01')) return Icons.wb_sunny_outlined;
  if (code.contains('02') || code.contains('03')) return Icons.filter_drama_outlined;
  if (code.contains('09') || code.contains('10')) return Icons.water_drop_outlined;
  if (code.contains('11')) return Icons.thunderstorm_outlined;
  if (code.contains('13')) return Icons.ac_unit_outlined;
  if (code.contains('50')) return Icons.foggy;
  return Icons.cloud_outlined;
}

class WeatherForecastSection extends StatefulWidget {
  const WeatherForecastSection({super.key});

  @override
  State<WeatherForecastSection> createState() => _WeatherForecastSectionState();
}

class _WeatherForecastSectionState extends State<WeatherForecastSection> {
  final _service = WeatherForecastService();
  late Future<List<DailyForecast>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = _service.fetch10DayForecast();
  }

  void _retry() {
    setState(() {
      _forecastFuture = _service.fetch10DayForecast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Weather Forecast", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        FutureBuilder<List<DailyForecast>>(
          future: _forecastFuture,
          // The forecast from the previous visit to this tab, shown right away.
          initialData: _service.lastKnownForecast,
          builder: (context, snapshot) {
            final forecast = snapshot.data;
            if (forecast == null || forecast.isEmpty) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'The forecast is unavailable right now.',
                      style: TextStyle(color: palette.muted),
                    ),
                  ),
                  TextButton(onPressed: _retry, child: const Text('Try again')),
                ],
              );
            }

            return SizedBox(
              // Tall enough for the extra line of a day with rain.
              height: 144,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  final formattedDate = DateFormat('d MMMM').format(day.date);

                  return GlassCard(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(2),
                    radius: 26,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(formattedDate, style: TextStyle(color: palette.muted)),
                        const SizedBox(height: 8),
                        Icon(weatherIcon(day.icon), size: 32, color: palette.ink),
                        SizedBox(
                          height: 12,
                        ),
                        Text("${day.minTemp.toInt()}°C | ${day.maxTemp.toInt()}°C", style: TextStyle(color: palette.ink)),
                        if (day.rainProbability > 0)
                          Text("${day.rainProbability.toInt()}%", style: TextStyle(color: palette.muted)),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
