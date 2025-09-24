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

/// Marks a model that needs example code generation.
class ExampleModel {
  const ExampleModel();
}

/// Fixed example value (highest priority)
class Example {
  final Object? value;
  const Example({this.value});
}

/// String length
class Len {
  final int? min;
  final int? max;
  const Len({this.min, this.max});
}

/// Numeric range
class Range {
  final num? min;
  final num? max;
  const Range({this.min, this.max});
}

/// Regex pattern hint (common patterns like email/uuid will be recognized)
class Pattern {
  final String regex;
  const Pattern(this.regex);
}

/// Candidate set
class OneOf {
  final List<Object?> values;
  const OneOf(this.values);
}

/// Enum preference
class EnumHint<T> {
  final T? prefer;
  const EnumHint({this.prefer});
}

/// Nullable probability (0~1), only applies to nullable fields
class Nullable {
  final double prob;
  const Nullable({this.prob = 0.0});
}

/// Collection size (List/Set/Map)
class Items {
  final int? min;
  final int? max;
  final int? fixed;
  const Items({this.min, this.max, this.fixed});
}

/// Date range (DateTime)
class DateRange {
  final int? startYear;
  final int startMonth;
  final int startDay;
  final int? endYear;
  final int endMonth;
  final int endDay;

  const DateRange({
    this.startYear,
    this.startMonth = 1,
    this.startDay = 1,
    this.endYear,
    this.endMonth = 12,
    this.endDay = 31,
  });

  DateTime? get start => startYear != null ? DateTime(startYear!, startMonth, startDay) : null;

  DateTime? get end => endYear != null ? DateTime(endYear!, endMonth, endDay) : null;
}

/// For documentation only (notes in preview structure)
class FieldDescription {
  final String text;
  const FieldDescription(this.text);
}

/// Email constraint with domain and length control
class Email {
  final String domain;
  final int? maxLen;
  const Email({this.domain = 'example.com', this.maxLen});
}
