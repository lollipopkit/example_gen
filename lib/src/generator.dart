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

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// 代码生成器，基于 @ExampleModel 注解生成示例创建方法
class ExampleGenerator extends GeneratorForAnnotation<ExampleModel> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ExampleModel 只能应用于类',
        element: element,
      );
    }

    return _generateClass(element);
  }

  String _generateClass(ClassElement classElement) {
    final className = classElement.name;
    final buffer = StringBuffer();

    // 生成示例创建方法
    buffer.writeln('/// 自动生成的 $className 示例创建方法');
    buffer.writeln('class ${className}Example extends TypeExample<$className> {');
    buffer.writeln('  @override');
    buffer.writeln('  $className generate(ExampleContext ctx, {Map<String, Object?>? hints}) {');
    
    // 获取构造函数
    final constructor = _getConstructor(classElement);
    if (constructor == null) {
      throw InvalidGenerationSourceError(
        '$className 需要有一个公共构造函数',
        element: classElement,
      );
    }

    // 生成构造函数调用
    buffer.writeln('    return $className(');
    
    for (final param in constructor.parameters) {
      final fieldName = param.name;
      final fieldType = param.type;
      
      // 获取字段上的注解
      final fieldElement = classElement.fields
          .where((f) => f.name == fieldName)
          .firstOrNull;
      
      final example = _getAnnotation<Example>(fieldElement);
      final len = _getAnnotation<Len>(fieldElement);
      final range = _getAnnotation<Range>(fieldElement);
      final pattern = _getAnnotation<Pattern>(fieldElement);
      final oneOf = _getAnnotation<OneOf>(fieldElement);
      final enumHint = _getAnnotation<EnumHint>(fieldElement);
      final nullable = _getAnnotation<Nullable>(fieldElement);
      final items = _getAnnotation<Items>(fieldElement);
      final dateRange = _getAnnotation<DateRange>(fieldElement);
      
      buffer.write('      $fieldName: ');
      
      // 生成字段值
      if (example != null) {
        // 优先使用固定示例值
        buffer.write(_generateExampleValue(example));
      } else {
        buffer.write(_generateFieldValue(
          fieldType, 
          fieldName,
          len: len,
          range: range,
          pattern: pattern,
          oneOf: oneOf,
          enumHint: enumHint,
          nullable: nullable,
          items: items,
          dateRange: dateRange,
        ));
      }
      
      buffer.writeln(',');
    }
    
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    
    // 生成注册辅助方法
    buffer.writeln();
    buffer.writeln('/// 注册 $className 示例生成器');
    buffer.writeln('void register${className}Example() {');
    buffer.writeln('  ExampleRegistry.instance.register<$className>(${className}Example());');
    buffer.writeln('}');

    return buffer.toString();
  }

  ConstructorElement? _getConstructor(ClassElement classElement) {
    // 查找默认构造函数或第一个公共构造函数
    return classElement.constructors
        .where((c) => c.isPublic)
        .firstOrNull;
  }

  T? _getAnnotation<T>(Element? element) {
    if (element == null) return null;
    
    for (final metadata in element.metadata) {
      final obj = metadata.computeConstantValue();
      if (obj == null) continue;
      
      final type = obj.type;
      if (type == null) continue;
      
      // 比对类型名称
      final typeName = type.getDisplayString(withNullability: false);
      if (typeName == T.toString()) {
        return _deserializeAnnotation<T>(obj, metadata);
      }
    }
    return null;
  }

  T? _deserializeAnnotation<T>(dynamic constantValue, ElementAnnotation annotation) {
    final source = annotation.toSource();
    
    // 简单的字符串解析方式来获取注解参数
    if (T == Example) {
      final match = RegExp(r'Example\(\s*value:\s*(.+?)\s*\)').firstMatch(source);
      if (match != null) {
        final valueStr = match.group(1)!;
        dynamic value;
        if (valueStr.startsWith("'") && valueStr.endsWith("'")) {
          value = valueStr.substring(1, valueStr.length - 1);
        } else if (valueStr == 'null') {
          value = null;
        } else if (valueStr == 'true') {
          value = true;
        } else if (valueStr == 'false') {
          value = false;
        } else {
          value = num.tryParse(valueStr) ?? valueStr;
        }
        return Example(value: value) as T;
      }
    } else if (T == Len) {
      final minMatch = RegExp(r'min:\s*(\d+)').firstMatch(source);
      final maxMatch = RegExp(r'max:\s*(\d+)').firstMatch(source);
      final min = minMatch != null ? int.parse(minMatch.group(1)!) : null;
      final max = maxMatch != null ? int.parse(maxMatch.group(1)!) : null;
      return Len(min: min, max: max) as T;
    } else if (T == Range) {
      final minMatch = RegExp(r'min:\s*([\d.]+)').firstMatch(source);
      final maxMatch = RegExp(r'max:\s*([\d.]+)').firstMatch(source);
      final min = minMatch != null ? num.parse(minMatch.group(1)!) : null;
      final max = maxMatch != null ? num.parse(maxMatch.group(1)!) : null;
      return Range(min: min, max: max) as T;
    } else if (T == Pattern) {
      final match = RegExp("Pattern\\(r?['\\\"](.+?)['\\\"]\\)").firstMatch(source);
      if (match != null) {
        return Pattern(match.group(1)!) as T;
      }
    } else if (T == OneOf) {
      final match = RegExp(r'OneOf\(\s*\[(.+?)\]\s*\)').firstMatch(source);
      if (match != null) {
        final valuesStr = match.group(1)!;
        final values = valuesStr.split(',').map((s) {
          s = s.trim();
          if (s.startsWith("'") && s.endsWith("'")) {
            return s.substring(1, s.length - 1);
          }
          return s;
        }).toList();
        return OneOf(values) as T;
      }
    } else if (T == Nullable) {
      final match = RegExp(r'prob:\s*([\d.]+)').firstMatch(source);
      final prob = match != null ? double.parse(match.group(1)!) : 0.0;
      return Nullable(prob: prob) as T;
    } else if (T == Items) {
      final minMatch = RegExp(r'min:\s*(\d+)').firstMatch(source);
      final maxMatch = RegExp(r'max:\s*(\d+)').firstMatch(source);
      final fixedMatch = RegExp(r'fixed:\s*(\d+)').firstMatch(source);
      final min = minMatch != null ? int.parse(minMatch.group(1)!) : null;
      final max = maxMatch != null ? int.parse(maxMatch.group(1)!) : null;
      final fixed = fixedMatch != null ? int.parse(fixedMatch.group(1)!) : null;
      return Items(min: min, max: max, fixed: fixed) as T;
    } else if (T == DateRange) {
      final startYearMatch = RegExp(r'startYear:\s*(\d+)').firstMatch(source);
      final endYearMatch = RegExp(r'endYear:\s*(\d+)').firstMatch(source);
      final startYear = startYearMatch != null ? int.parse(startYearMatch.group(1)!) : null;
      final endYear = endYearMatch != null ? int.parse(endYearMatch.group(1)!) : null;
      return DateRange(startYear: startYear, endYear: endYear) as T;
    }
    
    return null;
  }

  String _generateExampleValue(Example example) {
    final value = example.value;
    if (value is String) {
      return "'${value.replaceAll("'", "\\'")}'";
    } else if (value is num || value is bool) {
      return value.toString();
    } else if (value == null) {
      return 'null';
    } else {
      return value.toString();
    }
  }

  String _generateFieldValue(
    DartType fieldType,
    String fieldName, {
    Len? len,
    Range? range,
    Pattern? pattern,
    OneOf? oneOf,
    EnumHint? enumHint,
    Nullable? nullable,
    Items? items,
    DateRange? dateRange,
  }) {
    final isNullable = fieldType.nullabilitySuffix == NullabilitySuffix.question;
    
    // 处理可空类型
    if (isNullable && nullable != null) {
      final prob = nullable.prob;
      return 'ctx.chance($prob) ? null : ${_generateNonNullValue(fieldType, fieldName, len: len, range: range, pattern: pattern, oneOf: oneOf, enumHint: enumHint, items: items, dateRange: dateRange)}';
    }
    
    return _generateNonNullValue(fieldType, fieldName, len: len, range: range, pattern: pattern, oneOf: oneOf, enumHint: enumHint, items: items, dateRange: dateRange);
  }

  String _generateNonNullValue(
    DartType fieldType,
    String fieldName, {
    Len? len,
    Range? range,
    Pattern? pattern,
    OneOf? oneOf,
    EnumHint? enumHint,
    Items? items,
    DateRange? dateRange,
  }) {
    final typeName = fieldType.getDisplayString(withNullability: false);
    
    // 基本类型处理
    switch (typeName) {
      case 'String':
        return _generateStringValue(fieldName, len: len, pattern: pattern, oneOf: oneOf);
      case 'int':
        return _generateIntValue(range: range);
      case 'double':
        return _generateDoubleValue(range: range);
      case 'bool':
        return 'ctx.chance(0.5)';
      case 'DateTime':
        return _generateDateTimeValue(dateRange: dateRange);
    }
    
    // 列表类型
    if (typeName.startsWith('List<')) {
      return _generateListValue(fieldType, fieldName, items: items);
    }
    
    // Set类型
    if (typeName.startsWith('Set<')) {
      return _generateSetValue(fieldType, fieldName, items: items);
    }
    
    // Map类型
    if (typeName.startsWith('Map<')) {
      return _generateMapValue(fieldType, fieldName, items: items);
    }
    
    // 枚举类型
    if (fieldType.element is EnumElement) {
      return _generateEnumValue(fieldType, enumHint: enumHint);
    }
    
    // 自定义类型
    return 'ExampleRegistry.instance.exampleOf<$typeName>(seed: seedFor("$fieldName", 42))';
  }

  String _generateStringValue(String fieldName, {Len? len, Pattern? pattern, OneOf? oneOf}) {
    final hints = <String, dynamic>{};
    
    if (len != null) {
      if (len.min != null) hints['minLen'] = len.min;
      if (len.max != null) hints['maxLen'] = len.max;
    }
    
    if (pattern != null) {
      // 使用 r'' 原始字符串来避免转义问题
      hints['pattern'] = "r'${pattern.regex}'";
    }
    
    if (oneOf != null) {
      final values = oneOf.values.map((v) => "'$v'").join(', ');
      hints['oneOf'] = '[$values]';
    }
    
    // 检测邮箱字段
    if (fieldName.toLowerCase().contains('email')) {
      hints['email'] = 'true';
    }
    
    if (hints.isEmpty) {
      return 'ctx.letters()';
    } else {
      final hintsStr = hints.entries.map((e) => "'${e.key}': ${e.value}").join(', ');
      return 'ExampleRegistry.instance.exampleOf<String>(seed: seedFor("$fieldName", 42), hints: <String, Object?>{$hintsStr})';
    }
  }

  String _generateIntValue({Range? range}) {
    if (range != null) {
      final min = range.min?.toInt() ?? 0;
      final max = range.max?.toInt() ?? 100;
      return 'ctx.intIn($min, $max)';
    }
    return 'ctx.intIn(0, 100)';
  }

  String _generateDoubleValue({Range? range}) {
    if (range != null) {
      final min = range.min ?? 0.0;
      final max = range.max ?? 1.0;
      return 'ctx.doubleIn($min, $max)';
    }
    return 'ctx.doubleIn(0.0, 1.0)';
  }

  String _generateDateTimeValue({DateRange? dateRange}) {
    if (dateRange != null) {
      final start = dateRange.start ?? DateTime.utc(2000);
      final end = dateRange.end ?? DateTime.utc(2030);
      return 'ctx.dateIn(DateTime.utc(${start.year}, ${start.month}, ${start.day}), DateTime.utc(${end.year}, ${end.month}, ${end.day}))';
    }
    return 'ctx.dateIn(DateTime.utc(2000), DateTime.utc(2030))';
  }

  String _generateListValue(DartType listType, String fieldName, {Items? items}) {
    // 提取泛型参数
    final elementType = (listType as ParameterizedType).typeArguments.first;
    
    final min = items?.min ?? 1;
    final max = items?.max ?? 3;
    final fixed = items?.fixed;
    
    if (fixed != null) {
      return 'List.generate($fixed, (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]")})';
    } else {
      return 'List.generate(ctx.intIn($min, $max), (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]")})';
    }
  }

  String _generateSetValue(DartType setType, String fieldName, {Items? items}) {
    // 类似 List 处理
    final elementType = (setType as ParameterizedType).typeArguments.first;
    
    final min = items?.min ?? 1;
    final max = items?.max ?? 3;
    final fixed = items?.fixed;
    
    if (fixed != null) {
      return 'Set.from(List.generate($fixed, (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]")}))';
    } else {
      return 'Set.from(List.generate(ctx.intIn($min, $max), (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]")}))';
    }
  }

  String _generateMapValue(DartType mapType, String fieldName, {Items? items}) {
    final typeArgs = (mapType as ParameterizedType).typeArguments;
    final keyType = typeArgs[0];
    final valueType = typeArgs[1];
    
    final min = items?.min ?? 1;
    final max = items?.max ?? 3;
    final fixed = items?.fixed;
    
    final size = fixed != null ? fixed.toString() : 'ctx.intIn($min, $max)';
    
    return 'Map.fromEntries(List.generate($size, (i) => MapEntry(${_generateNonNullValue(keyType, "$fieldName.key[\$i]")}, ${_generateNonNullValue(valueType, "$fieldName.value[\$i]")})))';
  }

  String _generateEnumValue(DartType enumType, {EnumHint? enumHint}) {
    final enumElement = enumType.element as EnumElement;
    final enumName = enumElement.name;
    final values = enumElement.fields.where((f) => f.isEnumConstant).map((f) => f.name).toList();
    
    if (enumHint?.prefer != null) {
      // 如果有首选值，70% 概率使用首选值
      return 'ctx.chance(0.7) ? ${enumHint!.prefer} : $enumName.values[ctx.intIn(0, ${values.length - 1})]';
    } else {
      return '$enumName.values[ctx.intIn(0, ${values.length - 1})]';
    }
  }
}