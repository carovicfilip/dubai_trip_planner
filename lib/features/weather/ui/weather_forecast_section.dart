import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';

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
                  const Expanded(
                    child: Text(
                      'The forecast is unavailable right now.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton(onPressed: _retry, child: const Text('Try again')),
                ],
              );
            }

            return SizedBox(
              // Tall enough for the extra line of a day with rain.
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  final formattedDate = DateFormat('d MMMM').format(day.date);

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                       color:   Colors.white,

                       // Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(formattedDate, style: const TextStyle(color:  Colors.black54)),
                        const SizedBox(height: 8),
                        Text(
                          day.emoji,
                          style: TextStyle(fontSize: 30),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text("${day.minTemp.toInt()}°C | ${day.maxTemp.toInt()}°C", style: const TextStyle(color: Colors.black54),),
                        if (day.rainProbability > 0)
                          Text("${day.rainProbability.toInt()}%", style: const TextStyle(color:  Colors.black54)),
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
