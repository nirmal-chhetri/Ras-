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

### Phase 3: Visual Canvas & Masonry Feed
- [ ] Implement `ThemeManager` dynamically morphing between Slate, Obsidian, and Travertine themes.
- [ ] Implement `CanvasScreen` using `CustomScrollView` and `SliverMasonryGrid.count`.
- [ ] Build `SpecimenCard` with clamped aspect ratios, memory-cached image rendering, and `Hero` tags.
- **Verifier Checkpoint 3:** Performance profile on emulator/device maintaining locked 60 FPS during infinite scrolling.

---

### Phase 4: Sensory Audio Dock & Visualizer
- [ ] Build floating `AudioDock` capsule widget at bottom with frosted glass `BackdropFilter`.
- [ ] Build live `CustomPainter` waveform rendering the simulated sound amplitude stream.
- [ ] Implement volume toggle, pause/play, and atmosphere telemetry display.
- **Verifier Checkpoint 4:** Test background looping and volume crossfade without UI frame drops.

---

### Phase 5: Specimen Inspector & Decompression Modal
- [ ] Build `SpecimenDetailScreen` with full-bleed `Hero` image transition.
- [ ] Display typographic monograph: Materials, Studio Origin, Dimensions, and Story.
- [ ] Implement the "Decompression Modal" before opening external artisan store URLs via `url_launcher`.
- **Verifier Checkpoint 5:** Test external intent launch and return without app reload.

---

### Phase 6: Personal Studio (Moodboard Drawer) & Ingestion
- [ ] Build slide-up `StudioDrawer` displaying the user's pinned specimens in a collage layout.
- [ ] Add "Pin" button with `HapticFeedback.mediumImpact()`.
- [ ] Add "Add Custom Specimen" dialog with URL input.
- **Verifier Checkpoint 6:** Offline persistence test: kill app, relaunch, verify saved pins remain intact.

---

### Phase 7: Edge Case Verification & Lab Demo Prep
- [ ] Test Airplane mode (100% offline playback).
- [ ] Test audio priority when Spotify is active.
- [ ] Test layout resilience with 200% system font scaling.
- [ ] Package release APK / Windows desktop build for presentation day.
