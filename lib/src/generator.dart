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

/// Generate example code based on @ExampleModel
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

    // Generate example class
    buffer.writeln('/// $className example generator');
    buffer.writeln('class ${className}Example extends TypeExample<$className> {');
    buffer.writeln('  @override');
    buffer.writeln('  $className generate(ExampleContext ctx, {Map<String, Object?>? hints}) {');

    // Get the constructor
    final constructor = _getConstructor(classElement);
    if (constructor == null) {
      throw InvalidGenerationSourceError(
        '$className has no public constructor',
        element: classElement,
      );
    }

    // Generate constructor call
    buffer.writeln('    return $className(');

    for (final param in constructor.formalParameters) {
      final fieldName = param.name ?? 'field';
      final fieldType = param.type;

      // Get field annotations
      final fieldElement = classElement.fields.where((f) => f.name == fieldName).firstOrNull;

      final example = _getAnnotation<Example>(fieldElement);
      final len = _getAnnotation<Len>(fieldElement);
      final range = _getAnnotation<Range>(fieldElement);
      final pattern = _getAnnotation<Pattern>(fieldElement);
      final oneOf = _getAnnotation<OneOf>(fieldElement);
      final enumHint = _getAnnotation<EnumHint>(fieldElement);
      final nullable = _getAnnotation<Nullable>(fieldElement);
      final items = _getAnnotation<Items>(fieldElement);
      final dateRange = _getAnnotation<DateRange>(fieldElement);
      final email = _getAnnotation<Email>(fieldElement);

      buffer.write('      $fieldName: ');

      // Generate field value
      if (example != null) {
        // Use fixed example value if provided
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
          email: email,
        ));
      }

      buffer.writeln(',');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  ConstructorElement? _getConstructor(ClassElement classElement) {
    // Find the unnamed public constructor
    return classElement.constructors.where((c) => c.isPublic).firstOrNull;
  }

  T? _getAnnotation<T>(Element? element) {
    if (element == null) return null;

    for (final metadata in element.metadata.annotations) {
      final obj = metadata.computeConstantValue();
      if (obj == null) continue;

      final type = obj.type;
      if (type == null) continue;

      // Compare type names to identify the annotation
      final typeName = type.getDisplayString();
      if (typeName == T.toString()) {
        return _deserializeAnnotation<T>(obj, metadata);
      }
    }
    return null;
  }

  T? _deserializeAnnotation<T>(dynamic constantValue, ElementAnnotation annotation) {
    final source = annotation.toSource();

    // Parse based on type
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
    } else if (T == Email) {
      final domainMatch =
          RegExp(r"domain:\s*'([^']*)'").firstMatch(source) ?? RegExp(r'domain:\s*"([^"]*)"').firstMatch(source);
      final maxLenMatch = RegExp(r'maxLen:\s*(\d+)').firstMatch(source);
      final domain = domainMatch?.group(1) ?? 'example.com';
      final maxLen = maxLenMatch != null ? int.parse(maxLenMatch.group(1)!) : null;
      return Email(domain: domain, maxLen: maxLen) as T;
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
    Email? email,
  }) {
    final isNullable = fieldType.nullabilitySuffix == NullabilitySuffix.question;

    // Handle nullable fields
    if (isNullable && nullable != null) {
      final prob = nullable.prob;
      return 'ctx.chance($prob) ? null : ${_generateNonNullValue(fieldType, fieldName, len: len, range: range, pattern: pattern, oneOf: oneOf, enumHint: enumHint, items: items, dateRange: dateRange, email: email)}';
    }

    return _generateNonNullValue(fieldType, fieldName,
        len: len,
        range: range,
        pattern: pattern,
        oneOf: oneOf,
        enumHint: enumHint,
        items: items,
        dateRange: dateRange,
        email: email);
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
    Email? email,
  }) {
    final typeName = fieldType.getDisplayString();

    // Handle basic types
    switch (typeName) {
      case 'String':
        return _generateStringValue(fieldName, len: len, pattern: pattern, oneOf: oneOf, email: email);
      case 'int':
        return _generateIntValue(range: range);
      case 'double':
        return _generateDoubleValue(range: range);
      case 'bool':
        return 'ctx.chance(0.5)';
      case 'DateTime':
        return _generateDateTimeValue(dateRange: dateRange);
    }

    // List
    if (typeName.startsWith('List<')) {
      return _generateListValue(fieldType, fieldName, items: items, oneOf: oneOf);
    }

    // Set
    if (typeName.startsWith('Set<')) {
      return _generateSetValue(fieldType, fieldName, items: items);
    }

    // Map
    if (typeName.startsWith('Map<')) {
      return _generateMapValue(fieldType, fieldName, items: items);
    }

    // Enum
    if (fieldType.element is EnumElement) {
      return _generateEnumValue(fieldType, enumHint: enumHint);
    }

    // Custom class - use ExampleRegistry to get example
    return 'ExampleRegistry.instance.exampleOf<$typeName>(seed: seedFor("$fieldName", ctx.seed))';
  }

  String _generateStringValue(String fieldName, {Len? len, Pattern? pattern, OneOf? oneOf, Email? email}) {
    final hints = <String, dynamic>{};

    if (len != null) {
      if (len.min != null) hints['minLen'] = len.min;
      if (len.max != null) hints['maxLen'] = len.max;
    }

    if (pattern != null) {
      hints['pattern'] = "r'${pattern.regex}'";
    }

    if (oneOf != null) {
      final values = oneOf.values.map((v) => "'$v'").join(', ');
      hints['oneOf'] = '[$values]';
    }

    // Check email annotation or field name
    if (email != null) {
      hints['email'] = 'true';
      hints['domain'] = "'${email.domain}'";
      if (email.maxLen != null) {
        hints['maxLen'] = email.maxLen;
      }
    }

    if (hints.isEmpty) {
      return 'ctx.letters()';
    } else {
      final hintsStr = hints.entries.map((e) => "'${e.key}': ${e.value}").join(', ');
      return 'ExampleRegistry.instance.exampleOf<String>(seed: seedFor("$fieldName", ctx.seed), hints: <String, Object?>{$hintsStr})';
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

  String _generateListValue(DartType listType, String fieldName, {Items? items, OneOf? oneOf}) {
    // Extract element type
    final elementType = (listType as ParameterizedType).typeArguments.first;

    final min = items?.min ?? 1;
    final max = items?.max ?? 3;
    final fixed = items?.fixed;

    if (fixed != null) {
      return 'List.generate($fixed, (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]", oneOf: oneOf)})';
    } else {
      return 'List.generate(ctx.intIn($min, $max), (i) => ${_generateNonNullValue(elementType, "$fieldName[\$i]", oneOf: oneOf)})';
    }
  }

  String _generateSetValue(DartType setType, String fieldName, {Items? items}) {
    // Same as List but wrapped in Set.from
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
      // If prefer value is valid, use it with higher probability
      return 'ctx.chance(0.7) ? ${enumHint!.prefer} : $enumName.values[ctx.intIn(0, ${values.length - 1})]';
    } else {
      return '$enumName.values[ctx.intIn(0, ${values.length - 1})]';
    }
  }
}
