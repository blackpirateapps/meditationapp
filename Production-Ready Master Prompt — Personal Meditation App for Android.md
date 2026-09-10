# Build a Production-Ready Personal Meditation App for Android

## 0. Mission

Build a complete, polished, production-ready meditation application for **Android phones and Android tablets** using **Flutter**.

This is a personal-use application intended to be used almost every day for years. It must feel like a **quiet, premium meditation instrument**, not a social wellness platform.

The application must be fully functional with no placeholders, fake data, unfinished screens, TODO implementations, mock-only interactions, or "coming soon" features.

The app must work **fully offline** for all core functionality.

The product philosophy is:

> **Before meditation: powerful customization.  
> During meditation: almost nothing.  
> After meditation: lightweight reflection and useful long-term history.**

The application should feel **Cupertino-inspired / Apple-like in visual polish**, while still behaving naturally and correctly as an Android application.

---

# 1. Non-Negotiable Product Decisions

Implement all of the following:

1. Meditation is the central feature.
2. The app supports multiple meditation types.
3. Breathing is one meditation type among many, not the identity of the entire application.
4. Guided meditation is supported through **visual, timed, audio/sound, and haptic guidance**, but **there is no spoken voice guidance**.
5. Users can configure meditation sessions extensively.
6. Users can create and customize their own meditation presets.
7. Built-in presets and user-created presets coexist.
8. The home screen is adaptive/personalized based on usage.
9. Meditation can continue correctly while the screen is off / device is locked.
10. Sleep is a first-class meditation category.
11. The app includes a small, high-quality built-in sound collection.
12. The app includes lightweight post-session journaling.
13. The app includes calendar/session history.
14. The app includes statistics and progress.
15. The app includes achievements/milestones.
16. Achievements are meaningful and subtle, not childish gamification.
17. There are no social features.
18. There is no account requirement.
19. There is no subscription system.
20. There is no cloud/backend dependency for core functionality.
21. The app must work without internet access.
22. Phone and tablet layouts must be intentionally designed, not merely stretched.
23. Dark mode must be fully supported.
24. The meditation screen must be visually minimal and calming.
25. The user must have substantial control over session behavior.

---

# 2. Technology Stack

Use:

- Flutter
- Dart
- Stable production versions of dependencies compatible with the project
- Drift + SQLite for persistent local storage
- Flutter's standard state-management approach already established by the project, or use a clean architecture with a predictable state-management solution if starting from scratch
- Android native integration where Flutter alone is insufficient
- Android foreground service/background execution for reliable ongoing meditation playback/timing where required
- Android local notifications
- Local bundled audio assets
- Responsive/adaptive Flutter layouts

Do not introduce unnecessary cloud services.

Do not add Firebase unless a specific Android capability genuinely requires it.

Do not create a custom backend.

Do not require user authentication.

All core data remains local.

---

# 3. High-Level Architecture

Use clean separation between:

```text
Presentation
    ↓
Application / Controllers
    ↓
Domain
    ↓
Repositories
    ↓
Drift database / Audio / Android integrations
```

Recommended conceptual modules:

```text
lib/
  app/
  core/
    theme/
    responsive/
    routing/
    accessibility/
    audio/
    notifications/
    platform/
  features/
    meditate/
    practices/
    meditation_session/
    history/
    progress/
    achievements/
    journal/
    sounds/
    settings/
  data/
    database/
    repositories/
    models/
```

Keep the architecture modular enough that additional meditation types and achievement rules can be added later without rewriting the entire application.

---

# 4. Core Navigation

Primary application destinations:

```text
Meditate
History
Progress
Settings
```

On phones:

- Use a clean bottom navigation/navigation bar or equivalent adaptive navigation.
- The selected destination must be visually clear.
- Navigation must respect Android back behavior.

On larger tablets:

- Use a navigation rail.
- Content should use the additional available space intelligently.
- Avoid excessive empty margins merely because the viewport is larger.

Do not create a separate permanent tab for "Practices" unless the adaptive UX benefits from it.

Practice discovery should be part of the Meditate experience.

---

# 5. Visual Design System

The visual language should be:

- Cupertino-inspired
- Premium
- Calm
- Minimal
- Spacious
- Typography-led
- Subtle
- Modern
- Highly polished

Do NOT make the application look like a generic meditation application.

Avoid:

- cliché wellness illustrations
- gradients everywhere
- inspirational quote overload
- cartoon graphics
- excessive cards
- badges covering the screen
- giant colorful CTAs
- visual noise
- excessive shadows
- excessive decorative elements

Use:

- generous whitespace
- carefully chosen typography hierarchy
- rounded controls where appropriate
- restrained separators
- subtle surfaces
- soft transitions
- excellent dark mode
- consistent iconography
- predictable spacing
- large touch targets
- smooth microinteractions

The UI should feel closer to a premium Apple utility/journal/reading application than a conventional health application.

Do not literally copy iOS UI. Preserve natural Android interaction patterns.

---

# 6. Theme System

Implement a real theme system, not ad-hoc colors.

Required modes:

```text
System
Light
Dark
```

Use semantic colors rather than hardcoded colors throughout the application.

Every screen, modal, sheet, icon, divider, text field, slider, graph, meditation screen, dialog, overlay, navigation element, and achievement state must respond correctly to the active theme.

Ensure:

- sufficient contrast
- accessibility
- dark-mode-specific surfaces
- no hardcoded light-only assumptions
- no unreadable low-contrast secondary text

The meditation screen may intentionally use an even darker visual treatment in Sleep mode.

---

# 7. Responsive Layout System

Support:

- Android phones
- small tablets
- large tablets
- portrait
- landscape

Define breakpoints centrally.

Do not rely on arbitrary `MediaQuery` checks scattered throughout the codebase.

Create reusable responsive layout primitives.

Examples:

