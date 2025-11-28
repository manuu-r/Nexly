# Nexly - Your Notification Secretary

Nexly silently captures your phone notifications throughout the day and presents them as a clean daily summary, turning constant interruption into efficient batch processing.

## Features

- 📱 **Silent Notification Capture** - Notifications are captured in the background without interrupting you
- 📊 **Daily Summary** - View all captured notifications organized by app
- 🔕 **No Interruptions** - Stay focused while Nexly works silently
- 🗂️ **Organized View** - Notifications grouped by app with expandable details
- 🚀 **Quick App Launch** - Tap to open the source app directly
- 🤖 **AI-Ready** - Cactus integration for future AI-powered summarization

## Requirements

- Flutter SDK (latest stable)
- Android device with API level 24+ (Android 7.0+)
- Minimum 6GB RAM (for AI features)

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
flutter run
```

### 4. Grant Permissions

1. Open the app
2. Tap "Grant Notification Access"
3. Enable notification access for Nexly
4. Return to the app and start the service

## Project Structure

```
lib/
├── models/
│   ├── notification_item.dart       # Data model for notifications
│   └── notification_item.g.dart     # Generated Hive adapter
├── screens/
│   ├── dashboard_screen.dart        # Main dashboard
│   └── summary_screen.dart          # Notification summary view
├── services/
│   ├── notification_service.dart    # Background notification listener
│   └── cactus_service.dart         # AI service (future feature)
└── main.dart                        # App entry point
```

## Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: ValueListenable (Hive)
- **Local Storage**: Hive (lightweight, fast NoSQL database)
- **Routing**: go_router
- **AI Engine**: Cactus Compute (for future AI features)
- **Notifications**: flutter_notification_listener, flutter_local_notifications

## Recommended AI Models (6GB RAM Devices)

For future AI-powered summarization features:

### 1. Gemma 2B IT (Recommended)
- **RAM Usage**: ~1.5GB
- **Speed**: Fast
- **Quality**: High
- **Model**: `gemma-2b-it-q4_0.gguf`

### 2. Qwen 1.8B
- **RAM Usage**: ~1GB
- **Speed**: Very Fast
- **Quality**: Good
- **Model**: `qwen1_8b-q4_0.gguf`

### 3. TinyLlama 1.1B
- **RAM Usage**: ~700MB
- **Speed**: Extremely Fast
- **Quality**: Acceptable
- **Model**: `tinyllama-1.1b-q4_0.gguf`

## Future Features (Planned)

- [ ] AI-powered notification summarization
- [ ] Smart categorization using AI
- [ ] Scheduled daily summary notifications (8 PM)
- [ ] Notification priority detection
- [ ] Custom filter rules
- [ ] Multi-day history view
- [ ] Export summaries

## Development Notes

### Building for Release

```bash
flutter build apk --release
```

### Debugging Notification Service

The notification listener runs in a background isolate. Check logs with:

```bash
flutter logs
```

## License

See [LICENSE](LICENSE) file for details.

## Contributing

This is a personal project built according to the implementation plan. Contributions welcome!
