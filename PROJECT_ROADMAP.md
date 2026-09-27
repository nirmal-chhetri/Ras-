# Project Implementation Roadmap & Verification Sprint
**Project:** Aether Sensory Commerce  
**Target Deadline:** 7–14 Days (Semester 3-1 Tinkering Lab Project)  

---

## Sprint Breakdown & Verifier Checkpoints

```
[ Phase 0: Architecture & Specs ] ──► [ Phase 1: Environment & Scaffolding ]
                                                   │
                                                   ▼
[ Phase 3: Presentation (Masonry & UI) ] ◄── [ Phase 2: State Graph & Gateways ]
             │
             ▼
[ Phase 4: Audio Engine & Dock ] ──► [ Phase 5: Inspector & Decompression ]
                                                   │
                                                   ▼
[ Phase 7: Live Lab Demo & Evaluator Run ] ◄── [ Phase 6: User Studio & Persistence ]
```

---

### Phase 0: System Architecture & Graph Spec (COMPLETED ✅)
- [x] [SYSTEM_DESIGN.md](file:///d:/3-1/Thinkiring%20Lb/SYSTEM_DESIGN.md) (SRS + Non-Functional Performance Thresholds)
- [x] [GRAPH_WORKFLOWS.md](file:///d:/3-1/Thinkiring%20Lb/GRAPH_WORKFLOWS.md) (StateGraphs, Deterministic Verifier Gates & Tool Gateways)
- [x] [DESIGN_SYSTEM.md](file:///d:/3-1/Thinkiring%20Lb/DESIGN_SYSTEM.md) (Typographic hierarchy, Palettes, Audio frequencies & Haptic maps)
- [x] [DATA_CATALOG.json](file:///d:/3-1/Thinkiring%20Lb/DATA_CATALOG.json) (Seed database with real Unsplash CDN assets & artisan stories)

---

### Phase 1: Environment & Scaffolding (COMPLETED ✅)
- [x] Verify Flutter SDK in PATH (`flutter doctor`).
- [x] Initialize clean Flutter skeleton: `flutter create --org com.aether.commerce --platforms=windows,web .`
- [x] Populate `pubspec.yaml` with core dependencies (staggered grid, cached network image, google fonts, just_audio, audio_session, url_launcher, shared_preferences, cupertino_icons).
- [x] Download and bundle 3 offline ambient audio loops into `assets/audio/` (rain_study.ogg, tokyo_nocturne.wav, raw_terracotta.wav).
- **Verifier Checkpoint 1:** `dart analyze` passes with 0 errors; asset bundling verified via `flutter build bundle` and `verify_resources.py`.

---

### Phase 2: State Graph & Semantic Gateways (COMPLETED ✅)
- [x] Implement `AtmosphereState` schema & `AtmosphereStateMachine` (Graph 1: Atmospheric State Machine with audio conflict check).
- [x] Implement `IAudioGateway` and `JustAudioGateway` isolating `just_audio` and `audio_session`.
- [x] Implement `IStorageGateway` and `SharedPreferencesStorageGateway` persisting pinned items and custom curations.
- [x] Implement `IProvenanceGateway` and `UrlLauncherProvenanceGateway` for external atelier validation.
- [x] Implement Deterministic Verifier Gates 1, 2, and 3 (`VisualResolutionVerifier`, `AspectRatioVerifier`, `CrossmodalCongruenceVerifier`).
- [x] Implement `SpecimenIngestionPipeline` (Graph 2: Ingestion & Curation Pipeline).
- [x] Wire `CatalogRepository` to `IStorageGateway` and `AspectRatioVerifier`.
- **Verifier Checkpoint 2:** Full test suite in `test/phase2_graph_gateways_test.dart` passing 8/8 tests; 13/13 tests across project passing; `dart analyze` reports 0 issues.

---

### Phase 3: Visual Canvas & Masonry Feed (COMPLETED ✅)
- [x] Implement `ThemeManager` dynamically morphing between Slate, Obsidian, and Travertine themes with configurable transition curves and event broadcasting.
- [x] Implement `CanvasScreen` using `CustomScrollView`, `SliverMasonryGrid.count`, broadsheet masthead header, and atmospheric sub-filters.
- [x] Build `SpecimenCard` with clamped aspect ratios, memory-cached image rendering, Hero transitions, tactile bookmark toggling, and editorial typography block.
- **Verifier Checkpoint 3:** Full widget test suite in `test/phase3_masonry_feed_test.dart` passing; 16/16 tests across project passing; `dart analyze` reports 0 issues.

---

### Phase 4: Sensory Audio Dock & Visualizer (COMPLETED ✅)
- [x] Build floating `AudioDock` capsule widget at bottom with frosted glass `BackdropFilter` (sigma 14), play/tune-in pulse button, and telemetry block.
- [x] Build live `_WaveformPainter` dual-tone frequency bars reacting to live amplitude stream and theme accent glow.
- [x] Implement multi-stage volume cycle preset (100% -> 70% -> 35% -> Muted -> 100%), pause/play, stepped volume crossfade, and web autoplay gesture handling (`NotAllowedError` recovery).
- **Verifier Checkpoint 4:** Automated test suite in `test/phase4_audio_dock_test.dart` passing; 19/19 tests across project passing; `dart analyze` reports 0 issues.

---

### Phase 5: Specimen Inspector & Decompression Modal (COMPLETED ✅)
- [x] Build `SpecimenDetailScreen` with full-bleed `Hero` image transition, bottom vignette gradient, and interactive pin toggling.
- [x] Display typographic monograph: Materials badges, Studio Origin, Estimated Value in USD, Material Craft narrative, and Atmospheric Resonance pill.
- [x] Implement the "Slow-Commerce Decompression Modal" before opening external artisan store URLs via `IProvenanceGateway`.
- **Verifier Checkpoint 5:** Automated test suite in `test/phase5_detail_decompression_test.dart` passing; 21/21 tests across project passing; `dart analyze` reports 0 issues.

---

### Phase 6: Personal Studio (Moodboard Drawer) & Ingestion (COMPLETED ✅)
- [x] Build slide-up `StudioDrawer` displaying user's pinned specimens in a 2-column moodboard collage layout with tactile unpinning.
- [x] Implement room budget & space investment telemetry bar (Total Curated, Average Specimen Value, Total Estimated USD).
- [x] Connect "Clip Artisan Specimen" dialog to `SpecimenIngestionPipeline` (URL validation, aspect ratio bounds repair, atmosphere auto-congruence, inline error telemetry).
- **Verifier Checkpoint 6:** Offline persistence test in `test/phase6_studio_persistence_test.dart` passing; 23/23 tests across project passing; `dart analyze` reports 0 issues.

---

### Phase 7: Edge Case Verification & Lab Demo Prep
- [ ] Test Airplane mode (100% offline playback).
- [ ] Test audio priority when Spotify is active.
- [ ] Test layout resilience with 200% system font scaling.
- [ ] Package release APK / Windows desktop build for presentation day.