```text
Phone
Single-column

Small tablet
Navigation rail + primary content

Large tablet
Navigation rail + multi-column content where useful
```

Tablet UI must feel intentionally designed.

---

# 8. Meditate Home Screen

This is the main screen.

The home screen should adapt based on the user's actual usage.

Do not permanently hard-code the same ordering for every user.

Use local usage data such as:

- recently used practices
- most frequently used practices
- most recently completed sessions
- time-of-day patterns
- favorite presets
- manually pinned presets

The app should surface relevant practices while still allowing discovery.

Example conceptual layout:

```text
Good evening

Continue
────────────────────

Evening Meditation
20 minutes
Open Awareness

[ Start ]


Your Practices
────────────────────

10 min
Breathing

20 min
Open Awareness

30 min
Sleep

5 min
Reset


Recently Used
────────────────────

Body Scan
15 minutes

Box Breathing
10 minutes
```

Actual text and arrangement should adapt dynamically.

Important:

- Do not invent fake personalization.
- Personalization must be based on real local history.
- Users should be able to pin/favorite practices.
- Users should be able to reorder or remove displayed shortcuts if useful.
- Empty states must be handled gracefully for new users.

For a brand-new user, provide sensible built-in practices.

---

# 9. Built-In Meditation Types

Implement these initial meditation types:

### 9.1 Breathing

Supports configurable breathing phases:

```text
Inhale
Hold
Exhale
Hold
```

Each phase can be independently configured.

Examples:

- Box breathing
- Equal breathing
- 4–7–8
- Custom breathing

The breathing animation must derive its timing dynamically from the configured phases.

Do not hardcode animations to one breathing method.

---

### 9.2 Open Awareness

Primarily silent.

Can optionally include:

- periodic visual reminder
- interval bell
- background sound
- haptic cue

The user should be able to turn all guidance off.

---

### 9.3 Body Scan

Use visual/timed prompts rather than spoken instructions.

Example conceptual sequence:

```text
Feet
Lower legs
Knees
Thighs
Abdomen
Chest
Hands
Arms
Shoulders
Neck
Face
Whole body
```

The user should be able to configure duration.

Prompts should be calm and unobtrusive.

---

### 9.4 Focus

Use a central focus point / minimal visual target.

Optional periodic reminder:

```text
Return to your focus
```

Allow the user to disable this entirely.

---

### 9.5 Mantra

A visual mantra meditation.

The user can define:

```text
Mantra text
Display frequency
Optional haptic cue
Optional interval sound
```

No spoken mantra feature is required.

---

### 9.6 Walking

A walking meditation timer.

Support:

- total duration
- interval bells
- optional step/phase prompts
- optional background sound

Do not require GPS.

Do not turn this into a fitness tracker.

---

### 9.7 Sleep

Sleep is a first-class practice category.

Features:

- 10/20/30/45/60 minute presets
- custom duration
- background sounds
- no interval bell by default
- fade-out
- screen dimming
- nearly-black visual treatment
- screen-off playback
- reliable background operation

Sleep sessions must not force the user to interact with the screen after starting.

---

### 9.8 Silent Timer

A completely generic meditation timer:

- duration
- preparation
- interval bell
- ending bell
- optional background audio
- optional haptics
- screen behavior

This is the simplest and most flexible meditation type.

---

# 10. Practice / Preset Model

A meditation practice must be represented as data/configuration rather than a hardcoded widget.

A practice should conceptually support:

```text
id
name
description
type
duration
preparationDuration
guidanceMode
visualGuidance
hapticGuidance
intervalBellEnabled
intervalBellInterval
intervalBellSound
intervalBellVolume
startSound
endingSound
endingSoundEnabled
backgroundSound
backgroundSoundVolume
fadeInDuration
fadeOutDuration
screenBehavior
breathingConfiguration
bodyScanConfiguration
mantraConfiguration
walkingConfiguration
createdAt
updatedAt
isBuiltIn
isFavorite
useCount
lastUsedAt
```

Only applicable properties need to be serialized/stored for each practice type.

Use a robust schema rather than putting arbitrary untyped JSON everywhere.

---

# 11. Practice Creation / Editing

Provide a complete practice editor.

Basic section:

```text
Name
Type
Duration
```

Behavior:

```text
Preparation
Guidance
Interval bells
Ending bell
Haptics
```

Sound:

```text
Background sound
Background volume
Bell sound
Bell volume
Fade in
Fade out
```

Display:

```text
Screen behavior
Visual guidance
Brightness behavior
```

Type-specific configuration appears dynamically.

Example breathing configuration:

```text
Inhale
Hold
Exhale
Hold
```

Use progressive disclosure:

- frequently changed controls visible first
- advanced controls behind an expandable "Advanced" section

Do not hide capabilities merely to simplify implementation.

---

# 12. Quick Start

Users must be able to start a meditation without creating a preset.

Provide a quick configuration flow:

```text
Duration
Background sound
Bell
Start
```

Advanced configuration remains available.

The last-used configuration may be remembered where sensible.

---

# 13. Active Meditation Experience

This is the most important screen in the app.

During meditation, the interface should become nearly invisible.

By default show only what is essential.

Conceptual:

```text
                    08:42


                       ○

                    INHALE


                   10:00


                  [ Pause ]
```

The actual presentation varies by practice type.

Examples:

Breathing:

```text
INHALE
central breathing animation
remaining time
```

Open awareness:

```text
20:00

minimal visual anchor
```

Body scan:

```text
Shoulders
12:40
```

Mantra:

```text
[ mantra ]
10:20
```

Sleep:

```text
29:48

·
```

No persistent bottom navigation should remain on this screen.

---

# 14. Controls During Meditation

The meditation screen should initially hide secondary controls.

Tapping the screen should reveal controls.

Controls include:

```text
Pause
End
Sound
Brightness
```

