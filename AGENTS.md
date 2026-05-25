# Repository Guidelines

## Project Structure & Module Organization
This repository contains a Flutter app in `lab_assistant_app/`. Core Dart code lives in `lab_assistant_app/lib/`: `main.dart` wires the app shell, `theme.dart` centralizes styling, `models/` defines experiment data, `services/` holds workflow logic, `state/` manages app state, `screens/` contains page-level UI, and `widgets/` contains reusable UI pieces. Tests live in `lab_assistant_app/test/` and mirror the behavior under `lib/`. Platform runners and generated platform files are under `android/`, `ios/`, and `macos/`; avoid editing them unless the platform behavior requires it. Design notes are kept under `docs/superpowers/plans/`.

## Build, Test, and Development Commands
Run commands from `lab_assistant_app/`.

- `flutter pub get`: install Dart and Flutter dependencies from `pubspec.yaml`.
- `flutter run`: launch the app on a connected device, emulator, or desktop target.
- `flutter test`: run all unit and widget tests in `test/`.
- `flutter analyze`: run static analysis using `analysis_options.yaml` and `flutter_lints`.
- `dart format lib test`: format Dart source and tests before submitting changes.

## Coding Style & Naming Conventions
Follow standard Dart formatting with two-space indentation. Use `UpperCamelCase` for classes, enums, and widgets; `lowerCamelCase` for methods, fields, and local variables; and `snake_case.dart` for file names. Keep business logic in `services/` or `state/`, not inside screen widgets. Prefer small reusable widgets in `widgets/` when UI is shared or grows complex. Keep user-facing strings consistent with the app language already used in the surrounding screen.

## Testing Guidelines
Use `flutter_test`. Name test files with the `_test.dart` suffix, such as `app_state_test.dart` or `lab_workflow_service_test.dart`. Add unit tests for service and state changes, and widget tests for visible UI flows. Before handing off, run `flutter test` and `flutter analyze`; include any known failures in the PR notes.

## Commit & Pull Request Guidelines
The current history uses concise imperative commit messages, for example `Publish lab assistant for hackathon handoff`. Keep commits focused and describe the user-visible or architectural change. Pull requests should include a short summary, test results, linked issue or task context when available, and screenshots or screen recordings for UI changes. Note any platform-specific impact for Android, iOS, or macOS.
