# Stillness — Personal Meditation App for Android
## Architecture, Implementation & Handoff Guide

### 1. Overview
**Stillness** is a production-ready, Cupertino-inspired, offline-first personal meditation application designed for Android phones and tablets. Built with Flutter, Drift (SQLite), and just_audio, Stillness functions as a calm, precise, and unobtrusive instrument for mindfulness.

#### Key Principles
- **100% Offline & Private:** Zero accounts, zero analytics, zero network requests, zero telemetry, and zero ads. All data remains exclusively on the user's local device.
- **Cupertino-Inspired Instrument Aesthetic:** Clean typographic hierarchy, subtle tactile borders, frosted surfaces, restrained color accents, and dedicated OLED Sleep palette.
- **Authoritative Timing:** Wall-clock delta timing resistant to Android app lifecycles, background execution, and screen-off battery savers.
- **Adaptive Responsive Design:** Dynamic multi-pane layouts for tablets (NavigationRail, AdaptiveTwoPane) and focused ergonomic navigation for phones.
- **Data Portability:** Complete JSON export and import capabilities for local backups and migration.

---

### 2. Architecture & Directory Structure

```
lib/
├── app/
│   └── app.dart                     # Root StillnessApp widget, tab routing & theme switching
├── core/
│   ├── audio/
│   │   ├── audio_constants.dart     # Bell sounds, ambient tracks & display metadata
│   │   └── audio_service.dart       # Looped ambient mixing, bell cues, volume fading, focus handling
│   ├── haptics/
│   │   └── haptic_service.dart      # Tactile bell pulses and breathing phase cues
│   ├── notifications/
│   │   └── notification_service.dart# Daily scheduled practice reminders and active session indicators
│   ├── responsive/
│   │   ├── breakpoints.dart         # Compact (<600dp), Medium (600-840dp), Expanded (>840dp)
│   │   └── responsive_layout.dart   # ResponsiveScaffold, AdaptiveTwoPane, ContentContainer
│   ├── theme/
│   │   ├── app_colors.dart          # Light, Dark, and OLED Sleep color definitions
│   │   ├── app_theme.dart           # ThemeData configurations and context extensions
│   │   └── app_typography.dart     # Proportional typographic scales and mono timer styles
│   ├── wakelock/
│   │   └── wakelock_service.dart    # Screen keep-awake management during meditation
│   └── widgets/                     # Cupertino design system primitives (AppCard, AppButton, etc.)
├── data/
│   ├── database/
│   │   ├── database.dart            # Drift SQLite database schema and tables
│   │   └── database.g.dart          # Generated Drift database code
│   ├── models/
│   │   ├── achievement.dart         # Milestone achievements definition and progression
│   │   ├── app_settings.dart        # User preferences (theme, audio, countdowns, reminders)
│   │   ├── breathing_config.dart    # Breathing pattern models (Box, 4-7-8, Resonant, etc.)
│   │   ├── export_data.dart         # Schema for backup export/import
│   │   ├── meditation_session.dart  # Completed session record with moods and reflections
│   │   ├── meditation_type.dart     # 8 meditation modes with descriptions and icons
│   │   ├── practice.dart            # Practice configurations and 8 seeded built-in presets
│   │   └── session_snapshot.dart    # Immutable configuration snapshot for historical integrity
│   └── repositories/
│       ├── achievement_repository.dart# Milestones evaluation and persistence
│       ├── practice_repository.dart   # Practice CRUD and adaptive usage-based ranking
│       ├── session_repository.dart    # Session logging, stats aggregation, streaks
│       └── settings_repository.dart   # Settings persistence, backup JSON export/import, purge
├── features/
│   ├── achievements/screens/        # Milestones progress and unlocked badges screen
│   ├── completion/screens/          # Post-session mood rating (1-5) and reflective journaling
│   ├── history/screens/             # Month calendar view with activity dots and session inspector
│   ├── meditate/screens/            # Home dashboard, time-of-day greeting, quick-start launcher
│   ├── meditation_session/          # Active timer, breathing orb, visual guides, dismiss guard
│   ├── practices/screens/           # Practice browser, tablet split-view, comprehensive editor
│   ├── progress/screens/            # Time aggregated bar charts, streaks, practice breakdowns
│   └── settings/screens/            # Audio auditioning, themes, reminders, backup & restore
└── main.dart                        # Initialization of services, database, and error boundary
```

---

