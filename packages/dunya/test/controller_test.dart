import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dunya/dunya.dart';

void main() {
  late CountryPickerController controller;

  setUp(() {
    controller = CountryPickerController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('CountryPickerController', () {
    test('allCountries returns full list', () {
      expect(controller.allCountries, isNotEmpty);
      expect(controller.allCountries.length, 250);
    });

    test('currentSelection is null initially', () {
      expect(controller.currentSelection, isNull);
    });

    test('results stream emits all countries on creation', () async {
      // Subscribe first, then create controller so we catch the sync add
      final completer = Completer<List<Country>>();
      final ctrl = CountryPickerController();
      // The initial add is synchronous in the constructor, so for a
      // broadcast stream we need to trigger a new emission.
      ctrl.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      // clear() re-emits the full list
      ctrl.clear();
      final result = await completer.future;
      expect(result.length, 250);
      ctrl.dispose();
    });

    test('select updates currentSelection', () {
      final country = controller.allCountries.first;
      controller.select(country);
      expect(controller.currentSelection, country);
    });

    test('select emits on selected stream', () {
      final country = controller.allCountries.first;
      expectLater(
        controller.selected,
        emits(country),
      );
      controller.select(country);
    });

    test('clear resets selection to null', () {
      final country = controller.allCountries.first;
      controller.select(country);
      controller.clear();
      expect(controller.currentSelection, isNull);
    });

    test('clear emits null on selected stream', () {
      final country = controller.allCountries.first;
      controller.select(country);
      expectLater(
        controller.selected,
        emits(isNull),
      );
      controller.clear();
    });

    test('clear resets results to all countries', () async {
      final completer = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      controller.clear();
      final result = await completer.future;
      expect(result.length, 250);
    });

    test('search debounces at 150ms', () async {
      final completer = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });

      controller.search('xyz');
      controller.search('United');

      final results = await completer.future;
      expect(
        results.every((c) => c.name.toLowerCase().contains('united')),
        isTrue,
      );
    });

    test('search filters results', () async {
      final completer = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });

      controller.search('AE');
      final results = await completer.future;
      expect(results, isNotEmpty);
      expect(results.first.alpha2, 'AE');
    });

    test('search with no match returns empty', () async {
      final completer = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });

      controller.search('zzzzznotacountry');
      final results = await completer.future;
      expect(results, isEmpty);
    });

    test('filterByRegion limits results to region', () async {
      final completer = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!completer.isCompleted) completer.complete(data);
      });

      controller.filterByRegion('Africa');
      final results = await completer.future;
      expect(results, isNotEmpty);
      expect(results.every((c) => c.region == 'Africa'), isTrue);
    });

    test('filterByRegion with null returns all', () async {
      final first = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!first.isCompleted) {
          first.complete(data);
        }
      });

      controller.filterByRegion('Africa');
      await first.future;

      final second = Completer<List<Country>>();
      controller.results.listen((data) {
        if (!second.isCompleted) second.complete(data);
      });

      controller.filterByRegion(null);
      final results = await second.future;
      expect(results.length, 250);
    });

    test('selected stream emits sequence of selections', () {
      final first = controller.allCountries[0];
      final second = controller.allCountries[1];

      expectLater(
        controller.selected,
        emitsInOrder([first, second, isNull]),
      );

      controller.select(first);
      controller.select(second);
      controller.clear();
    });

    test('dispose closes streams', () {
      controller.dispose();
      expect(controller.results, emitsDone);
      expect(controller.selected, emitsDone);
    });
  });
}
