English | [简体中文](README_zh.md)

# example_gen

A Dart library for annotation-based example data generation.  
Generate realistic, deterministic example data for your Dart models with flexible constraints and customization options.

## Installation
```bash
dart pub add example_gen
```

## Quick Start

### 0. Define Your Model with Annotations

```dart
import 'package:example_gen/example_gen.dart';

@ExampleModel()
class User {
  @Len(min: 8, max: 12)
  final String id;
  
  @Pattern(r'^[A-Z][a-z]+ [A-Z][a-z]+$')
  final String name;
  
  @Example(value: 'user@example.com') // Fixed value
  final String email;
  
  @Range(min: 18, max: 80)
  final int age;
  
  @Nullable(prob: 0.2) // 20% chance of being null
  final String? bio;
  
  @DateRange(startYear: 2025, endYear: 2025)
  final DateTime createdAt;
  
  @Items(min: 1, max: 5)
  @OneOf(['developer', 'designer', 'manager', 'admin'])
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.bio,
    required this.createdAt,
    required this.roles,
  });
}
```

### 1. Generate the Example Code

```bash
dart run build_runner build
```

### 2. Register Type Generators

```dart
// Register built-in generators
registerBuiltins();

// Register custom generator
ExampleRegistry.instance.register<User>(UserExample());
```

### 3. Generate Examples

```dart
// Generate example with seed for reproducibility
final user = ExampleRegistry.instance.exampleOf<User>(seed: 42);
print(user.name); // Always generates same name for seed 42

// Generate with hints
final email = ExampleRegistry.instance.exampleOf<String>(
  seed: 1,
  hints: {'email': true}
);
print(email); // Generates email-like string
```

## Available Annotations

### Core Annotations

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@ExampleModel()` | Mark class for generation | `@ExampleModel()` |
| `@Example(value: ...)` | Fixed value (highest priority) | `@Example(value: 'fixed')` |

### String Constraints

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@Len(min: 5, max: 10)` | String length | `@Len(min: 5, max: 10)` |
| `@Pattern('regex')` | Regex pattern | `@Pattern(r'\d{3}-\d{4}')` |
| `@OneOf(['a', 'b', 'c'])` | Candidate values | `@OneOf(['red', 'blue', 'green'])` |

### Numeric Constraints

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@Range(min: 0, max: 100)` | Numeric range | `@Range(min: 18, max: 65)` |

### Null Handling

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@Nullable(prob: 0.3)` | Null probability (0-1) | `@Nullable(prob: 0.2)` |

### Collection Constraints

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@Items(min: 1, max: 5)` | Collection size | `@Items(fixed: 3)` |

### Date Constraints

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@DateRange(...)` | DateTime range | `@DateRange(startYear: 2025, endYear: 2025)` |

### Documentation

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@FieldDescription('text')` | Field documentation | `@FieldDescription('User unique identifier')` |

## Advanced Usage

### Custom Type Generators

```dart
class UserExample extends TypeExample<User> {
  @override
  User generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return User(
      id: ctx.letters(min: 8, max: 12),
      name: '${ctx.letters(min: 3, max: 8).capitalize()} ${ctx.letters(min: 4, max: 10).capitalize()}',
      email: ctx.email(),
      age: ctx.intIn(18, 80),
      bio: ctx.chance(0.8) ? ctx.letters(min: 10, max: 50) : null,
      createdAt: ctx.dateIn(DateTime(2020), DateTime.now()),
      roles: List.generate(
        ctx.intIn(1, 3),
        (_) => ['developer', 'designer', 'manager'][ctx.intIn(0, 2)],
      ),
    );
  }
}
```

### ExampleContext Utilities

The `ExampleContext` provides various utility methods:

```dart
final ctx = ExampleContext(seed: 42);

// String generation
ctx.letters(min: 5, max: 10);     // Random letters
ctx.digits(min: 3, max: 6);       // Random digits
ctx.email();                      // Email-like string

// Numeric generation
ctx.intIn(1, 100);               // Random integer
ctx.doubleIn(0.0, 10.0);         // Random double

// Boolean generation
ctx.chance(0.7);                 // 70% probability true

// Date generation
ctx.dateIn(start, end);          // Random date in range
```

### Field Path Seeding

For deterministic field-level generation:

```dart
final baseSeed = 1000;
final fieldSeed = seedFor("user.profile.name", baseSeed);
final ctx = ExampleContext(fieldSeed);
final name = ctx.letters(min: 5, max: 15);
```

## Built-in Type Support

The library includes generators for:

- **String**: With email/UUID detection, length constraints, patterns
- **int**: With range constraints
- **double**: With range constraints  
- **bool**: Random boolean values
- **DateTime**: With date range constraints

## Example Output

```dart
// Basic types
String: "kdmfhsldk"
Email string: "user@example.com"
UUID string: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
Integer: 42
Range integer: 156
Double: 7.23
Boolean: true
DateTime: 2023-05-15 14:30:22.000Z

// Custom User example
User 1:
  ID: abcdef12
  Name: John Smith
  Email: john.smith@example.com
  Age: 28
  Status: Active
  Created at: 2022-03-15 10:22:33.000Z
  Tags: developer, admin
  Profile:
    Bio: Software engineer with 5 years experience.
    Avatar: https://avatar.example.com/john_smith.jpg
    Settings: {theme: dark, notifications: true, language: en}
```

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.