Additional controls can be accessible through a secondary sheet.

Controls must not accidentally end a meditation.

Ending a session should use a deliberate confirmation step unless the user has disabled confirmation.

---

# 15. Pause Behavior

Pause must:

- stop visual session progression
- pause background audio where appropriate
- preserve elapsed/remaining state
- preserve current breathing phase
- preserve current practice stage
- preserve interval timers
- resume exactly where paused

Do not restart the session from the beginning.

---

# 16. End Session Behavior

When the user explicitly ends a session:

show:

```text
End meditation?

Your current progress will be recorded.

[ Continue meditating ]
[ End session ]
```

Use clear destructive-action styling without excessive visual drama.

Decide and document whether partially completed sessions count toward statistics. Recommended behavior:

- completed sessions count fully
- partially completed sessions are stored separately with actual elapsed duration
- achievements requiring completed sessions should generally use completed sessions only
- total meditation time may include partially completed sessions if at least a meaningful minimum duration was completed

Make this behavior consistent everywhere.

---

# 17. Screen-Off / Background Operation

This is a core production requirement.

Meditation must continue correctly when:

- screen turns off
- device is locked
- user switches apps
- Android puts the application into the background

Where required, use Android native foreground-service/background-audio mechanisms.

Requirements:

- audio continues reliably
- timer state remains correct
- ending sound plays
- session is recorded
- system notification is correct
- notification allows appropriate controls
- no unnecessary battery drain
- app recovers gracefully from Android process pressure where feasible

Handle Android audio focus correctly.

Handle interruptions such as:

- phone calls
- other media playback
- Bluetooth audio changes
- headphone disconnect
- audio focus changes

Do not assume audio output will always remain unchanged.

---

# 18. Audio System

Implement a centralized audio manager.

It must support:

- background looping audio
- meditation bells
- preparation sound
- interval sounds
- ending sounds
- volume control
- fade in
- fade out
- audio focus
- interruption handling
- stopping/cleanup
- screen-off playback

Avoid scattered audio code across screens.

The audio engine must be reusable.

---

# 19. Built-In Sound Library

Ship a small local sound library.

Initial categories:

### Nature

- Rain
- Ocean
- Forest
- Fireplace

### Noise

- Brown noise
- Pink noise
- White noise

### Ambient

- Soft ambient drone
- Deep ambient sound

### Silent

- None

All assets must be locally bundled or otherwise legally redistributable.

Do not use copyrighted audio without appropriate rights.

The settings/practice editor should allow:

- select sound
- volume
- preview
- loop
- fade in
- fade out

Audio previews must stop cleanly when navigating away.

---

# 20. Haptics

Support optional haptic cues.

Examples:

- meditation start
- meditation end
- breathing phase transition
- interval marker

Haptics must be:

- subtle
- optional
- disabled automatically where system restrictions make them unsuitable
- respectful of Android device settings

Do not vibrate continuously.

---

# 21. Preparation Period

Before a session begins, optionally show a preparation period.

Example:

```text
Get comfortable

Starting in

3

```

Allow:

```text
0 sec
5 sec
10 sec
15 sec
30 sec
60 sec
Custom
```

During preparation:

- no session time should be counted as meditation time unless explicitly designed otherwise
- optional background sound can fade in
- optional start bell may play

---

# 22. Timing Engine

Do not base session timing on repeated UI frame callbacks alone.

Use a robust elapsed-time model based on timestamps/durations.

The timer must remain accurate when:

- app is backgrounded
- display turns off
- UI rebuilds
- device is under load
- audio playback changes
- the user pauses/resumes

The UI should derive its state from the authoritative session clock.

Handle clock changes safely.

Do not simply increment an integer every second.

---

# 23. Meditation Completion

After a session:

```text
Finished

20 minutes
Open Awareness

How do you feel?

😌   🙂   😐   😕   😣

Add a note

[                         ]

[ Done ]
```

Keep this lightweight.

No mandatory journaling.

The user should be able to dismiss immediately.

---

# 24. Lightweight Journal

Each completed meditation can optionally have:

- mood
- note
- session metadata

Mood should use a small set of understandable choices.

Text entry:

- multiline
- simple
- comfortable keyboard experience
- autosave draft if practical
- no rich-text editor required

Journal text remains local.

Users can later view it from session history.

---

# 25. History

History must combine:

1. calendar
2. session list
3. individual session details

Top-level summary:

```text
September 2026

27 sessions
4h 32m
10m average
18 active days
```

Calendar:

```text
M T W T F S S
● ●   ●   ●
●   ● ●
● ● ●
```

Use accessible indicators rather than relying on color alone.

Session list:

```text
Today
20 min · Open Awareness

Yesterday
10 min · Breathing

Sep 8
30 min · Sleep
```

Session detail should show:

```text
Date/time
Duration
Practice
Type
Completed/partial
Mood
Note
Sound
Meditation settings
```

Do not expose unnecessary implementation details.

---

# 26. History Filtering

Provide practical filters/sorting:

- date
- meditation type
- duration range
- completed/partial

Search is optional and should not be implemented at the expense of core quality.

Do not create complicated filtering UI.

---

# 27. Progress Screen

Progress should show meaningful long-term information without becoming a fitness dashboard.

Sections:

### Overview

```text
Total time
Total sessions
Average session duration
Days meditated
```

### Time period

Allow:

```text
Week
Month
Year
All time
```

### Calendar consistency

Show meditation days.

### Activity visualization

Use a restrained chart.

Possible data:

- meditation minutes per day
- sessions per week
- total time by meditation type

Charts must work in light/dark themes and remain readable.

---

# 28. Meditation Type Breakdown

Show useful breakdowns:

```text
Breathing        3h 20m
Open Awareness   5h 10m
Sleep            8h 40m
Body Scan        2h 15m
```

Avoid turning the screen into excessive statistical analysis.

