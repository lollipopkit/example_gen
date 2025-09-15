// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation_example.dart';

// **************************************************************************
// ExampleGenerator
// **************************************************************************

/// User example generator
class UserExample extends TypeExample<User> {
  @override
  User generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return User(
      id: 'user_12345',
      username: ExampleRegistry.instance
          .exampleOf<String>(seed: seedFor("username", 42), hints: <String, Object?>{'minLen': 3, 'maxLen': 15}),
      email: 'john.doe@example.com',
      age: ctx.intIn(18, 65),
      bio: ctx.chance(0.3) ? null : ctx.letters(),
      role: ExampleRegistry.instance.exampleOf<String>(seed: seedFor("role", 42), hints: <String, Object?>{
        'oneOf': ['developer', 'designer', 'manager', 'admin', 'user']
      }),
      joinDate: ctx.dateIn(DateTime.utc(2020, 1, 1), DateTime.utc(2024, 12, 31)),
      skills: List.generate(ctx.intIn(1, 4), (i) => ctx.letters()),
      isActive: ctx.chance(0.5),
    );
  }
}

/// Product example generator
class ProductExample extends TypeExample<Product> {
  @override
  Product generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return Product(
      productId: ExampleRegistry.instance.exampleOf<String>(seed: seedFor("productId", 42), hints: <String, Object?>{
        'pattern': r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      }),
      name: ExampleRegistry.instance
          .exampleOf<String>(seed: seedFor("name", 42), hints: <String, Object?>{'minLen': 5, 'maxLen': 30}),
      price: ctx.doubleIn(1.0, 999.99),
      categories: List.generate(3, (i) => ctx.letters()),
      description: ctx.chance(0.6)
          ? null
          : ExampleRegistry.instance.exampleOf<String>(
              seed: seedFor("description", 42), hints: <String, Object?>{'minLen': 20, 'maxLen': 100}),
    );
  }
}

/// Order example generator
class OrderExample extends TypeExample<Order> {
  @override
  Order generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    return Order(
      orderNumber: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("orderNumber", 42), hints: <String, Object?>{'pattern': r'^ORD-\d{8}-\d{4}$'}),
      productIds: List.generate(ctx.intIn(1, 5), (i) => ctx.letters()),
      status: ExampleRegistry.instance.exampleOf<String>(seed: seedFor("status", 42), hints: <String, Object?>{
        'oneOf': ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
      }),
      totalAmount: ctx.doubleIn(10.0, 5000.0),
      orderDate: ctx.dateIn(DateTime.utc(2024, 1, 1), DateTime.utc(2024, 12, 31)),
      notes: ctx.chance(0.4)
          ? null
          : ExampleRegistry.instance
              .exampleOf<String>(seed: seedFor("notes", 42), hints: <String, Object?>{'minLen': 10, 'maxLen': 50}),
    );
  }
}
