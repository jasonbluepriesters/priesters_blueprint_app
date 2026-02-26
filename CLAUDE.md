# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (choose a target)
flutter run -d windows
flutter run -d android
flutter run -d ios

# Analyze for lint errors
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Regenerate code after modifying @freezed or @riverpod annotated files
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

## Architecture Overview

This is a **Flutter + Riverpod** facility layout & compliance app using an **offline-first** data strategy.

### Navigation

`main.dart` → `MainNavigationScreen` (bottom nav) → three top-level tabs:
1. **Blueprints** (`BlueprintDashboardScreen`) — list/create facility layout blueprints
2. **Facilities** (`FacilitiesDashboardScreen`) — asset register
3. **Settings** (`SettingsScreen`)

### Data Layer: Offline-First with Supabase Sync

`OfflineFirstBlueprintRepository` (`lib/features/blueprint/data/offline_first_blueprint_repo.dart`) is the single data gateway:
- **SQLite** (via `sqflite`) is the local source of truth, DB name: `priesters_blueprint.db`, version 2
- **Supabase** is the cloud backend; on upgrade the local DB is dropped and re-pulled from cloud
- Blueprint `layoutElements` are stored as a JSON-encoded string in both SQLite and Supabase
- The repo is instantiated directly (not injected) in `BlueprintDashboardScreen`; a `blueprintRepositoryProvider` also exists in `blueprint_provider.dart` for Riverpod consumers

### Domain Models

All models live in `lib/features/blueprint/domain/facility_blueprint.dart` and use manual `toMap()`/`fromMap()` serialization (no code generation). Canvas elements are a polymorphic `List<dynamic>` discriminated by a `'type'` key:
- `CustomMachine` — rectangular equipment piece with mm dimensions, position, rotation, optional `assetId` link
- `StructuralWall` — line segment (startX/Y → endX/Y) with thickness
- `TextLabel` — free-form text annotation
- `TracingImage` — background reference image with opacity

`FacilityAsset` (`lib/features/facilities/domain/facility_asset.dart`) represents physical equipment in the asset register and can be linked to a `CustomMachine` via `assetId`.

### State Management

- **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) is used throughout
- `GraphicsController` (`lib/core/theme/graphics_controller.dart`) — `@keepAlive` notifier persisting canvas settings (theme, grid, snap, high-fidelity) to `SharedPreferences`; the `sharedPreferencesProvider` is overridden in `main.dart`
- `BlueprintElements` (`lib/features/blueprint/presentation/state/blueprint_elements_notifier.dart`) — `@riverpod` notifier holding the live `List<dynamic>` of canvas elements for a given `blueprintId`; mutated in-place then saved back to the repo
- Generated files (`*.g.dart`, `*.freezed.dart`) must be regenerated with `build_runner` after changing annotated classes

### Canvas Workspace

`CanvasWorkspaceScreen` receives `blueprintId`, `blueprintName`, and `facilityName`. It uses `InteractiveViewer` + `TransformationController` for pan/zoom. The UI auto-hides after 5 seconds of inactivity. A real-time Supabase stream (`blueprintStreamProvider`) watches the active blueprint for cloud changes.

### Export

`DxfExporter` (`lib/features/blueprint/data/dxf_exporter.dart`) converts the blueprint's element list to a DXF string. Canvas coordinates are multiplied by 10 to restore real-world millimeter scale for AutoCAD compatibility.

### Code Generation

`GraphicsState` uses `@freezed`. `GraphicsController` and `BlueprintElements` use `@riverpod`. Any changes to these annotated classes require running `build_runner`.