---

# 29. Achievements

Achievements are required.

They must be based on real activity.

Avoid:

- XP
- levels
- coins
- fake rewards
- confetti
- aggressive streak mechanics

Use quiet milestones.

Initial achievements should include things such as:

```text
First Breath
Completed your first meditation.

Ten Sessions
Completed 10 meditation sessions.

One Hour
Accumulated one hour of meditation.

Five Hours
Accumulated five hours.

Ten Hours
Accumulated ten hours.

Twenty-Five Sessions
Completed 25 sessions.

Fifty Sessions
Completed 50 sessions.

Seven Days
Meditated on seven different days.

Thirty Days
Meditated on thirty different days.

Early Bird
Completed an early-morning session.

Long Sit
Completed a session of at least 30 minutes.

Explorer
Tried at least five meditation types.

Sleep Practice
Completed ten sleep sessions.
```

Design an achievement engine where definitions are data-driven.

Each achievement should have:

```text
id
title
description
category
threshold
progress
unlockedAt
```

Achievements should automatically update after relevant events.

Do not require users to manually open Progress before achievement progress updates.

When an achievement unlocks, show a subtle notification/toast/sheet that does not interrupt a meditation session.

Never show an achievement overlay during meditation.

---

# 30. Streaks

Streaks may be displayed as a simple statistic, but must not dominate the experience.

Example:

```text
Current streak
6 days
```

Also show:

```text
Longest streak
18 days
```

Do not punish missed days with alarming messaging.

Do not frame meditation as an obligation.

---

# 31. Practice Favorites / Pinning

Allow users to:

- favorite a practice
- pin a practice to the Meditate home screen
- remove from favorites
- duplicate an existing practice
- edit user-created practices
- delete user-created practices

Built-in practices should not be accidentally deleted.

For built-in practices:

```text
Customize
```

creates or saves a customized copy rather than mutating the global built-in definition.

---

# 32. Practice Usage Intelligence

Track lightweight local metadata:

```text
useCount
lastUsedAt
favorite
pinned
createdAt
updatedAt
```

Use this to determine adaptive home-screen ordering.

A reasonable ranking strategy can consider:

```text
Pinned
Favorite
Recent use
Frequency of use
Time-of-day relevance
```

Do not make recommendations that feel invasive or unpredictable.

The user must remain in control.

---

# 33. Time-of-Day Personalization

The app may use the current time to improve ordering.

Example:

Morning:

```text
Morning practice
Breathing
Focus
```

Evening:

```text
Evening practice
Open Awareness
Sleep
```

However:

- never require location
- never require internet
- do not infer sensitive personal information
- use only local usage patterns and time-of-day logic

---

# 34. Settings

Create a complete settings area.

Recommended sections:

## Appearance

```text
Theme
System
Light
Dark
```

## Meditation

```text
Default preparation
Default duration
Default ending behavior
Default haptics
Default screen behavior
```

## Audio

```text
Default background volume
Default bell volume
Fade behavior
```

## Reminders

```text
Off
Daily
Weekdays
Custom
```

## Notifications

```text
Enable reminders
Permission state
```

## Display

```text
Keep screen awake
Dim during meditation
Sleep mode screen behavior
```

## Data

```text
Export data
Import data
Delete all data
```

## About

```text
Version
Licenses
Privacy
```

Include a clear destructive-data confirmation flow.

---

# 35. Notifications and Reminders

Notifications are optional.

Allow:

```text
Off
Daily
Weekdays
Custom schedule
```

Allow the user to choose time.

Use calm copy.

Example:

```text
Take a moment

Your meditation is ready.
```

Do not send excessive reminders.

Do not notify after every session.

Do not create notifications without user permission.

Handle Android notification permission correctly.

---

# 36. Android Permissions

Request only permissions actually required.

Likely permissions may include:

- notification permission
- foreground service/audio-related permissions where required by Android version
- vibration only where necessary

Do not request:

- location
- contacts
- camera
- microphone
- storage access

unless a future feature genuinely requires them.

There is explicitly **no voice recording** feature.

---

# 37. Data Model

Create a normalized local database.

Core tables should include at minimum:

### Practices

```text
id
name
type
configuration
createdAt
updatedAt
isBuiltIn
isFavorite
isPinned
useCount
lastUsedAt
```

### Sessions

```text
id
practiceId
startedAt
completedAt
plannedDuration
actualDuration
status
mood
note
```

Status:

```text
completed
partial
cancelled
```

### Session Configuration Snapshot

Store the effective settings used by a session so historical data remains correct even if the practice is later edited.

### Achievements

```text
id
unlockedAt
```

Achievement definitions can remain code/data driven; unlocked state belongs in the DB.

### App Settings

Store user preferences cleanly.

### Optional Daily Statistics

Use derived/aggregated statistics only where they materially improve performance. Do not create redundant data unless needed.

---

# 38. Historical Integrity

This is important.

If a user edits:

```text
Evening Meditation
20 min
```

to:

```text
Evening Meditation
30 min
```

previous sessions must still show the actual configuration/session information from when they occurred.

Never recalculate historical session details from today's practice definition.

Store a session configuration snapshot.

---

# 39. Data Export / Import

Implement local export/import.

Preferred format:

```text
JSON archive
```

containing:

- practices
- sessions
- journal entries
- achievements
- settings where appropriate

Audio assets do not need to be included unless practical.

Import must validate schema/version.

Use migrations.

Never blindly import malformed data into the live database.

Allow backup restoration without corrupting existing data.

Provide clear overwrite/merge semantics.

---

# 40. Database Migrations

Use proper Drift migrations.

Never delete user data merely because the schema changes.

Version the local database.

Add tests for every migration.

---

# 41. Offline-First Requirement

The application must remain completely usable without internet access.

Do not display errors because there is no internet.

The following must all work offline:

