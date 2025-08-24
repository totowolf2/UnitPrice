# Repository Guidelines

## Project Structure & Modules
- `lib/`: Main source. Organized by feature-first.
  - `lib/core/`: Cross-cutting utilities, constants, providers.
  - `lib/features/`: Feature modules (products, comparison, settings).
  - `lib/shared/`: Reusable widgets and shared models.
- `test/`: Widget/unit tests (`*_test.dart`).
- Platform folders: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`.

## Build, Test, and Dev Commands
- Install deps: `flutter pub get`.
- Analyze code: `flutter analyze` (uses `analysis_options.yaml`).
- Format code: `dart format .` (2-space indent by default).
- Run app: `flutter run` (e.g., `-d chrome`, `-d ios`).
- Build release: `flutter build apk` | `flutter build ios` | `flutter build web`.
- Generate code (isar/riverpod):
  - One-off: `dart run build_runner build --delete-conflicting-outputs`.
  - Watch: `dart run build_runner watch --delete-conflicting-outputs`.

## Coding Style & Naming
- Follow Flutter lints (see `analysis_options.yaml`).
- Dart style: `PascalCase` classes, `lowerCamelCase` members, `snake_case.dart` files.
- Keep features isolated; prefer pure functions in `core/utils`.
- Avoid `print`; use logging (see below) and Riverpod for state.

## Testing Guidelines
- Framework: `flutter_test` with `WidgetTester`.
- File naming: mirror source path with `_test.dart` suffix.
- Run all tests: `flutter test`.
- Coverage (optional): `flutter test --coverage` (outputs `coverage/lcov.info`).
- Add tests for: price/unit conversions, repositories, widgets’ basic interactions.

## Commit & Pull Requests
- Note: No existing Git history to infer conventions. Use Conventional Commits:
  - Examples: `feat(products): add unit selector`, `fix(db): handle isar init error`.
- PRs must include:
  - Clear description and rationale; link issues (e.g., `Closes #12`).
  - Screenshots for UI changes (before/after), and testing notes.
  - Touch `pubspec.yaml` only when required; run codegen if annotations changed.

## Security & Configuration Tips
- Local DB: Isar stores data on-device; avoid committing real data.
- Platform permissions: keep image picker/storage permissions minimal and documented.
- Secrets: none should live in repo; use platform keystores where applicable.

