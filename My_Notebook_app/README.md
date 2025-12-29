# My First App - Flutter Task Manager

A clean, simple Flutter todo/task management application demonstrating core Flutter concepts: StatefulWidget, ListView.builder, state management with setState, and basic UI design with Material Design.

## 🎯 Features

- ✅ **Task List Display** - View all tasks in a scrollable list
- ✅ **Mark Complete** - Check off completed tasks with visual strike-through
- ✅ **Delete Tasks** - Remove tasks with trash icon button
- ✅ **Real-time Updates** - Instant UI refresh with `setState()`
- ✅ **Material Design** - Built with Flutter's Material Design package

## 📱 Screenshots

(Add screenshots here when app is run)

## 🏗️ Project Structure

```
lib/
  └── main.dart          # Complete app: MyApp, MyHomePage, Task model
android/                # Android-specific configuration
ios/                    # iOS-specific configuration
web/                    # Web build configuration
test/                   # Unit/Widget tests
```

## 📋 App Architecture

### Main Components:

1. **MyApp** (StatelessWidget)
   - Root widget
   - Configures MaterialApp with blue theme

2. **MyHomePage** (StatefulWidget)
   - Main UI screen with task list

3. **_MyHomePageState**
   - Manages task list state
   - Handles task completion toggle
   - Handles task deletion

4. **Task** (Model Class)
   - Simple data class: `name` + `isCompleted`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.3+)
- Dart SDK
- Emulator/Device for testing

### Installation

```bash
# Navigate to project
cd my_first_app

# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

## 💻 Development

### Run Tests
```bash
flutter test
```

### Format Code
```bash
dart format lib/
```

### Analyze Code
```bash
flutter analyze
```

## 📚 Next Steps / Enhancement Ideas

- [ ] Add task creation dialog with TextField
- [ ] Persist tasks using shared_preferences or SQLite
- [ ] Add task categories/filtering
- [ ] Implement task editing
- [ ] Add due dates
- [ ] Add task priority levels
- [ ] Implement local notifications
- [ ] Add dark mode support

## 📝 Dependencies

- `flutter` - Flutter framework
- `cupertino_icons` - iOS-style icons

## 🔧 Configuration

- **Dart Version:** 3.10.3+
- **Flutter Version:** Latest stable
- **Platforms:** Android, iOS, Web, Windows, Linux, macOS

## 📄 License

MIT License - feel free to use this for learning

## 📖 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guide](https://material.io/design)

## ✨ Learn From This Project

This app demonstrates:
- StatefulWidget lifecycle
- ListView.builder for efficient list rendering
- setState() for reactive updates
- Material Design widgets
- Dart class definitions
- Basic Flutter project structure
