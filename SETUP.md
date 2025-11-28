# Nexly - Quick Setup Guide

## ✅ What's Been Completed

This bare minimum setup includes:

1. **Flutter Project Structure** - Android-only configuration
2. **Core Dependencies** - All packages installed and configured
3. **Data Models** - NotificationItem with Hive persistence
4. **Android Permissions** - Notification listener permissions configured
5. **Screens** - Dashboard and Summary screens
6. **Notification Service** - Background notification capture
7. **Routing** - go_router setup for navigation
8. **Cactus Integration** - Ready for AI model integration

## 🚀 Quick Start

```bash
# Run the app
flutter run

# Or build APK
flutter build apk --release
```

## 📱 First Run Setup

1. Launch the app on Android device
2. Tap "Grant Notification Access"
3. Enable Nexly in system settings
4. Return to app and tap "Start Service"
5. Notifications will now be captured silently
6. View captured notifications via "View Summary"

## 🤖 AI Model Integration (Optional - For Later)

### Recommended Model for 6GB RAM: **Gemma 2B IT**

**Why Gemma 2B IT?**
- RAM Usage: ~1.5GB (leaves 4.5GB for system)
- Speed: Fast inference (50-150 tokens/sec)
- Quality: High-quality Google model
- Format: GGUF Q4_0 quantization

### Download Model

```bash
# Download from HuggingFace
wget https://huggingface.co/google/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_0.gguf

# Or use smaller models:
# Qwen 1.8B (~1GB): https://huggingface.co/Qwen/Qwen-1_8B-Chat-GGUF
# TinyLlama 1.1B (~700MB): https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
```

### Integration Steps (When Ready)

1. Add model file to app assets:
   ```yaml
   # pubspec.yaml
   flutter:
     assets:
       - assets/models/gemma-2b-it-q4_0.gguf
   ```

2. Update `lib/services/cactus_service.dart`:
   ```dart
   _model = await CactusLM.create(
     modelPath: 'assets/models/gemma-2b-it-q4_0.gguf',
     maxTokens: 512,
     temperature: 0.7,
   );
   ```

3. Initialize in main.dart:
   ```dart
   await CactusAIService.initialize();
   ```

## 📂 Project Structure

```
lib/
├── models/
│   ├── notification_item.dart        # Notification data model
│   └── notification_item.g.dart      # Hive adapter (generated)
├── screens/
│   ├── dashboard_screen.dart         # Main screen with service controls
│   └── summary_screen.dart           # Notification list view
├── services/
│   ├── notification_service.dart     # Background notification capture
│   └── cactus_service.dart          # AI service (ready for integration)
└── main.dart                         # App entry point with Hive init
```

## 🔧 Technical Details

### Storage
- **Hive**: Lightweight NoSQL database
- **Location**: Device local storage
- **Box Name**: `notifications`
- **Type-safe**: Generated adapters with build_runner

### Permissions (AndroidManifest.xml)
- `BIND_NOTIFICATION_LISTENER_SERVICE` - Core feature
- `POST_NOTIFICATIONS` - Local notifications
- `RECEIVE_BOOT_COMPLETED` - Auto-start (future)
- `WAKE_LOCK` - Background operation
- `FOREGROUND_SERVICE` - Service stability

### Background Service
- Uses `flutter_notification_listener`
- Runs in separate isolate
- Filters system notifications
- Auto-saves to Hive

## 🎯 Next Steps (Future Implementation)

- [ ] Implement AI summarization with Gemma 2B
- [ ] Add scheduled daily notifications (8 PM)
- [ ] Smart categorization using AI
- [ ] Notification priority detection
- [ ] Custom filter rules
- [ ] Export functionality
- [ ] Multi-day history

## 📊 Performance Expectations

With **Gemma 2B IT Q4_0** on 6GB RAM device:
- **Inference Speed**: 50-150 tokens/sec
- **Time to First Token**: <50ms
- **RAM Usage**: ~1.5GB (model) + ~500MB (app) = ~2GB total
- **Available RAM**: ~4GB for system

## 🐛 Troubleshooting

### Notifications not capturing?
- Check notification access permission
- Ensure service is started
- Check system battery optimization settings

### App crashes?
- Check Android version (requires API 24+)
- Review flutter logs: `flutter logs`

### Build errors?
- Clean and rebuild: `flutter clean && flutter pub get`
- Regenerate code: `flutter pub run build_runner build --delete-conflicting-outputs`

## 📝 Development Commands

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk --release

# View logs
flutter logs
```

## ✨ Ready to Go!

Your Nexly app is set up and ready to run. The AI features are prepared but not yet active - you can add them later when needed. For now, you have a fully functional notification capture and summary app!