- start meditation
- breathing
- timer
- sounds
- sleep mode
- history
- journal
- statistics
- achievements
- reminders already configured locally
- settings
- data export/import

---

# 42. Accessibility

Implement accessibility seriously.

Requirements:

- minimum comfortable touch targets
- semantic labels
- accessible icons
- meaningful screen-reader descriptions
- sufficient text contrast
- support larger font sizes
- avoid information conveyed by color alone
- respect system reduced-motion preferences where practical
- avoid flashing animations
- ensure meditation controls remain discoverable to accessibility services

Breathing animations must have accessible textual alternatives.

Do not make the app unusable with animations disabled.

---

# 43. Motion Design

Animations should be calm.

Use:

- fades
- gentle scale
- subtle slide transitions
- breathing expansion/contraction
- smooth timer changes

Avoid:

- bouncing
- elastic overshoot
- flashy transitions
- confetti
- abrupt movement

Respect reduced-motion preferences.

---

# 44. Sleep Visual Behavior

Sleep sessions require special treatment.

When Sleep mode starts:

- optionally dim the screen
- use very dark surfaces
- minimize controls
- avoid bright white text where possible while retaining accessibility
- allow screen to turn off normally
- continue audio in background
- fade audio toward the end if configured

Do not force the display to stay awake unless the user explicitly chooses that behavior.

---

# 45. Keep-Screen-Awake Behavior

Allow a global/default preference and per-session override.

Options:

```text
System default
Keep awake
Allow screen to sleep
```

For meditation sessions where keeping the screen awake is enabled, prevent display sleep appropriately.

Always allow screen-off operation when the user chooses it.

---

# 46. Error Handling

Every subsystem must fail gracefully.

Examples:

Audio asset unavailable:

- show a meaningful error
- continue session silently if safe
- do not crash

Notification scheduling fails:

- keep meditation functionality working
- surface the issue in Settings where useful

Database issue:

- never silently destroy data
- provide recoverable error handling

Background playback interrupted:

- update session state appropriately
- recover when possible

Import malformed:

- reject safely
- never corrupt existing data

---

# 47. App Lifecycle Handling

Handle:

- app launch
- app resume
- app background
- app termination
- configuration changes
- screen rotation
- tablet resizing
- multi-window where practical

The current meditation session must remain coherent across lifecycle events.

---

# 48. Orientation

Support:

- portrait
- landscape

Do not hard-lock orientation unless a specific screen genuinely requires it.

The meditation screen must adapt gracefully.

Tablet landscape should feel especially polished.

---

# 49. Android Back Behavior

Implement predictable back behavior.

Examples:

While editing practice:

```text
Back
→ save/discard confirmation if unsaved
```

During meditation:

```text
Back
→ do NOT immediately destroy session
→ reveal/confirm exit behavior
```

While a bottom sheet is open:

```text
Back
→ dismiss sheet first
```

Do not allow accidental loss of meditation sessions.

---

# 50. First-Run Experience

Do not create a huge onboarding carousel.

On first launch, provide a lightweight introduction.

Goal:

Get the user into their first meditation quickly.

Provide sensible initial built-in practices.

Potential first-launch view:

```text
A quieter place to meditate.

Choose a practice
or start with a simple timer.

[ Begin ]
```

Do not require account creation.

Do not require internet.

Do not require notification permission immediately unless necessary.

Request optional permissions contextually when the feature is first enabled.

---

# 51. Initial Built-In Presets

Ship sensible built-in presets such as:

```text
Morning Breathing
10 min
Breathing

Quiet Focus
10 min
Focus

Open Awareness
20 min
Open Awareness

Body Scan
15 min
Body Scan

Evening Reset
10 min
Open Awareness

Sleep
30 min
Sleep

Silent Meditation
20 min
Silent Timer

Walking Meditation
15 min
Walking
```

These are starting defaults, not mandatory fixed content.

Users can customize/duplicate them.

---

# 52. Practice Discovery UX

The practice discovery UI should not feel like an app-store catalog.

Use clean sections such as:

```text
For You
Built-in Practices
Your Practices
```

Keep descriptions short.

Avoid unnecessary illustrations.

---

# 53. Session Resume

Decide behavior if the app is reopened during an active meditation.

If a session remains active:

```text
Continue meditation
```

Restore the session accurately.

If the process was killed, use persisted session metadata to determine whether a session can be resumed.

Never silently create duplicate sessions.

---

# 54. Session Persistence

At session start:

- create session record

During meditation:

- persist important state periodically and at lifecycle boundaries

On completion:

- finalize the session
- update usage statistics
- update achievements
- update practice usage metadata

Use transactions where necessary.

---

# 55. Statistics Consistency

All statistics must be derived from the same authoritative session data.

Do not allow:

```text
History says 27 sessions
Progress says 25
Achievement engine says 28
```

Create a shared statistics/repository layer.

Test edge cases:

- partial sessions
- midnight crossing
- month transitions
- year transitions
- time zone changes
- edited practices
- imported data

---

# 56. Time Zones and Dates

Store timestamps consistently.

Use local calendar presentation for the user.

Be careful with:

- sessions crossing midnight
- daylight saving changes
- system timezone changes
- year boundaries

Do not classify sessions solely by duration or local date stored as a string.

---

# 57. Performance

The application must remain smooth with years of history.

The architecture should comfortably handle:

- thousands of sessions
- hundreds of practices
- years of journal entries

Do not load the entire database into memory unnecessarily.

Use:

- indexed queries
- pagination
- lazy lists
- efficient aggregate queries
- reactive DB streams where appropriate

Charts should not requery unnecessarily.

---

# 58. Animations and Rendering Performance

The breathing animation and meditation timer must maintain smooth performance.

Avoid rebuilding the entire screen every animation frame.

Separate:

- animation state
- timer state
- static UI
- audio state

