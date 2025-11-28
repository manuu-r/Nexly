# Nexly Implementation Plan

## The Concept
**The Problem:**
Phones ring, vibrate, and light up for *everything*, breaking focus and creating anxiety ("Did I miss something important?").

**The Solution:**
Nexly acts like a secretary for your phone. It **silently catches notifications in the background** throughout the day and holds them. At a set time (e.g., 8 PM), it presents a clean **"Daily Summary"** of everything you missed. This turns "constant interruption" into efficient "batch processing."

## Overview
**Goal:** Build a Flutter app that collects system notifications via a background service, persists them using **Cactus Compute (Hybrid Fallback)**, and displays a daily summary with deep-link support.
**Stack:** Flutter, `flutter_notification_listener`, `cactus`, `go_router`, `android_intent_plus`.
**Timeline:** 24 Hours.

## Phase 1: Project Setup & Data Layer (Hours 0-4)
1.  **Initialize Project:**
    *   `flutter create nexly`
    *   Add dependencies: `flutter_notification_listener`, `cactus`, `go_router`, `android_intent_plus`, `flutter_local_notifications`, `intl`, `shared_preferences`.

2.  **Cactus Compute Configuration:**
    *   Initialize `CactusSync`.
    *   Enable **Hybrid Fallback** (local-first storage).
    *   **Model:** Create `NotificationItem` class.
        *   Fields: `id`, `packageName`, `title`, `body`, `timestamp`, `isRead`.
        *   Implement `CactusModel` interface (ensure serialization/deserialization).

## Phase 2: Android Background Service (Hours 4-10)
1.  **Manifest Configuration (`AndroidManifest.xml`):**
    *   Add `BIND_NOTIFICATION_LISTENER_SERVICE` permission.
    *   Register `NotificationListenerProvider` service.

2.  **Service Logic (`service.dart`):**
    *   Implement static callback `onNotificationReceived`.
    *   **Isolate Handling:** Initialize a separate Cactus instance inside the background isolate if necessary to persist data immediately upon receipt.
    *   Filter logic: Ignore ongoing/system low-priority notifications if needed.

3.  **Permissions:**
    *   Implement UI flow to guide user to Android "Notification Access" settings.

## Phase 3: UI & Deep Linking (Hours 10-18)
1.  **Navigation (`go_router`):**
    *   `/`: Dashboard (Status, Toggle Service, "Show Summary" debug button).
    *   `/summary`: List view of captured notifications.

2.  **Summary Screen:**
    *   Fetch `NotificationItem`s via Cactus (sorted by time/app).
    *   Group by `packageName`.
    *   **Action:** Tap to open app.
        *   Use `android_intent_plus` or `DeviceApps` to launch the specific package.
        *   Try constructing intents for specific deep links (e.g., `mailto:`) where parsable.

3.  **Data Management:**
    *   "Clear All" button (deletes from Cactus DB).
    *   "Mark as Read" functionality.

## Phase 4: Scheduling & Notifications (Hours 18-22)
1.  **Daily Trigger:**
    *   Use `flutter_local_notifications` to schedule a recurring notification at 8 PM.
    *   **Payload:** Tapping this notification launches the app directly to `/summary`.

2.  **Background Sync (Optional):**
    *   Ensure Cactus syncs with remote backend (if configured) when app comes to foreground.

## Phase 5: Testing & Build (Hours 22-24)
1.  **Edge Cases:**
    *   Test device restart (Service auto-start feasibility).
    *   Test permission revocation.
2.  **Polish:**
    *   Simple, clean UI (Material 3).
    *   Error handling for missing apps (deep link failure).