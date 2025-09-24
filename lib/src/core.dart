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

library;

import 'dart:math';

typedef Seed = int;

/// Unified "example generation context"
class ExampleContext {
  final Random _rand;
  final Seed _seed;
  ExampleContext(Seed seed)
      : _rand = Random(seed),
        _seed = seed;

  bool chance(double p) => _rand.nextDouble() < p;
  int intIn(int min, int max) => min + _rand.nextInt((max - min + 1).clamp(1, 1 << 31));
  double doubleIn(double min, double max) => min + _rand.nextDouble() * (max - min);

  /// Get the current seed value for sub-generators
  int get seed => _seed;
  String letters({int min = 3, int max = 12}) {
    final len = intIn(min, max);
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final b = StringBuffer();
    for (var i = 0; i < len; i++) {
      b.write(chars[_rand.nextInt(chars.length)]);
    }
    return b.toString();
  }

  String digits({int min = 3, int max = 6}) {
    final len = intIn(min, max);
    final b = StringBuffer();
    for (var i = 0; i < len; i++) {
      b.write(_rand.nextInt(10));
    }
    return b.toString();
  }

  String email() => '${letters(min: 3, max: 8)}@${letters(min: 3, max: 6)}.com';

  String uuid() {
    String hex(int n) {
      const chars = '0123456789abcdef';
      return List.generate(n, (_) => chars[intIn(0, 15)]).join();
    }

    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }

  DateTime dateIn(DateTime start, DateTime end) {
    final s = start.millisecondsSinceEpoch;
    final e = end.millisecondsSinceEpoch;
    final t = intIn(min(s, e), max(s, e));
    return DateTime.fromMillisecondsSinceEpoch(t, isUtc: start.isUtc || end.isUtc);
  }
}

/// Runtime type generator interface (for basic types and extensible hooks)
abstract class TypeExample<T> {
  T generate(ExampleContext ctx, {Map<String, Object?>? hints});
}

/// Runtime registry (code generators will call basic type generation)
class ExampleRegistry {
  ExampleRegistry();

  static final instance = ExampleRegistry();

  final Map<Type, TypeExample<dynamic>> _generators = {};

  void register<T>(TypeExample<T> gen) {
    _generators[T] = gen;
  }

  /// Clear all registered generators (mainly for testing)
  void clear() {
    _generators.clear();
  }

  T exampleOf<T>({Seed? seed, Map<String, Object?>? hints}) {
    // Auto-register built-ins if not already registered
    if (_generators.isEmpty) {
      registerBuiltins();
    }

    // Use random seed if none provided
    seed ??= DateTime.now().millisecondsSinceEpoch;

    final gen = _generators[T];
    if (gen == null) {
      throw StateError('No generator registered for type $T');
    }
    return (gen as TypeExample<T>).generate(ExampleContext(seed), hints: hints);
  }
}

/// Basic type default generation
class StringExample extends TypeExample<String> {
  @override
  String generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final min = (hints?['minLen'] as int?) ?? 3;
    final max = (hints?['maxLen'] as int?) ?? 12;
    final pattern = hints?['pattern'] as String?;
    final oneOf = (hints?['oneOf'] as List?)?.cast<String>();
    final email = hints?['email'] == true;

    if (oneOf != null && oneOf.isNotEmpty) {
      return oneOf[ctx.intIn(0, oneOf.length - 1)];
    }
    if (email) return ctx.email();
    if (pattern != null) {
      // Lightweight heuristic
      final p = pattern;
      if (p.contains('@') && p.contains('.')) return ctx.email();
      if (RegExp(r'uuid|guid', caseSensitive: false).hasMatch(p)) {
        // Simple uuid v4
        String hex(int n) {
          const chars = '0123456789abcdef';
          return List.generate(n, (_) => chars[ctx.intIn(0, 15)]).join();
        }

        return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
      }
    }
    return ctx.letters(min: min, max: max);
  }
}

class IntExample extends TypeExample<int> {
  @override
  int generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final min = (hints?['min'] as int?) ?? 0;
    final max = (hints?['max'] as int?) ?? 100;
    return ctx.intIn(min, max);
  }
}

class DoubleExample extends TypeExample<double> {
  @override
  double generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final min = (hints?['min'] as double?) ?? 0.0;
    final max = (hints?['max'] as double?) ?? 1.0;
    return double.parse(ctx.doubleIn(min, max).toStringAsFixed(6));
  }
}

class BoolExample extends TypeExample<bool> {
  @override
  bool generate(ExampleContext ctx, {Map<String, Object?>? hints}) => ctx.chance(0.5);
}

class DateTimeExample extends TypeExample<DateTime> {
  @override
  DateTime generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final start = hints?['start'] as DateTime? ?? DateTime.utc(2000);
    final end = hints?['end'] as DateTime? ?? DateTime.utc(2030);
    return ctx.dateIn(start, end).toUtc();
  }
}

/// Register built-ins
void registerBuiltins() {
  final r = ExampleRegistry.instance;
  r.register<String>(StringExample());
  r.register<String?>(StringExample());
  r.register<int>(IntExample());
  r.register<int?>(IntExample());
  r.register<double>(DoubleExample());
  r.register<double?>(DoubleExample());
  r.register<bool>(BoolExample());
  r.register<bool?>(BoolExample());
  r.register<DateTime>(DateTimeExample());
  r.register<DateTime?>(DateTimeExample());
}

/// Stable hash (for "field path + baseSeed → sub-seed")
int seedFor(String path, int baseSeed) {
  // FNV-1a 32-bit + mix baseSeed
  const int fnvPrime = 0x01000193;
  int hash = 0x811C9DC5 ^ baseSeed;
  for (final c in path.codeUnits) {
    hash ^= c;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  // Convert to signed int
  final signed = hash >= 0x80000000 ? hash - 0x100000000 : hash;
  return signed;
}
