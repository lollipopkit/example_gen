// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation_example.dart';

// **************************************************************************
// ExampleGenerator
// **************************************************************************

/// 自动生成的 User 示例创建方法
class UserExample extends TypeExample<User> {
  @override
  User generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final baseSeed = hints?['_seed'] as int? ?? 42;
    return User(
      id: 'user_12345',
      username: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("username", baseSeed),
          hints: <String, Object?>{'minLen': 3, 'maxLen': 15}),
      email: 'john.doe@example.com',
      age: ctx.intIn(18, 65),
      bio: ctx.chance(0.3) ? null : ctx.letters(),
      role: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("role", baseSeed),
          hints: <String, Object?>{
            'oneOf': ['developer', 'designer', 'manager', 'admin', 'user']
          }),
      joinDate:
          ctx.dateIn(DateTime.utc(2020, 1, 1), DateTime.utc(2024, 12, 31)),
      skills: List.generate(ctx.intIn(1, 4), (i) => ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("skills_$i", baseSeed),
          hints: <String, Object?>{
            'oneOf': ['dart', 'flutter', 'javascript', 'python', 'java', 'go', 'rust']
          })),
      isActive: ctx.chance(0.5),
    );
  }
}

/// 注册 User 示例生成器
void registerUserExample() {
  ExampleRegistry.instance.register<User>(UserExample());
}

/// 自动生成的 Product 示例创建方法
class ProductExample extends TypeExample<Product> {
  @override
  Product generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final baseSeed = hints?['_seed'] as int? ?? 42;
    return Product(
      productId: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("productId", baseSeed),
          hints: <String, Object?>{
            'pattern':
                r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
          }),
      name: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("name", baseSeed),
          hints: <String, Object?>{'minLen': 5, 'maxLen': 30}),
      price: ctx.doubleIn(1.0, 999.99),
      categories: List.generate(3, (i) => ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("categories_$i", baseSeed),
          hints: <String, Object?>{
            'oneOf': ['electronics', 'clothing', 'books', 'home', 'sports', 'toys']
          })),
      description: ctx.chance(0.6)
          ? null
          : ExampleRegistry.instance.exampleOf<String>(
              seed: seedFor("description", baseSeed),
              hints: <String, Object?>{'minLen': 20, 'maxLen': 100}),
    );
  }
}

/// 注册 Product 示例生成器
void registerProductExample() {
  ExampleRegistry.instance.register<Product>(ProductExample());
}

/// 自动生成的 Order 示例创建方法
class OrderExample extends TypeExample<Order> {
  @override
  Order generate(ExampleContext ctx, {Map<String, Object?>? hints}) {
    final baseSeed = hints?['_seed'] as int? ?? 42;
    return Order(
      orderNumber: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("orderNumber", baseSeed),
          hints: <String, Object?>{'pattern': r'^ORD-\d{8}-\d{4}$'}),
      productIds: List.generate(ctx.intIn(1, 5), (i) => ctx.uuid()),
      status: ExampleRegistry.instance.exampleOf<String>(
          seed: seedFor("status", baseSeed),
          hints: <String, Object?>{
            'oneOf': [
              'pending',
              'processing',
              'shipped',
              'delivered',
              'cancelled'
            ]
          }),
      totalAmount: ctx.doubleIn(10.0, 5000.0),
      orderDate:
          ctx.dateIn(DateTime.utc(2024, 1, 1), DateTime.utc(2024, 12, 31)),
      notes: ctx.chance(0.4)
          ? null
          : ExampleRegistry.instance.exampleOf<String>(
              seed: seedFor("notes", baseSeed),
              hints: <String, Object?>{'minLen': 10, 'maxLen': 50}),
    );
  }
}

/// 注册 Order 示例生成器
void registerOrderExample() {
  ExampleRegistry.instance.register<Order>(OrderExample());
}
