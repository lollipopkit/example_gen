import 'package:example_gen/example_gen.dart';
import 'package:example_gen/src/core.dart';

// User model example using annotations
@ExampleModel()
class User {
  // Fixed example value (highest priority)
  @Example(value: 'user_12345')
  final String id;

  // String length constraint
  @Len(min: 3, max: 15)
  final String username;

  // Fixed email example
  @Example(value: 'john.doe@example.com')
  final String email;

  // Numeric range constraint
  @Range(min: 18, max: 65)
  final int age;

  // Nullable field probability control
  @Nullable(prob: 0.3) // 30% probability of null
  final String? bio;

  // Candidate value set
  @OneOf(['developer', 'designer', 'manager', 'admin', 'user'])
  final String role;

  // Date range constraint
  @DateRange(startYear: 2020, endYear: 2024)
  final DateTime joinDate;

  // Collection size constraint and candidate values
  @Items(min: 1, max: 4)
  @OneOf(['dart', 'flutter', 'javascript', 'python', 'java', 'go', 'rust'])
  final List<String> skills;

  // Field description (for documentation)
  @FieldDescription('User active status')
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.age,
    this.bio,
    required this.role,
    required this.joinDate,
    required this.skills,
    required this.isActive,
  });

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, age: $age, '
        'bio: $bio, role: $role, joinDate: $joinDate, skills: $skills, '
        'isActive: $isActive}';
  }
}

// Product model using regex patterns
@ExampleModel()
class Product {
  // UUID pattern
  @Pattern(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
  final String productId;

  // Product name length limit
  @Len(min: 5, max: 30)
  final String name;

  // Price range
  @Range(min: 1.0, max: 999.99)
  final double price;

  // Fixed number of tags
  @Items(fixed: 3)
  @OneOf(['electronics', 'clothing', 'books', 'home', 'sports', 'toys'])
  final List<String> categories;

  // Nullable description with higher null probability
  @Nullable(prob: 0.6)
  @Len(min: 20, max: 100)
  final String? description;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.categories,
    this.description,
  });

  @override
  String toString() {
    return 'Product{productId: $productId, name: $name, price: $price, '
        'categories: $categories, description: $description}';
  }
}

// Order model demonstrating more complex constraints
@ExampleModel()
class Order {
  // Order number pattern: ORD-YYYYMMDD-NNNN
  @Pattern(r'^ORD-\d{8}-\d{4}$')
  final String orderNumber;

  // Order item count range
  @Items(min: 1, max: 5)
  final List<String> productIds;

  // Order status
  @OneOf(['pending', 'processing', 'shipped', 'delivered', 'cancelled'])
  final String status;

  // Total amount range
  @Range(min: 10.0, max: 5000.0)
  final double totalAmount;

  // Order date within the last year
  @DateRange(startYear: 2024, endYear: 2024)
  final DateTime orderDate;

  // Nullable notes
  @Nullable(prob: 0.4)
  @Len(min: 10, max: 50)
  final String? notes;

  Order({
    required this.orderNumber,
    required this.productIds,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.notes,
  });

  @override
  String toString() {
    return 'Order{orderNumber: $orderNumber, productIds: $productIds, '
        'status: $status, totalAmount: $totalAmount, orderDate: $orderDate, '
        'notes: $notes}';
  }
}

// Custom generator example
class UserExample extends TypeExample<User> {
  @override
  User generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return User(
      // @Example annotation will override this value
      id: ctx.letters(min: 8, max: 12),
      username: ctx.letters(min: 3, max: 15),
      // @Example annotation will override this value
      email: ctx.email(),
      age: ctx.intIn(18, 65),
      bio: ctx.chance(0.7) ? ctx.letters(min: 20, max: 100) : null,
      role: ['developer', 'designer', 'manager', 'admin', 'user'][ctx.intIn(0, 4)],
      joinDate: ctx.dateIn(DateTime(2020, 1, 1), DateTime(2024, 12, 31)),
      skills: List.generate(
        ctx.intIn(1, 4),
        (_) => ['dart', 'flutter', 'javascript', 'python', 'java', 'go', 'rust'][ctx.intIn(0, 6)],
      ),
      isActive: ctx.chance(0.8),
    );
  }
}

class ProductExample extends TypeExample<Product> {
  @override
  Product generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return Product(
      productId: ctx.uuid(),
      name: ctx.letters(min: 5, max: 30),
      price: ctx.doubleIn(1.0, 999.99),
      categories: List.generate(
        3,
        (_) => ['electronics', 'clothing', 'books', 'home', 'sports', 'toys'][ctx.intIn(0, 5)],
      ),
      description: ctx.chance(0.4) ? ctx.letters(min: 20, max: 100) : null,
    );
  }
}