Use performant Flutter animation primitives.

---

# 59. Battery Usage

This is a personal daily-use application.

Do not keep unnecessary timers, isolates, animations, location services, or wake locks running.

During screen-off meditation:

- only the necessary background/audio/timing infrastructure should remain active.

When a session ends:

- all temporary resources must be released immediately.

---

# 60. Security / Privacy

Because meditation notes and history can be personally meaningful:

- keep data local
- do not transmit session data
- do not add analytics SDKs by default
- do not collect user behavior remotely
- do not embed advertising
- clearly explain local data handling

No account should be required.

---

# 61. Privacy Screen

Include a simple in-app privacy explanation:

```text
Your meditation data stays on this device.

The app does not require an account and does not need
an internet connection for core functionality.
```

Only claim behavior that is actually true in the implementation.

---

# 62. Testing Requirements

Write real automated tests.

At minimum:

### Unit tests

- timer calculations
- pause/resume
- elapsed-time calculations
- breathing phase transitions
- practice serialization/deserialization
- achievement conditions
- statistics calculations
- date grouping
- streak calculations
- migration logic

### Widget tests

- home state
- practice editor
- active meditation controls
- completion screen
- history
- progress
- settings
- empty states
- dark mode
- large text

### Integration tests

At minimum:

- create practice → start → pause → resume → complete
- complete meditation → journal → history
- achievement unlock
- background/screen-off flow where testable
- notification scheduling
- export/import
- database migration

---

# 63. Test Scenarios That Must Not Be Ignored

Explicitly test:

1. Start 10-minute session.
2. Lock screen after 20 seconds.
3. Unlock after several minutes.
4. Confirm timer remains accurate.

Also:

1. Pause during breathing phase.
2. Wait.
3. Resume.
4. Confirm correct phase/state.

Also:

1. Start meditation.
2. Receive phone call/audio interruption.
3. Handle audio focus.
4. Resume correctly.

Also:

1. Rotate phone.
2. Continue session.

Also:

1. Switch portrait → landscape tablet.
2. Continue session.

Also:

1. Kill and reopen app where supported.
2. Recover session safely.

Also:

1. Create journal note.
2. Verify persistence after restart.

Also:

1. Edit a practice.
2. Verify old session remains historically unchanged.

Also:

1. Reach achievement threshold.
2. Verify exactly one unlock record.

---

# 64. Empty States

Every major data-driven screen needs a polished empty state.

Examples:

History:

```text
No meditations yet.

Your sessions will appear here
after your first practice.

[ Start meditating ]
```

Progress:

```text
Your progress starts here.

Complete a meditation to begin.
```

Journal:

```text
No reflections yet.
```

Keep empty states concise.

---

# 65. Loading States

Do not use pointless full-screen spinners.

Use:

- immediate local data where possible
- lightweight placeholders only where actual loading exists
- smooth transitions

Never use blur-based loading.

Never hide already-available content behind unnecessary loading overlays.

---

# 66. Sound Preview

Sound selection must allow preview.

Rules:

- preview can be started/stopped
- navigating away stops preview
- preview never overlaps with active meditation audio
- volume respects selected preview volume
- preview resources are disposed correctly

---

# 67. Favorites / Personalization

The user should be able to quickly mark a practice favorite.

Pinned practices should appear first in appropriate sections.

The UI should not become cluttered with duplicate controls for pin/favorite/edit.

Use contextual menus where appropriate.

---

# 68. Data Deletion

Provide:

```text
Delete all meditation data
```

This must be a destructive operation with confirmation.

Explain exactly what will be deleted:

- sessions
- journal entries
- custom practices
- achievements
- local statistics
- settings if applicable

Built-in practice definitions should remain available unless the user chooses to reset the entire application.

Do not delete data accidentally.

---

# 69. Reset App

Provide a separate reset option if useful:

```text
Reset app
```

Distinguish:

```text
Delete meditation history
```

from:

```text
Reset all settings
```

from:

```text
Delete all data
```

Do not combine dangerous actions ambiguously.

---

# 70. No Placeholder Content

Do not write:

```text
TODO
Coming soon
Placeholder
Mock data
Lorem ipsum
Fake statistics
Fake achievements
Stub audio
```

Any feature visible in the production UI must work.

If a feature cannot be implemented correctly, do not pretend it is finished. Resolve the implementation rather than hiding the issue.

---

# 71. No Fake Personalization

Do not display:

```text
Recommended for you
```

unless the recommendation is based on actual local data or a clearly defined deterministic rule.

New-user state must be explicitly handled.

---

# 72. No Unnecessary Backend

Do not introduce:

- Firebase
- Supabase
- custom API
- cloud database
- login server
- analytics backend

The app is local-first by design.

---

# 73. Code Quality

Code must be:

- strongly typed
- null-safe
- modular
- documented where behavior is non-obvious
- testable
- maintainable

Avoid giant widgets.

Avoid duplicating business rules.

Avoid putting business logic directly in UI widgets.

Use reusable components for:

- cards/surfaces
- buttons
- typography
- practice rows
- session rows
- charts
- settings rows
- sheets
- dialogs

---

# 74. Design System Components

Create reusable design primitives for:

```text
AppSurface
AppCard
AppButton
AppIconButton
AppSectionHeader
AppListRow
AppSlider
AppSegmentedControl
AppSheet
AppDialog
AppEmptyState
AppStat
AppProgressIndicator
```

Do not allow random one-off styling to proliferate.

---

# 75. Typography

Choose a premium, highly readable typography system.

Use a deliberate hierarchy:

```text
Display
Title
Section title
Body
Secondary
Caption
```

Typography must work well on both phone and tablet.

Support dynamic type/font scaling.

Do not use tiny text to fit more content.

---

# 76. Icons

Use one consistent icon family.

Do not mix random icon packs.

Icons must have semantic labels where interactive.

