// Copyright 2025 lollipopkit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:test/test.dart';
import 'package:example_gen/src/core.dart';

// Custom type generator for testing
class ColorExample extends TypeExample<String> {
  @override
  String generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final colors = ['red', 'green', 'blue', 'yellow'];
    return colors[ctx.intIn(0, colors.length - 1)];
  }
}

void main() {
  group('ExampleContext Tests', () {
    late ExampleContext ctx;

    setUp(() {
      ctx = ExampleContext(42); // Fixed seed ensures reproducibility
    });

    test('chance() should generate consistent probabilities', () {
      final ctx1 = ExampleContext(123);
      final ctx2 = ExampleContext(123);
      
      // Same seed should produce same result
      expect(ctx1.chance(0.5), equals(ctx2.chance(0.5)));
      expect(ctx1.chance(0.8), equals(ctx2.chance(0.8)));
    });

    test('intIn() should generate integers within range', () {
      for (int i = 0; i < 100; i++) {
        final value = ctx.intIn(10, 20);
        expect(value, greaterThanOrEqualTo(10));
        expect(value, lessThanOrEqualTo(20));
      }
    });

    test('doubleIn() should generate doubles within range', () {
      for (int i = 0; i < 100; i++) {
        final value = ctx.doubleIn(1.5, 3.7);
        expect(value, greaterThanOrEqualTo(1.5));
        expect(value, lessThan(3.7));
      }
    });

    test('letters() should generate strings with correct length', () {
      final short = ctx.letters(min: 3, max: 3);
      expect(short.length, equals(3));
      expect(RegExp(r'^[a-z]+$').hasMatch(short), isTrue);

      final longer = ctx.letters(min: 8, max: 12);
      expect(longer.length, greaterThanOrEqualTo(8));
      expect(longer.length, lessThanOrEqualTo(12));
      expect(RegExp(r'^[a-z]+$').hasMatch(longer), isTrue);
    });

    test('digits() should generate numeric strings', () {
      final digits = ctx.digits(min: 4, max: 6);
      expect(digits.length, greaterThanOrEqualTo(4));
      expect(digits.length, lessThanOrEqualTo(6));
      expect(RegExp(r'^\d+$').hasMatch(digits), isTrue);
    });

    test('email() should generate valid email format', () {
      final email = ctx.email();
      expect(email, contains('@'));
      expect(email, contains('.com'));
      expect(RegExp(r'^[a-z]+@[a-z]+\.com$').hasMatch(email), isTrue);
    });

    test('dateIn() should generate dates within range', () {
      final start = DateTime.utc(2020, 1, 1);
      final end = DateTime.utc(2023, 12, 31);
      
      for (int i = 0; i < 50; i++) {
        final date = ctx.dateIn(start, end);
        expect(date.isAfter(start) || date.isAtSameMomentAs(start), isTrue);
        expect(date.isBefore(end) || date.isAtSameMomentAs(end), isTrue);
      }
    });

    test('dateIn() should handle UTC correctly', () {
      final start = DateTime.utc(2020, 1, 1);
      final end = DateTime.utc(2021, 1, 1);
      final date = ctx.dateIn(start, end);
      expect(date.isUtc, isTrue);
    });

    test('uuid() should generate valid UUID v4 format', () {
      final uuid = ctx.uuid();
      expect(uuid, matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-a[0-9a-f]{3}-[0-9a-f]{12}$'));
      
      // Should be deterministic with same seed
      final ctx2 = ExampleContext(42);
      final uuid2 = ctx2.uuid();
      expect(uuid, equals(uuid2));
    });
  });

  group('ExampleRegistry Tests', () {
    setUp(() {
      // Clear registry and re-register built-in types
      ExampleRegistry.instance.clear();
      registerBuiltins();
    });

    test('should register and retrieve basic types', () {
      expect(() => ExampleRegistry.instance.exampleOf<String>(), returnsNormally);
      expect(() => ExampleRegistry.instance.exampleOf<int>(), returnsNormally);
      expect(() => ExampleRegistry.instance.exampleOf<double>(), returnsNormally);
      expect(() => ExampleRegistry.instance.exampleOf<bool>(), returnsNormally);
      expect(() => ExampleRegistry.instance.exampleOf<DateTime>(), returnsNormally);
    });

    test('should throw for unregistered types', () {
      expect(
        () => ExampleRegistry.instance.exampleOf<List<String>>(),
        throwsA(isA<StateError>())
      );
    });

    test('should generate consistent results with same seed', () {
      final str1 = ExampleRegistry.instance.exampleOf<String>(seed: 100);
      final str2 = ExampleRegistry.instance.exampleOf<String>(seed: 100);
      expect(str1, equals(str2));

      final int1 = ExampleRegistry.instance.exampleOf<int>(seed: 200);
      final int2 = ExampleRegistry.instance.exampleOf<int>(seed: 200);
      expect(int1, equals(int2));
    });
  });

  group('StringExample Tests', () {
    late StringExample generator;
    late ExampleContext ctx;

    setUp(() {
      generator = StringExample();
      ctx = ExampleContext(42);
    });

    test('should respect length hints', () {
      final short = generator.generate(ctx, hints: {'minLen': 5, 'maxLen': 5});
      expect(short.length, equals(5));

      final range = generator.generate(ctx, hints: {'minLen': 8, 'maxLen': 12});
      expect(range.length, greaterThanOrEqualTo(8));
      expect(range.length, lessThanOrEqualTo(12));
    });

    test('should use oneOf when provided', () {
      final candidates = ['apple', 'banana', 'cherry'];
      final result = generator.generate(ctx, hints: {'oneOf': candidates});
      expect(candidates, contains(result));
    });

    test('should generate email when email hint is true', () {
      final email = generator.generate(ctx, hints: {'email': true});
      expect(email, matches(r'^[a-z]+@[a-z]+\.com$'));
    });

    test('should generate UUID when uuid hint is true', () {
      final uuid = generator.generate(ctx, hints: {'uuid': true});
      expect(uuid, matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-a[0-9a-f]{3}-[0-9a-f]{12}$'));
    });

  });

  group('IntExample Tests', () {
    late IntExample generator;
    late ExampleContext ctx;

    setUp(() {
      generator = IntExample();
      ctx = ExampleContext(42);
    });

    test('should respect range hints', () {
      final value = generator.generate(ctx, hints: {'min': 50, 'max': 100});
      expect(value, greaterThanOrEqualTo(50));
      expect(value, lessThanOrEqualTo(100));
    });

    test('should use default range when no hints', () {
      final value = generator.generate(ctx);
      expect(value, greaterThanOrEqualTo(0));
      expect(value, lessThanOrEqualTo(100));
    });
  });

  group('DoubleExample Tests', () {
    late DoubleExample generator;
    late ExampleContext ctx;

    setUp(() {
      generator = DoubleExample();
      ctx = ExampleContext(42);
    });

    test('should respect range hints', () {
      final value = generator.generate(ctx, hints: {'min': 2.5, 'max': 7.8});
      expect(value, greaterThanOrEqualTo(2.5));
      expect(value, lessThan(7.8));
    });

    test('should format to 6 decimal places', () {
      final value = generator.generate(ctx, hints: {'min': 0.0, 'max': 1.0});
      final str = value.toString();
      final decimal = str.split('.')[1];
      expect(decimal.length, lessThanOrEqualTo(6));
    });
  });

  group('BoolExample Tests', () {
    late BoolExample generator;
    late ExampleContext ctx;

    setUp(() {
      generator = BoolExample();
      ctx = ExampleContext(42);
    });

    test('should generate boolean values', () {
      final value = generator.generate(ctx);
      expect(value, isA<bool>());
    });

    test('should be consistent with same context', () {
      final ctx1 = ExampleContext(123);
      final ctx2 = ExampleContext(123);
      expect(generator.generate(ctx1), equals(generator.generate(ctx2)));
    });
  });

  group('DateTimeExample Tests', () {
    late DateTimeExample generator;
    late ExampleContext ctx;

    setUp(() {
      generator = DateTimeExample();
      ctx = ExampleContext(42);
    });

    test('should respect date range hints', () {
      final start = DateTime.utc(2022, 1, 1);
      final end = DateTime.utc(2022, 12, 31);
      final date = generator.generate(ctx, hints: {'start': start, 'end': end});
      
      expect(date.isAfter(start) || date.isAtSameMomentAs(start), isTrue);
      expect(date.isBefore(end) || date.isAtSameMomentAs(end), isTrue);
      expect(date.isUtc, isTrue);
    });

    test('should use default range when no hints', () {
      final date = generator.generate(ctx);
      expect(date.year, greaterThanOrEqualTo(2000));
      expect(date.year, lessThanOrEqualTo(2030));
      expect(date.isUtc, isTrue);
    });
  });

  group('seedFor Function Tests', () {
    test('should generate consistent seeds for same path and baseSeed', () {
      final seed1 = seedFor('user.name', 100);
      final seed2 = seedFor('user.name', 100);
      expect(seed1, equals(seed2));
    });

    test('should generate different seeds for different paths', () {
      final seed1 = seedFor('user.name', 100);
      final seed2 = seedFor('user.age', 100);
      expect(seed1, isNot(equals(seed2)));
    });

    test('should generate different seeds for different base seeds', () {
      final seed1 = seedFor('user.name', 100);
      final seed2 = seedFor('user.name', 200);
      expect(seed1, isNot(equals(seed2)));
    });

    test('should handle empty and special characters in path', () {
      expect(() => seedFor('', 100), returnsNormally);
      expect(() => seedFor('a.b.c.d', 100), returnsNormally);
      expect(() => seedFor('user[0].items[1].name', 100), returnsNormally);
    });
  });

  group('Custom TypeExample Registration Tests', () {
    setUp(() {
      ExampleRegistry.instance.clear();
      registerBuiltins();
    });

    test('should allow custom type registration', () {
      // Register custom generator
      ExampleRegistry.instance.register<String>(ColorExample());
      final color = ExampleRegistry.instance.exampleOf<String>();
      expect(['red', 'green', 'blue', 'yellow'], contains(color));
    });
  });
}
