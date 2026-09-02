import 'package:flutter/material.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/domain/weather.dart';
import 'package:weather_app/presentation/weather_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({required this.repository, super.key});
  final WeatherRepository repository;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final WeatherController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(widget.repository)..search('Alexandria');
    _searchController = TextEditingController(text: 'Alexandria');
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Skyline Weather'),
      actions: [
        IconButton(
          tooltip: 'Refresh weather',
          onPressed: () => _controller.search(_searchController.text),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _controller.search(_searchController.text),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SearchBar(
                      controller: _searchController,
                      onSearch: () =>
                          _controller.search(_searchController.text),
                    ),
                    const SizedBox(height: 24),
                    _buildContent(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildContent(BuildContext context) {
    switch (_controller.status) {
      case WeatherStatus.empty:
        return const _MessageState(
          icon: Icons.location_city_rounded,
          title: 'Find your weather',
          message: 'Search for a city to see the latest conditions.',
        );
      case WeatherStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: CircularProgressIndicator(),
          ),
        );
      case WeatherStatus.error:
        return _MessageState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load weather',
          message: _controller.errorMessage ?? 'Please try again.',
          action: OutlinedButton.icon(
            onPressed: () => _controller.search(_searchController.text),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        );
      case WeatherStatus.success:
        return _WeatherContent(weather: _controller.weather!);
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});
  final TextEditingController controller;
  final VoidCallback onSearch;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    textInputAction: TextInputAction.search,
    onSubmitted: (_) => onSearch(),
    decoration: InputDecoration(
      hintText: 'Search a city',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: IconButton(
        tooltip: 'Search',
        onPressed: onSearch,
        icon: const Icon(Icons.arrow_forward_rounded),
      ),
    ),
  );
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});
  final Weather weather;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weather.city,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '${weather.country}  •  Updated ${_formatTime(weather.updatedAt)}',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 0,
          color: const Color(0xffd9f3f0),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Icon(
                  _iconFor(weather.icon),
                  size: 64,
                  color: const Color(0xff0b7285),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature}°',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  'H ${weather.high}°\nL ${weather.low}°',
                  style: theme.textTheme.titleMedium?.copyWith(height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Today',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${weather.humidity}%',
            ),
            _Metric(
              icon: Icons.air_rounded,
              label: 'Wind',
              value: '${weather.windSpeed} km/h',
            ),
            _Metric(
              icon: Icons.speed_rounded,
              label: 'Pressure',
              value: '${weather.pressure} hPa',
            ),
            _Metric(
              icon: Icons.visibility_outlined,
              label: 'Visibility',
              value: '${weather.visibility} km',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '5-day forecast',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weather.forecast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _ForecastCard(day: weather.forecast[index]),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 50) / 2,
    child: Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff0b7285)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.day});
  final ForecastDay day;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112,
    child: Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(day.day, style: const TextStyle(fontWeight: FontWeight.bold)),
            Icon(_iconFor(day.icon), color: const Color(0xff0b7285), size: 30),
            Text('${day.high}° / ${day.low}°'),
            Text(
              day.condition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(icon, size: 58, color: const Color(0xff0b7285)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    ),
  );
}

IconData _iconFor(WeatherIcon icon) {
  switch (icon) {
    case WeatherIcon.sunny:
      return Icons.wb_sunny_rounded;
    case WeatherIcon.partlyCloudy:
      return Icons.wb_cloudy_rounded;
    case WeatherIcon.rainy:
      return Icons.grain_rounded;
    case WeatherIcon.stormy:
      return Icons.thunderstorm_rounded;
  }
}

String _formatTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
