[English](README.md) | 简体中文

# example_gen

基于注解的 Dart 示例数据生成库。  
为模型生成真实、确定性的示例数据，支持灵活的约束和自定义选项。

## 安装

```bash
dart pub add example_gen
```

## 快速开始

### 0. 使用注解定义您的模型

```dart
import 'package:example_gen/example_gen.dart';

@ExampleModel()
class User {
  @Len(min: 8, max: 12)
  final String id;
  
  @Pattern(r'^[A-Z][a-z]+ [A-Z][a-z]+$')
  final String name;
  
  @Example(value: 'user@example.com') // 固定值
  final String email;
  
  @Range(min: 18, max: 80)
  final int age;
  
  @Nullable(prob: 0.2) // 20% 概率为 null
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

### 1. 生成示例代码

```bash
dart run build_runner build
```

### 2. 注册类型生成器

```dart
// 注册内置生成器
registerBuiltins();

// 注册自定义生成器
ExampleRegistry.instance.register<User>(UserExample());
```

### 3. 生成示例

```dart
// 使用种子生成示例以确保可重现性
final user = ExampleRegistry.instance.exampleOf<User>(seed: 42);
print(user.name); // 种子 42 总是生成相同的名称

// 使用提示生成
final email = ExampleRegistry.instance.exampleOf<String>(
  seed: 1,
  hints: {'email': true}
);
print(email); // 生成类似邮箱的字符串
```

## 可用注解

### 核心注解

| 注解 | 用途 | 示例 |
|------|------|------|
| `@ExampleModel()` | 标记类用于生成 | `@ExampleModel()` |
| `@Example(value: ...)` | 固定值（最高优先级） | `@Example(value: 'fixed')` |

### 字符串约束

| 注解 | 用途 | 示例 |
|------|------|------|
| `@Len(min: 5, max: 10)` | 字符串长度 | `@Len(min: 5, max: 10)` |
| `@Pattern('regex')` | 正则表达式模式 | `@Pattern(r'\d{3}-\d{4}')` |
| `@OneOf(['a', 'b', 'c'])` | 候选值 | `@OneOf(['red', 'blue', 'green'])` |

### 数值约束

| 注解 | 用途 | 示例 |
|------|------|------|
| `@Range(min: 0, max: 100)` | 数值范围 | `@Range(min: 18, max: 65)` |

### 空值处理

| 注解 | 用途 | 示例 |
|------|------|------|
| `@Nullable(prob: 0.3)` | 空值概率（0-1） | `@Nullable(prob: 0.2)` |

### 集合约束

| 注解 | 用途 | 示例 |
|------|------|------|
| `@Items(min: 1, max: 5)` | 集合大小 | `@Items(fixed: 3)` |

### 日期约束

| 注解 | 用途 | 示例 |
|------|------|------|
| `@DateRange(...)` | 日期时间范围 | `@DateRange(startYear: 2025, endYear: 2025)` |

### 文档

| 注解 | 用途 | 示例 |
|------|------|------|
| `@FieldDescription('text')` | 字段文档 | `@FieldDescription('用户唯一标识符')` |

## 高级用法

### 自定义类型生成器

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

### ExampleContext 工具方法

`ExampleContext` 提供各种工具方法：

```dart
final ctx = ExampleContext(seed: 42);

// 字符串生成
ctx.letters(min: 5, max: 10);     // 随机字母
ctx.digits(min: 3, max: 6);       // 随机数字
ctx.email();                      // 类似邮箱的字符串

// 数值生成
ctx.intIn(1, 100);               // 随机整数
ctx.doubleIn(0.0, 10.0);         // 随机双精度浮点数

// 布尔值生成
ctx.chance(0.7);                 // 70% 概率为 true

// 日期生成
ctx.dateIn(start, end);          // 范围内的随机日期
```

### 字段路径种子

用于确定性的字段级生成：

```dart
final baseSeed = 1000;
final fieldSeed = seedFor("user.profile.name", baseSeed);
final ctx = ExampleContext(fieldSeed);
final name = ctx.letters(min: 5, max: 15);
```

## 内置类型支持

该库包含以下类型的生成器：

- **String**：支持邮箱/UUID 检测、长度约束、模式匹配
- **int**：支持范围约束
- **double**：支持范围约束
- **bool**：随机布尔值
- **DateTime**：支持日期范围约束

## 示例输出

```dart
// 基本类型
String: "kdmfhsldk"
Email string: "user@example.com"
UUID string: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
Integer: 42
Range integer: 156
Double: 7.23
Boolean: true
DateTime: 2023-05-15 14:30:22.000Z

// 自定义 User 示例
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

## 许可证

该项目采用 Apache 2.0 许可证 - 查看 LICENSE 文件了解详情。