Do not use icons when text is significantly clearer.

---

# 77. Tablet-Specific UX

For large screens, use available space for meaningful relationships.

Examples:

### Practice browser

```text
Navigation | Practice list | Practice details
```

### History

```text
Calendar | Sessions | Session detail
```

### Settings

```text
Settings categories | Settings detail
```

Do not force tablet users through narrow phone-sized cards.

---

# 78. Meditation Screen on Tablet

Do not unnecessarily center everything in a giant empty tablet viewport.

Use controlled maximum widths so the experience remains intimate.

The central meditation visualization should remain visually focused.

---

# 79. Settings UX on Tablet

Use a split layout.

Example:

```text
Appearance
Meditation
Audio
Notifications
Display
Data
About
```

with the selected category's options beside it.

On phone, use normal hierarchical navigation.

---

# 80. History UX on Tablet

Use a multi-column layout where appropriate.

For example:

```text
Calendar      Sessions             Details
September     Today                Open Awareness
              Yesterday            20 minutes
              Sep 8                 ...
```

Selecting an item updates the detail panel without forcing unnecessary navigation.

---

# 81. Progress UX on Tablet

Use the width for:

```text
Summary statistics
Calendar/activity
Meditation-type breakdown
Achievements
```

Avoid simply making every card wider.

---

# 82. Personalization Settings

Do not expose complicated personalization tuning to the user initially.

The system should mostly adapt automatically.

Provide basic controls such as:

```text
Show recently used
Show favorites
Show pinned
```

The underlying ranking should remain automatic.

---

# 83. Achievement Presentation

Achievements should have:

- clean icon
- title
- concise description
- locked/unlocked visual state
- progress where meaningful

Avoid giant trophy cabinets.

A subtle grid/list is enough.

---

# 84. Haptic / Sound / Visual Synchronization

For breathing meditation, phase transitions should stay synchronized across:

- animation
- text
- haptic cue
- optional sound

All must derive from the same authoritative breathing phase clock.

Do not independently run three timers that can drift apart.

---

# 85. Audio + Timer Synchronization

Audio cues should be scheduled from authoritative session state.

Do not assume the UI frame is the timing source.

Handle small execution delays gracefully.

---

# 86. Practice Duplication

Provide:

```text
Duplicate
```

for custom practices.

Duplicated practices should receive:

- new ID
- new timestamps
- copied configuration
- independent favorite/pin/use metadata

Do not accidentally mutate the original.

---

# 87. Built-In Practice Customization

For a built-in practice, the user should see:

```text
Customize
```

rather than unrestricted destructive editing.

Create a custom version or otherwise preserve the built-in original.

---

# 88. Export Format

Create a documented versioned export schema.

Example:

```json
{
  "schemaVersion": 1,
  "exportedAt": "...",
  "practices": [],
  "sessions": [],
  "achievements": [],
  "settings": []
}
```

Do not expose internal database implementation details unnecessarily.

---

# 89. Import Validation

Validate:

- schema version
- required fields
- enum values
- timestamps
- IDs
- duration ranges
- malformed notes
- unsupported future versions

Never overwrite production data before validating the complete file.

---

# 90. Release Readiness

Before declaring the app complete:

- remove debug logging
- remove unused imports
- remove dead code
- verify production assets
- verify Android app label
- verify icons
- verify splash screen
- verify notification channel behavior
- verify background service behavior
- verify audio focus behavior
- verify dark mode
- verify tablets
- verify landscape
- verify accessibility
- verify release build
- verify app restart behavior
- verify data migration
- verify export/import
- verify no crashes in core flows

---

# 91. Android Release Configuration

Prepare the project for a real Android release.

Implement correctly:

- application ID
- app name
- launcher icon
- adaptive icon
- splash screen
- release build configuration
- minimum supported Android version appropriate for modern Android
- target SDK appropriate for the current supported Android ecosystem
- notification channels
- foreground-service requirements
- audio behavior
- backup/data handling consistent with privacy expectations

Do not make unsupported assumptions about Android API behavior. Use current Android-compatible APIs and document any version-specific implementation.

---

# 92. Logging

Use structured logging during development.

Production builds should not flood logs with:

- every timer tick
- every animation frame
- sensitive journal content
- unnecessary session data

Never log private journal text.

---

# 93. Privacy-Sensitive Data Handling

Treat these as private:

- journal text
- mood
- meditation history

Do not include them in debug analytics or logs.

---

# 94. Core User Journeys That Must Feel Excellent

Polish these flows especially:

### Journey A — First meditation

```text
Launch
→ Meditate
→ choose simple practice
→ configure
→ start
→ meditate
→ finish
→ optional mood/note
→ history
```

### Journey B — Daily repeat

```text
Launch
→ adaptive recommended preset
→ Start
→ meditate
```

Target this flow to require almost no cognitive effort.

### Journey C — Custom practice

```text
Meditate
→ create
→ configure everything
→ save
→ start
```

### Journey D — Sleep

```text
Meditate
→ Sleep
→ choose sound/duration
→ start
→ screen off
→ audio continues
→ fades out
→ completion stored
```

### Journey E — Long-term review

```text
Progress
→ statistics
→ calendar
→ achievements
→ history
```

---

# 95. UX Priority Hierarchy

When making implementation decisions, prioritize in this order:

1. Reliability
2. Meditation experience
3. Ease of starting a session
4. Audio/background correctness
5. Data integrity
6. Accessibility
7. Tablet quality
8. Customization depth
9. Progress/history polish
10. Decorative visual effects

Never sacrifice session correctness for visual polish.

---

# 96. Definition of "Production Ready"

The implementation is only complete when:

