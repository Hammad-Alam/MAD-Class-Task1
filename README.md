# flutter_app

A Flutter multi-screen demo application built for classroom-style learning and practice.
It demonstrates a simple registration and login flow, an authenticated dashboard,
and a detail screen for course/subject information. The project is intentionally
lightweight and uses in-memory state, which makes it easy to understand and extend.

## Overview

This app follows a basic user journey:

1. Register a user account.
2. Log in with the registered email and password.
3. View a dashboard that shows the current user and a list of subjects.
4. Open a subject to see more details on a dedicated page.
5. Log out and return to the login screen.

The application does not use a backend, database, or external authentication service.
All user data is stored temporarily in memory through a singleton controller.

## Features

- Registration form with full name, email, gender, password, and password confirmation.
- Login form with email, password, and a remember-me option.
- Form validation for name, email, password rules, gender selection, and password matching.
- Dashboard that greets the logged-in user and lists available subjects.
- Detail page for each subject with course description, schedule, and metadata.
- Material 3 UI with a consistent purple-themed design.
- Named-route navigation between screens.

## Tech Stack

- Flutter SDK
- Dart
- Material 3 widgets
- `flutter_lints` for static analysis

## Project Structure

The repository is organized by feature and responsibility:

```text
flutter_app/
├── android/                 # Android-specific native project files
├── ios/                     # iOS-specific native project files
├── linux/                   # Linux desktop runner files
├── macos/                   # macOS desktop runner files
├── web/                     # Web entry point and assets
├── windows/                 # Windows desktop runner files
├── lib/                     # Application source code
├── test/                    # Widget and unit tests
├── analysis_options.yaml    # Linting and analysis rules
├── pubspec.yaml             # Package metadata and dependencies
└── README.md                # Project documentation
```

### `lib/`

The application code is split into smaller folders:

```text
lib/
├── main.dart                # App bootstrap, theme, and route configuration
├── controllers/             # In-memory auth logic
├── enums/                   # Enum definitions for auth and gender
├── models/                  # Data models for users and subjects
├── screens/                 # UI screens for each page
└── validators/              # Reusable form validation helpers
```

### Screen Responsibilities

- `RegistrationScreen` collects user details and creates a new in-memory account.
- `LoginScreen` authenticates a registered user and optionally remembers the email.
- `DashboardScreen` shows the current user and available subjects.
- `DetailScreen` displays the selected subject in a richer detail layout.

## Application Flow

### Registration

The registration screen validates the following fields:

- Full name must not be empty and must contain at least two characters.
- Email must follow a valid email format.
- Gender must be selected from the dropdown.
- Password must be at least six characters and include one uppercase letter and one special character.
- Confirm password must match the original password.

When registration succeeds, the user is redirected to the login screen.
If the email already exists in memory, the registration is rejected.

### Login

The login screen validates the email and password, then calls the in-memory auth controller.
If credentials are correct, the app navigates to the dashboard.
If the remember-me box is enabled, the app stores the email for the current session.

### Dashboard

After login, the dashboard shows:

- A welcome header with the user’s initials and email.
- A list of subjects loaded from `SubjectModel.getSubjects()`.
- A logout action that clears the current session and returns to login.

### Subject Details

The dashboard routes to the detail screen and passes the selected subject as a navigation argument.
The detail page maps the subject name to a matching icon and color, then renders:

- Course description
- Weekly schedule
- Subject metadata such as duration and level

## Architecture Notes

This project uses a very simple architecture:

- `AuthController` is a singleton that stores registered users and session state.
- `UserModel` and `SubjectModel` represent the app’s data.
- `FormValidator` keeps validation logic separate from UI code.
- `Gender` and `AuthStatus` keep domain values explicit and readable.

Because the state is stored in memory, all data is lost when the app restarts.
That is fine for a learning project, but it is not suitable for production authentication.

## Routing

Routes are defined in `main.dart`:

- `/register` -> Registration screen
- `/login` -> Login screen
- `/dashboard` -> Dashboard screen
- `/detail` -> Subject detail screen

The app starts on `/register`.

## Validation Rules

Validation helpers live in `lib/validators/form_validator.dart` and are reused across the forms.
This keeps the UI clean and ensures the same rules are applied consistently.

## Data Models

### `UserModel`

Stores:

- Full name
- Email
- Password
- Gender

### `SubjectModel`

Stores:

- Subject name
- Description
- Schedule
- Image key used as a logical identifier

The current subject list contains:

- Mobile App Development
- Software Re-engineering
- MIS

## Dependencies

The project currently uses only a small set of dependencies:

- `flutter`
- `cupertino_icons`
- `flutter_lints`

No external state-management, networking, or database package is included.

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK installed with Flutter
- A configured development device or emulator

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

You can target Android, iOS, web, Windows, macOS, or Linux depending on your local setup.

### Run Tests

```bash
flutter test
```

## Notes on the Current Codebase

- The app is currently a teaching/demo project, not a production auth system.
- User data is not persisted across app launches.
- The default test file still contains Flutter’s template counter test and can be replaced with app-specific tests.
- There are no image assets wired into the subject model yet, even though `SubjectModel` contains an `imageUrl` field.

## Suggested Next Improvements

If you want to evolve the project, the most useful next steps would be:

1. Replace in-memory auth with local persistence or a backend service.
2. Add app-specific widget tests for registration, login, and dashboard navigation.
3. Remove unused model fields or connect them to real assets.
4. Introduce a state-management solution if the app grows beyond the current scope.

## Documentation References

- Flutter docs: https://docs.flutter.dev/
- Flutter cookbook: https://docs.flutter.dev/cookbook
- Dart language docs: https://dart.dev/
