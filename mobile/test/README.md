# IndoWater Mobile App Tests

This directory contains tests for the IndoWater mobile application.

## Test Structure

The tests are organized into the following directories:

- `unit/`: Unit tests for individual components and services
- `widget/`: Widget tests for UI components
- `integration/`: Integration tests for flows and interactions between components

## Running Tests

### Unit and Widget Tests

To run all unit and widget tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/unit/meter_service_test.dart
```

### Integration Tests

To run integration tests:

```bash
flutter test integration_test/app_test.dart
```

## Generating Mocks

The project uses Mockito for mocking dependencies in tests. To generate mock classes:

```bash
flutter pub run build_runner build
```

This will generate mock classes based on the annotations in `test/generate_mocks.dart`.

## Test Coverage

To generate test coverage reports:

```bash
flutter test --coverage
```

This will generate a coverage report in the `coverage/` directory.

## Test Guidelines

1. **Unit Tests**: Focus on testing the logic of individual components in isolation.
2. **Widget Tests**: Test UI components and their interactions.
3. **Integration Tests**: Test flows and interactions between components.
4. **Mocking**: Use Mockito to mock dependencies in tests.
5. **Test Coverage**: Aim for high test coverage, especially for critical components.
6. **Test Naming**: Use descriptive names for tests that indicate what is being tested.
7. **Test Organization**: Organize tests in a way that makes it easy to find and run specific tests.

## Test Dependencies

- `flutter_test`: Flutter's testing framework
- `integration_test`: Flutter's integration testing framework
- `mockito`: Mocking framework for Dart
- `build_runner`: Code generation tool for Dart