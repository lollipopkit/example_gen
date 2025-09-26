# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
