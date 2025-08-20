# Ghiraas

Ghiraas is an AI-powered health and sustainability mobile application designed to help users manage their health metrics and promote eco-friendly habits. This application leverages artificial intelligence to provide personalized recommendations and insights based on user data.

## Project Structure (Feature-First + Clean Architecture)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_dimensions.dart
│   └── constants/
│       ├── app_constants.dart
│       ├── asset_constants.dart
│       └── string_constants.dart
├── core/
│   ├── di/
│   │   └── dependency_injection.dart
│   ├── error/
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── network_info.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── logging_interceptor.dart
│   ├── utils/
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   ├── datetime_extensions.dart
│   │   │   └── context_extensions.dart
│   │   ├── helpers/
│   │   │   ├── date_helper.dart
│   │   │   ├── validation_helper.dart
│   │   │   └── sustainability_calculator.dart
│   │   └── enums/
│   │       ├── app_enums.dart
│   │       └── sustainability_enums.dart
│   ├── services/
│   │   ├── local_storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── camera_service.dart
│   │   └── sensors_service.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       ├── sustainability_badge.dart
│       ├── progress_ring.dart
│       └── eco_score_display.dart
├── features/
│   ├── auth/ ...
│   ├── home/ ...
│   ├── exercise/ ...
│   ├── nutrition/ ...
│   ├── sleep/ ...
│   ├── profile/ ...
│   └── ai/ ...
├── assets/
│   ├── fonts/
│   ├── images/
│   │   ├── icons/
│   │   ├── illustrations/
│   │   └── logos/
│   ├── lottie/
│   └── json/
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

## Migration Note

This project has been migrated to a feature-first, clean architecture structure. All previous code in `lib/src/screens` and `lib/src/widgets` should be moved to the appropriate new locations under `features/` and `core/widgets/` respectively.

## Getting Started

To get started with the SustainaHealth application, follow these steps:

1. **Install dependencies**:
   ```
   flutter pub get
   ```
2. **Run the application**:
   ```
   flutter run
   ```

## Features

- **AI Integration**: Provides personalized health recommendations based on user data.
- **Health Tracking**: Allows users to manage and track their health metrics.
- **Sustainability Tracking**: Encourages eco-friendly habits and tracks sustainability efforts.
- **User Profiles**: Users can create and manage their profiles to personalize their experience.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Known Issues & Areas for Improvement

- **Platform Support**: This app is intended for Android and Web only. The `ios/`, `macos/`, and `linux/` folders are not needed and can be removed to reduce clutter.

- **Migration Incomplete**: Legacy code still exists in `lib/src/screens` and `lib/src/widgets`. These should be moved to the new `features/` and `core/widgets/` locations as per the migration note above.

- **Redundant Widget Files**: There are duplicate or legacy widget files in `lib/widgets/` and `lib/core/widgets/`. Consolidate widgets into the correct folder (`core/widgets/`).

- **Empty Folders**: The folder `lib/app/constants` is currently empty. Remove or populate it as needed.

- **Test Coverage**: Only a single widget test is present in `test/widget_test.dart`. The `test/unit/`, `test/widget/`, and `test/integration/` folders are empty. Add more tests to improve coverage.

- **Examples & Services**: Example and service files exist outside the new structure (`lib/examples/`, `lib/services/`). Consider moving them under `features/` or `core/` as appropriate.

- **pubspec.yaml Cleanup**: Some dependencies are commented out or duplicated. Clean up unused dependencies and ensure only necessary packages are included.

- **Documentation**: Update documentation to reflect platform support and ongoing migration/cleanup tasks.

---