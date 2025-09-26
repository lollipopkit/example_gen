# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-09-26

### Added
- `@UUID()` annotation for generating RFC 4122 compliant UUID v4 strings
  - Generates UUID format: `xxxxxxxx-xxxx-4xxx-axxx-xxxxxxxxxxxx`
  - Deterministic generation with seeded random numbers
  - Available as both `@UUID()` and `@uuid` (const instance)
  - Added `uuid()` method to `ExampleContext` for manual UUID generation

### Updated
- Enhanced `StringExample` to handle UUID generation via hints
- Added comprehensive tests for UUID generation and validation
- Updated README documentation with UUID annotation examples
- Updated example code to demonstrate UUID usage

## [1.1.0] - 2025-09-26

### Removed
- **BREAKING CHANGE**: `@Pattern` annotation has been completely removed
  - Pattern-based string generation using regex patterns is no longer supported
  - Use `@Len`, `@OneOf`, or `@Email` annotations for string constraints instead
  - This simplifies the library architecture and removes complex regex pattern handling

### Changed
- Updated examples to use `@Len` constraints instead of `@Pattern`
- Refined StringExample generator to focus on length and candidate-based generation
- Updated documentation to reflect removal of Pattern annotation

### Migration Guide
- Replace `@Pattern(r'regex')` with `@Len(min: X, max: Y)` for length constraints
- Replace `@Pattern` with `@OneOf(['value1', 'value2'])` for specific value sets
- Use `@Email(domain: 'example.com')` for email-like strings

## [1.0.1] - 2025-09-25

### Added
- `@Email` annotation for generating realistic email addresses
  - Configurable domain (defaults to 'example.com')
  - Optional maximum length constraint
  - Generates valid email format with random usernames

### Fixed
- Improved code generation stability and error handling
- Enhanced annotation processing reliability

### Changed
- Updated example generation logic for better type safety
- Refined generator implementation for improved performance

## [1.0.0] - Initial Release

### Added
- Core annotation-based example generation system
- Built-in annotations:
  - `@ExampleModel()` - Mark classes for generation
  - `@Example(value: ...)` - Fixed values
  - `@Len(min, max)` - String length constraints
  - `@Range(min, max)` - Numeric range constraints  
  - `@Pattern(regex)` - Regex pattern matching
  - `@OneOf([...])` - Candidate value selection
  - `@Nullable(prob: 0.3)` - Null probability
  - `@Items(min, max)` - Collection size constraints
  - `@DateRange(...)` - DateTime range constraints
  - `@FieldDescription(...)` - Field documentation
- Seeded random generation for deterministic results
- Build system integration with `build_runner`
- Support for custom type generators via registry
- Preview utilities for JSON output