class OrderExample extends TypeExample<Order> {
  @override
  Order generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final date = ctx.dateIn(DateTime(2024, 1, 1), DateTime(2024, 12, 31));
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final seq = ctx.intIn(1000, 9999);

    return Order(
      orderNumber: 'ORD-$dateStr-$seq',
      productIds: List.generate(ctx.intIn(1, 5), (_) => ctx.uuid()),
      status: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'][ctx.intIn(0, 4)],
      totalAmount: ctx.doubleIn(10.0, 5000.0),
      orderDate: date,
      notes: ctx.chance(0.6) ? ctx.letters(min: 10, max: 50) : null,
    );
  }
}

void main() {
  print('=== Example Gen Annotation Examples ===\n');

  // Register built-in generators
  registerBuiltins();

  // Register custom generators
  ExampleRegistry.instance.register<User>(UserExample());
  ExampleRegistry.instance.register<Product>(ProductExample());
  ExampleRegistry.instance.register<Order>(OrderExample());

  print('=== User Examples (Demonstrating Various Annotation Constraints) ===\n');

  // Generate multiple user examples
  for (int i = 1; i <= 3; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 100 + i);
    print('User $i:');
    print('  ID: ${user.id}'); // Fixed value
    print('  Username: ${user.username}'); // Length constraint
    print('  Email: ${user.email}'); // Fixed value
    print('  Age: ${user.age}'); // Range constraint
    print('  Bio: ${user.bio ?? "None"}'); // Nullable field
    print('  Role: ${user.role}'); // Candidate values
    print('  Join Date: ${user.joinDate}'); // Date range
    print('  Skills: ${user.skills.join(", ")}'); // Collection constraint
    print('  Active Status: ${user.isActive ? "Yes" : "No"}');
    print('');
  }

  print('=== Product Examples (Demonstrating Regex Pattern Constraints) ===\n');

  // Generate product examples
  for (int i = 1; i <= 2; i++) {
    final product = ExampleRegistry.instance.exampleOf<Product>(seed: 200 + i);
    print('Product $i:');
    print('  Product ID: ${product.productId}'); // UUID pattern
    print('  Name: ${product.name}'); // Length constraint
    print('  Price: \$${product.price.toStringAsFixed(2)}'); // Price range
    print('  Categories: ${product.categories.join(", ")}'); // Fixed count
    print('  Description: ${product.description ?? "None"}'); // High null probability
    print('');
  }

  print('=== Order Examples (Demonstrating Complex Constraint Combinations) ===\n');

  // Generate order examples
  for (int i = 1; i <= 2; i++) {
    final order = ExampleRegistry.instance.exampleOf<Order>(seed: 300 + i);
    print('Order $i:');
    print('  Order Number: ${order.orderNumber}'); // Complex pattern
    print('  Product ID List: ${order.productIds.join(", ")}'); // Dynamic count
    print('  Status: ${order.status}'); // Status enum
    print('  Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'); // Amount range
    print('  Order Date: ${order.orderDate}'); // Date range
    print('  Notes: ${order.notes ?? "None"}'); // Nullable notes
    print('');
  }

  print('=== Seed Consistency Verification ===\n');

  // Verify that same seed generates same data
  const testSeed = 42;
  final user1 = ExampleRegistry.instance.exampleOf<User>(seed: testSeed);
  final user2 = ExampleRegistry.instance.exampleOf<User>(seed: testSeed);

  print('Data generated using same seed $testSeed:');
  print('User1 ID: ${user1.id}');
  print('User2 ID: ${user2.id}');
  print('Data Consistent: ${user1.id == user2.id && user1.username == user2.username}');
  print('');

  print('=== Annotation Constraint Effects Demonstration ===\n');

  // Demonstrate effects of different annotations
  print('String length constraint effects:');
  for (int i = 0; i < 3; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 500 + i);
    print('  Username "${user.username}" length: ${user.username.length} (constraint: 3-15)');
  }
  print('');

  print('Numeric range constraint effects:');
  for (int i = 0; i < 3; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 600 + i);
    print('  Age: ${user.age} (constraint: 18-65)');
  }
  print('');

  print('Collection size constraint effects:');
  for (int i = 0; i < 3; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 700 + i);
    print('  Skills count: ${user.skills.length} (constraint: 1-4)');
  }
  print('');

  print('Nullable field probability effects (30% null):');
  int nullCount = 0;
  const sampleSize = 10;
  for (int i = 0; i < sampleSize; i++) {
    final user = ExampleRegistry.instance.exampleOf<User>(seed: 800 + i);
    if (user.bio == null) nullCount++;
  }
  print('  $nullCount null values out of $sampleSize samples (${(nullCount / sampleSize * 100).toStringAsFixed(1)}%)');
}