- all major screens exist
- all described interactions work
- meditation timing is reliable
- background/screen-off behavior works
- audio works
- custom practices work
- history is persistent
- journal is persistent
- statistics are consistent
- achievements work
- reminders work
- tablet layouts work
- dark mode works
- accessibility is addressed
- migrations are implemented
- export/import work
- no placeholder functionality remains
- automated tests cover critical logic
- release build succeeds

---

# 97. Required Implementation Process

Follow this implementation sequence:

## Phase 1 — Foundation

Build:

- project architecture
- theme system
- responsive system
- navigation
- Drift database
- repositories
- settings infrastructure

## Phase 2 — Practice Engine

Build:

- practice model
- built-in practices
- custom practice creation/editing
- favorites/pinning
- adaptive ordering

## Phase 3 — Meditation Engine

Build:

- authoritative session clock
- preparation
- pause/resume
- meditation phase engine
- breathing engine
- visual guidance
- haptics
- completion
- persistence

## Phase 4 — Audio / Android

Build:

- audio manager
- background audio
- foreground service where required
- notifications
- audio focus
- screen-off behavior
- sleep mode

## Phase 5 — History / Journal

Build:

- session history
- calendar
- detail view
- journal
- mood
- filtering

## Phase 6 — Progress / Achievements

Build:

- statistics
- charts
- streaks
- achievement engine
- achievement UI

## Phase 7 — Settings / Data

Build:

- reminders
- display behavior
- audio settings
- export/import
- deletion/reset
- privacy/about

## Phase 8 — Tablet / Accessibility / Polish

Complete:

- tablet layouts
- landscape
- accessibility
- reduced motion
- visual polish
- transitions
- edge cases

## Phase 9 — Testing / Release

Complete:

- unit tests
- widget tests
- integration tests
- migration tests
- release build
- crash/error review
- performance review

---

# 98. Agent Rules

The coding agent must follow these rules:

### Rule 1
Do not stop after scaffolding.

Implement the actual complete application.

### Rule 2
Do not use placeholders.

### Rule 3
Do not leave major architectural decisions unresolved.

### Rule 4
Do not ask the user to manually implement essential functionality that the agent can implement.

### Rule 5
When a library/API has limitations, adapt the implementation rather than pretending a feature works.

### Rule 6
Keep business logic outside widgets.

### Rule 7
Do not duplicate timer, statistics, achievement, or audio logic.

### Rule 8
Preserve historical data integrity.

### Rule 9
All user-facing features must be functional.

### Rule 10
Do not overengineer with cloud/backend infrastructure.

### Rule 11
Do not introduce unnecessary dependencies.

### Rule 12
Prefer stable, maintained packages.

### Rule 13
Run formatting, static analysis, unit tests, widget tests, and integration tests.

### Rule 14
Fix errors rather than suppressing them.

### Rule 15
Do not weaken type safety to get around compilation problems.

---

# 99. Final Acceptance Checklist

Before declaring success, verify the following:

## Product

- [ ] Meditation is the central experience
- [ ] Multiple meditation types
- [ ] Breathing works
- [ ] Open awareness works
- [ ] Body scan works
- [ ] Focus works
- [ ] Mantra works
- [ ] Walking works
- [ ] Sleep works
- [ ] Silent timer works
- [ ] Custom practices work

## Meditation Engine

- [ ] Preparation
- [ ] Accurate timing
- [ ] Pause
- [ ] Resume
- [ ] End confirmation
- [ ] Completion
- [ ] Screen-off operation
- [ ] Background operation
- [ ] Lifecycle handling

## Audio

- [ ] Built-in sounds
- [ ] Looping
- [ ] Volume
- [ ] Fade in
- [ ] Fade out
- [ ] Bells
- [ ] Audio focus
- [ ] Interruptions
- [ ] Background playback

## Personalization

- [ ] Favorites
- [ ] Pinning
- [ ] Recently used
- [ ] Usage counts
- [ ] Adaptive home screen
- [ ] Time-aware ordering where appropriate

## History

- [ ] Calendar
- [ ] Sessions
- [ ] Details
- [ ] Mood
- [ ] Journal
- [ ] Filtering
- [ ] Historical configuration snapshots

## Progress

- [ ] Weekly statistics
- [ ] Monthly statistics
- [ ] Yearly statistics
- [ ] All-time statistics
- [ ] Type breakdown
- [ ] Charts
- [ ] Streaks

## Achievements

- [ ] Achievement engine
- [ ] Progress
- [ ] Unlock persistence
- [ ] Unlock notification
- [ ] No duplicate unlocks

## Settings

- [ ] System/light/dark theme
- [ ] Meditation defaults
- [ ] Audio defaults
- [ ] Reminder scheduling
- [ ] Notification controls
- [ ] Screen behavior
- [ ] Data export
- [ ] Data import
- [ ] Data deletion
- [ ] Reset behavior
- [ ] Privacy/about

## Platform

- [ ] Android phone
- [ ] Android tablet
- [ ] Portrait
- [ ] Landscape
- [ ] Dark mode
- [ ] Accessibility
- [ ] Android back behavior
- [ ] Notifications
- [ ] Foreground service/background audio where required

## Quality

- [ ] No placeholder UI
- [ ] No mock data
- [ ] No TODOs for required features
- [ ] No crashes in core flows
- [ ] No unnecessary network dependency
- [ ] No private journal logging
- [ ] Release build succeeds
- [ ] Tests pass

---

# 100. Final UX Standard

The finished app should have two dramatically different personalities.

Before meditation:

```text
polished
configurable
informative
personal
```

During meditation:

```text
quiet
minimal
stable
almost invisible
```

After meditation:

```text
brief reflection
useful history
long-term insight
quiet achievements
```

The application should feel like a **personal meditation instrument that happens to have an excellent history and progress system**, rather than a wellness service trying to maximize engagement.

The user's fastest path should always be:

```text
Open app
↓
See the practice that makes sense
↓
Tap Start
↓
Put phone down
```

Build the entire application to this standard.