### 3. Database Schema (Drift SQLite)

1. **`practices` Table:**
   - `id`: Text Primary Key (UUID)
   - `name`: Text
   - `description`: Text
   - `type`: Text (Mapped to `MeditationType`)
   - `duration_seconds`: Integer
   - `preparation_seconds`: Integer
   - `ambient_sound`: Nullable Text
   - `ambient_volume`: Real (0.0 to 1.0)
   - `starting_bell`: Nullable Text
   - `ending_bell`: Nullable Text
   - `interval_bell`: Nullable Text
   - `interval_seconds`: Nullable Integer
   - `warm_up_seconds`: Integer
   - `cool_down_seconds`: Integer
   - `guidance_config`: Nullable Text (JSON-encoded specialized configurations)
   - `is_favorite`: Boolean
   - `is_pinned`: Boolean
   - `is_built_in`: Boolean
   - `usage_count`: Integer
   - `last_used_at`: Nullable DateTime
   - `created_at`: DateTime
   - `updated_at`: DateTime

2. **`sessions` Table:**
   - `id`: Text Primary Key (UUID)
   - `practice_id`: Nullable Text
   - `practice_name`: Text
   - `meditation_type`: Text
   - `started_at`: DateTime
   - `completed_at`: DateTime
   - `target_duration_seconds`: Integer
   - `actual_duration_seconds`: Integer
   - `completed`: Boolean
   - `mood_score`: Nullable Integer (1 to 5)
   - `reflection_note`: Nullable Text
   - `snapshot_json`: Text (Immutable `SessionSnapshot` for audit integrity)

3. **`achievements` Table:**
   - `id`: Text Primary Key
   - `title`: Text
   - `description`: Text
   - `icon`: Text
   - `target_value`: Integer
   - `current_value`: Integer
   - `is_unlocked`: Boolean
   - `unlocked_at`: Nullable DateTime

4. **`app_settings` Table:**
   - Single-row key-value storage for theme modes, sound preferences, reminder schedules, and defaults.

---

### 4. Audio Engine & Sound Synthesis

All audio files are embedded locally in `assets/audio/` as 16-bit PCM WAV files:
- **Bells (Binaural & Bell Synthesis):**
  - `bell_singing_bowl.wav` (Warm, grounding 216Hz Tibetan bowl fundamental with rich upper harmonics)
  - `bell_tingsha.wav` (Crisp, high-register 2048Hz Tibetan tingsha chime)
  - `bell_chime.wav` (Mid-range 880Hz meditation bell with clean exponential decay)
  - `bell_gong.wav` (Deep 108Hz resonant meditation gong with expansive sub-bass)
- **Nature Soundscapes (Seamlessly Looped):**
  - `nature_rain.wav` (Gentle steady rainfall)
  - `nature_ocean.wav` (Rhythmic slow ocean surf)
  - `nature_forest.wav` (Calm woodland breeze and soft foliage)
  - `nature_fireplace.wav` (Warm hearth embers and gentle crackle)
- **Noise Profiles (Filtered Color Noise):**
  - `noise_white.wav` (Equal energy per frequency)
  - `noise_pink.wav` (1/f spectral density for balanced calming focus)
  - `noise_brown.wav` (1/f² Brownian noise for deep relaxation and masking)
- **Ambient Drones:**
  - `ambient_soft.wav` (Airy, serene harmonic drone in F major)
  - `ambient_deep.wav` (Grounding, contemplative drone in C minor)

`AppAudioService` handles seamless looping, smooth volume cross-fades (fade-in / fade-out), interval bell cues, and Android audio focus ducking/pausing.

---

### 5. Quality Verification & Testing

The application has been verified according to the repository guidelines:
1. **Static Analysis:**
   - `flutter analyze` passes with **0 warnings and 0 errors**.
2. **Automated Test Suite:**
   - `flutter test` executes **21/21 unit and widget tests** cleanly:
     - Breathing cycle calculations and phase timing.
     - Immutable session snapshot integrity.
     - Streak calculation (consecutive days, multi-session days, broken streaks).
     - Adaptive usage-based practice ranking.
     - Backup JSON export, serialization, and import restoration.
     - App navigation, tab transitions, and reactive data streams.
     - Tablet responsive NavigationRail layout assertion.
     - Meditation launcher integration: "Start Meditation" navigation via `_navigatorKey` and clean session teardown.
     - Preparation timer instant handoff and active session clock startup.
     - Auto-discard rule for sessions under 5 seconds (zero SQLite persistence or achievement mutations).
     - Session preservation for sessions >= 5 seconds.
     - `RunningTimerDisplay` colon pulse animation and paused freeze states.
     - `LivingAmbientAura` dynamic breathing and minimal mode rendering.
