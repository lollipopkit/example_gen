import 'package:example_gen/src/core.dart';

// Example data models
class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final bool isActive;
  final DateTime createdAt;
  final List<String> tags;
  final UserProfile? profile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.isActive,
    required this.createdAt,
    required this.tags,
    this.profile,
  });

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, age: $age, '
        'isActive: $isActive, createdAt: $createdAt, tags: $tags, profile: $profile)';
  }
}

class UserProfile {
  final String bio;
  final String avatarUrl;
  final Map<String, dynamic> settings;

  UserProfile({
    required this.bio,
    required this.avatarUrl,
    required this.settings,
  });

  @override
  String toString() {
    return 'UserProfile(bio: $bio, avatarUrl: $avatarUrl, settings: $settings)';
  }
}

// Custom user generator
class UserExample extends TypeExample<User> {
  @override
  User generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return User(
      id: ctx.letters(min: 8, max: 12), // Generate random ID
      name: '${ctx.letters(min: 3, max: 8).replaceFirst(ctx.letters(min: 3, max: 8)[0], ctx.letters(min: 3, max: 8)[0].toUpperCase())} ${ctx.letters(min: 4, max: 10).replaceFirst(ctx.letters(min: 4, max: 10)[0], ctx.letters(min: 4, max: 10)[0].toUpperCase())}',
      email: ctx.email(),
      age: ctx.intIn(18, 80),
      isActive: ctx.chance(0.8), // 80% probability for active user
      createdAt: ctx.dateIn(
        DateTime.utc(2020, 1, 1),
        DateTime.now().toUtc(),
      ),
      tags: List.generate(
        ctx.intIn(1, 5),
        (_) => ['developer', 'designer', 'manager', 'admin', 'user'][ctx.intIn(0, 4)],
      ),
      profile: ctx.chance(0.7) ? UserProfileExample().generate(ctx) : null, // 70% probability to have profile
    );
  }
}

class UserProfileExample extends TypeExample<UserProfile> {
  @override
  UserProfile generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return UserProfile(
      bio: '${ctx.letters(min: 10, max: 50)} ${ctx.letters(min: 5, max: 20)}.',
      avatarUrl: 'https://avatar.example.com/${ctx.letters(min: 8, max: 16)}.jpg',
      settings: {
        'theme': ['light', 'dark'][ctx.intIn(0, 1)],
        'notifications': ctx.chance(0.8),
        'language': ['en', 'zh', 'ja', 'es'][ctx.intIn(0, 3)],
      },
    );
  }
}

void main() {
  // Register built-in type generators
  registerBuiltins();
  
  // Register custom type generators
  ExampleRegistry.instance.register<User>(UserExample());
  ExampleRegistry.instance.register<UserProfile>(UserProfileExample());

  print('=== Basic Type Examples ===\n');
  
  // Basic type examples
  print('String: ${ExampleRegistry.instance.exampleOf<String>(seed: 1)}');
  print('Email string: ${ExampleRegistry.instance.exampleOf<String>(seed: 2, hints: {'email': true})}');
  print('UUID string: ${ExampleRegistry.instance.exampleOf<String>(seed: 3, hints: {'pattern': 'uuid'})}');
  print('Candidate value string: ${ExampleRegistry.instance.exampleOf<String>(seed: 4, hints: {'oneOf': ['red', 'green', 'blue']})}');
  print('Length-limited string: ${ExampleRegistry.instance.exampleOf<String>(seed: 5, hints: {'minLen': 10, 'maxLen': 15})}');
  print('');
  
  print('Integer: ${ExampleRegistry.instance.exampleOf<int>(seed: 10)}');
  print('Range integer: ${ExampleRegistry.instance.exampleOf<int>(seed: 11, hints: {'min': 100, 'max': 200})}');
  print('');
  
  print('Double: ${ExampleRegistry.instance.exampleOf<double>(seed: 20)}');
  print('Range double: ${ExampleRegistry.instance.exampleOf<double>(seed: 21, hints: {'min': 10.5, 'max': 99.9})}');
  print('');
  
  print('Boolean: ${ExampleRegistry.instance.exampleOf<bool>(seed: 30)}');
  print('');
  
  print('DateTime: ${ExampleRegistry.instance.exampleOf<DateTime>(seed: 40)}');
  print('Range DateTime: ${ExampleRegistry.instance.exampleOf<DateTime>(seed: 41, hints: {
    'start': DateTime.utc(2023, 1, 1),
    'end': DateTime.utc(2023, 12, 31)
  })}');
  print('');

  print('=== Custom Type Examples ===\n');
  
  // Custom type examples
  for (int i = 1; i <= 3; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 100 + i);
    print('User $i:');
    print('  ID: ${user.id}');
    print('  Name: ${user.name}');
    print('  Email: ${user.email}');
    print('  Age: ${user.age}');
    print('  Status: ${user.isActive ? "Active" : "Inactive"}');
    print('  Created at: ${user.createdAt}');
    print('  Tags: ${user.tags.join(", ")}');
    if (user.profile != null) {
      print('  Profile:');
      print('    Bio: ${user.profile!.bio}');
      print('    Avatar: ${user.profile!.avatarUrl}');
      print('    Settings: ${user.profile!.settings}');
    } else {
      print('  Profile: None');
    }
    print('');
  }

  print('=== Seed Consistency Examples ===\n');
  
  // Seed consistency examples
  print('Using same seed generates same data:');
  final seed = 42;
  final user1 = ExampleRegistry.instance.exampleOf<User>(seed: seed);
  final user2 = ExampleRegistry.instance.exampleOf<User>(seed: seed);
  print('User1 ID: ${user1.id}');
  print('User2 ID: ${user2.id}');
  print('IDs same: ${user1.id == user2.id}');
  print('');
  
  print('Using different seeds generates different data:');
  final userA = ExampleRegistry.instance.exampleOf<User>(seed: 100);
  final userB = ExampleRegistry.instance.exampleOf<User>(seed: 200);
  print('UserA ID: ${userA.id}');
  print('UserB ID: ${userB.id}');
  print('IDs different: ${userA.id != userB.id}');
  print('');

  print('=== Field Path Seed Examples ===\n');
  
  // Field path seed examples
  final baseSeed = 1000;
  print('Base seed: $baseSeed');
  print('user.name field seed: ${seedFor("user.name", baseSeed)}');
  print('user.email field seed: ${seedFor("user.email", baseSeed)}');
  print('user.profile.bio field seed: ${seedFor("user.profile.bio", baseSeed)}');
  print('user.tags[0] field seed: ${seedFor("user.tags[0]", baseSeed)}');
  print('');
  
  // Show field path seed consistency
  print('Field path seed consistency:');
  final fieldSeed1 = seedFor("user.name", baseSeed);
  final fieldSeed2 = seedFor("user.name", baseSeed);
  print('Computed field seeds same: ${fieldSeed1 == fieldSeed2}');
  print('');

  print('=== ExampleContext Detailed Usage Examples ===\n');
  
  final ctx = ExampleContext(777);
  print('Direct use of ExampleContext:');
  print('Random letters: ${ctx.letters(min: 5, max: 10)}');
  print('Random digits: ${ctx.digits(min: 3, max: 6)}');
  print('Random email: ${ctx.email()}');
  print('Random integer (1-100): ${ctx.intIn(1, 100)}');
  print('Random double (0-10): ${ctx.doubleIn(0, 10)}');
  print('Random chance (70%): ${ctx.chance(0.7)}');
  print('Random date: ${ctx.dateIn(DateTime.utc(2023, 1, 1), DateTime.utc(2023, 12, 31))}');
}
