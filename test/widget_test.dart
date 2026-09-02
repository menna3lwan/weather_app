import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('loads and searches for a city', (tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Alexandria'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Cairo');
    await tester.tap(find.byTooltip('Search'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Cairo'), findsOneWidget);
  });

  testWidgets('shows a friendly message for unknown city', (tester) async {
    await tester.pumpWidget(const WeatherApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField), 'Atlantis');
    await tester.tap(find.byTooltip('Search'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Could not load weather'), findsOneWidget);
    expect(find.textContaining('could not find that city'), findsOneWidget);
  });

  test('repository reports offline and empty states', () async {
    final repository = WeatherRepository();
    expect(
      repository.fetchWeather('offline'),
      throwsA(isA<WeatherException>()),
    );
    expect(repository.fetchWeather(''), throwsA(isA<WeatherException>()));
  });
}