3. **Resource Lifecycle & Navigation Architecture:**
   - Root navigation uses a `GlobalKey<NavigatorState>` bound to `MaterialApp`, ensuring `_startMeditation` can launch `ActiveMeditationScreen` from any context or modal sheet.
   - `ActiveMeditationScreen` properly disposes `SessionController` on unmount, ensuring ticker timers, wakelock, and audio playback are cleanly stopped without memory leaks or dangling timers.
   - Drift query stream subscriptions unmount without dangling timers or memory leaks.
   - Audio operations (`playBell`, `startBackgroundSound`, `resumeBackgroundSound`) run non-blocking (`unawaited`) so ExoPlayer playback initialization does not stall Dart event loops, ticker timers, or screen transitions.
   - Automatic short-session discard (< 5 seconds) dismisses `ActiveMeditationScreen` directly back to the Meditate tab with a floating notification banner, bypassing the post-session journal.
   - Running timer features a Cupertino-style animated colon (`:`) pulsing at 1 Hz when running and solid when paused.
   - Minimal meditation types (`silentTimer`, `focus`, `openAwareness`, `sleep`) utilize `LivingAmbientAura` to provide an organic, calm 6-second breathing rhythm.

---

### 6. Maintenance & Future Extensions

- **Adding New Meditation Types:** Add an enum value to `MeditationType`, implement corresponding guidance rendering in `lib/features/meditation_session/widgets/visual_guidance_view.dart`, and add default configuration in `lib/data/models/`.
- **Modifying Database Schema:** Update `lib/data/database/database.dart`, increment `schemaVersion`, and execute `dart run build_runner build --delete-conflicting-outputs`.
- **Adding Audio Assets:** Add WAV or MP3 files to `assets/audio/`, declare them in `pubspec.yaml`, and register them in `lib/core/audio/audio_constants.dart`.
- **Android Core Library Desugaring:** Enabled in `android/app/build.gradle.kts` via `isCoreLibraryDesugaringEnabled = true` and `desugar_jdk_libs:2.1.4` to support `flutter_local_notifications` java.time desugaring on Android API < 26.
- **Short Session Discard Threshold:** Configured via `SessionController.minSaveThresholdSeconds` (default: `5`). Sessions finalized below this threshold bypass database logging and achievement evaluations.

---

### 7. CI/CD & Keystore Signing Setup

Automated testing and release compilation is handled via GitHub Actions in `.github/workflows/build_and_release.yml`.

#### Workflow Highlights
1. **Trigger:** Every push/PR to `main`, version tags (`v*`), or manual execution via `workflow_dispatch`.
2. **Quality Gate:** Executes `flutter analyze` (zero warnings/errors) and `flutter test` (14/14 automated tests).
3. **Release Signing:** Automatically decodes the keystore and configures `key.properties` from repository secrets.
4. **Artifacts:** Builds and publishes:
   - `stillness-release-apk` (`build/app/outputs/flutter-apk/app-release.apk`)
   - `stillness-release-aab` (`build/app/outputs/bundle/release/app-release.aab`)
   - Drafts a GitHub Release when pushing a `v*` tag.

#### Required Repository Secrets
Add the following secrets to your GitHub repository (**Settings > Secrets and variables > Actions > Repository secrets**):

| Secret Name | Description | Example / Command |
|---|---|---|
| `KEYSTORE_BASE64` | Base64-encoded JKS/keystore file content | `base64 -w 0 upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Password for the keystore file | `myStorePassword123` |
| `KEY_ALIAS` | Alias name of the signing key in the keystore | `upload` or `stillness-key` |
| `KEY_PASSWORD` | Password for the key (optional if same as keystore) | `myKeyPassword123` |

#### Generating a Keystore (If Needed)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

Encode for GitHub Secrets:
- **Linux:** `base64 -w 0 upload-keystore.jks`
- **macOS:** `base64 -i upload-keystore.jks`

#### Local Build Fallback
If building locally without `key.properties` or environment variables, `android/app/build.gradle.kts` automatically falls back to `signingConfigs.debug`, ensuring local development and testing never break.
