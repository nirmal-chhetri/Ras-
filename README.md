# Aether • Ākāśa (आकाश)
### Ambient Slow-Commerce & Sensory Discovery Sanctuary

> **3-1 Tinkering Lab Project**  
> *"Where slow living curation meets acoustic resonance and deterministic software engineering."*

---

## 1. Overview & Philosophy

**Aether** (known in its philosophical Sanskrit counterpart as **Ākāśa — आकाश**, meaning celestial ether and acoustic resonance) is an ambient, sensory-driven web and desktop application that re-imagines digital curation through the lens of **Slow Commerce**.

Traditional e-commerce platforms overwhelm users with tacky discount badges, countdown timers, star ratings, and friction-free 1-click impulse purchasing. **Aether** explicitly rejects these coercive patterns:

1. **Mindful Monograph Curation:** Products are presented as artisanal "specimens" with verified provenance, studio geography, and material craft stories.
2. **Synchronized Acoustic Atmospheres:** The visual theme, acoustic soundscapes, and typography morph dynamically across three curated biomes:
   - **Rain & Study (Slate Charcoal):** 800Hz–4kHz Rain field recording, contemplative desk solitude.
   - **Tokyo Nocturne (Obsidian Neon):** 60Hz Sub-drone & neon pulse, midnight OLED contrast.
   - **Raw Terracotta (Warm Travertine):** 432Hz Warm lo-fi tape flutter, Mediterranean sun-baked clay.
3. **The Slow-Commerce Decompression Gate & Labor Illusion:** An intentional interstitial checkpoint that invites users to pause and acquire directly from independent craft makers without intermediary markups, backed by a 2000ms operational transparency verification stage (Buell & Norton, 2011; Harvard Business School).
4. **Deterministic Engineering Invariants:** Every visual asset is mathematically bounded ($0.75 \le \text{Aspect Ratio} \le 1.33$) to guarantee zero masonry feed jitter or layout jumps.
5. **The 4-Phase Empirical Scientific Framework:**
   - **Phase 1 (Gestalt Spacing & Cognitive Pacing):** 24px card padding, 16px title separation, 8px hover affordance elevation, and 48px masonry gutters to break doomscroll motor loops (Wertheimer, 1923; Hallnäs & Redström, 2001).
   - **Phase 2 (Perceived Value & Labor Illusion):** 2000ms deliberate provenance verification delay enhancing authenticity and customer satisfaction (Buell & Norton, 2011).
   - **Phase 3 (Ergonomic Anti-Halation Contrast):** `#EAEAEA` paper silver text and `#1A1C23` surface elevation preventing retinal light scatter and ocular fatigue (Piepenbrock et al., 2014; Dobres et al., 2017) with expanded 1.5 all-caps tracking (Bringhurst, 2004; Tinker, 1963).
   - **Phase 4 (Crossmodal Psychoacoustic Ducking):** 400ms ducking to 20% and 800ms restoration preventing acoustic startle reflex and eliminating split-attention cognitive interference (Spence, 2011; Davis, 1984; Sweller, 2011).

---

## 2. System Architecture

```
                           +-------------------------------------+
                           |            Aether App               |
                           |       (lib/main.dart: Root)         |
                           +------------------+------------------+
                                              |
                     +------------------------+------------------------+
                     |                                                 |
         +-----------v------------+                       +------------v-----------+
         |     ThemeManager       |                       |  AudioEngineController |
         | (Circadian Theme Morph)|                       | (just_audio + Crossfade|
         +-----------+------------+                       +------------+-----------+
                     |                                                 |
                     +------------------------+------------------------+
                                              |
                           +------------------v------------------+
                           |            CanvasScreen             |
                           |  - Broadsheet Editorial Masthead    |
                           |  - AtmosphereSelector (Dropdown)    |
                           |  - Sub-filters (All vs Curated)     |
                           |  - 2-Column Staggered Masonry Grid  |
                           |  - Floating Frosted Glass AudioDock |
                           +------------------+------------------+
                                              |
                     +------------------------+------------------------+
                     |                                                 |
         +-----------v------------+                       +------------v-----------+
         |  SpecimenDetailScreen  |                       |      StudioDrawer      |
         | - Full-bleed Hero Bar  |                       | - Space Investment Bar |
         | - Materiality Story    |                       | - 2-Column Moodboard   |
         | - Decompression Gate   |                       | - Ingestion Pipeline   |
         +-----------+------------+                       +------------+-----------+
                     |                                                 |
                     +------------------------+------------------------+
                                              |
                           +------------------v------------------+
                           |          CatalogRepository          |
                           | (Unified Single Source of Truth)    |
                           +------------------+------------------+
                                              |
         +------------------------------------+-----------------------------------+
         |                                    |                                   |
+--------v---------+                +---------v--------+                +---------v--------+
|  IAudioGateway   |                |  IStorageGateway |                |IProvenanceGateway|
| (Session/Focus)  |                |(Prefs / Bundled) |                | (URL / Atelier)  |
+------------------+                +------------------+                +------------------+
```

---

## 3. The 3 Deterministic Verifiers

All specimens entering the system undergo deterministic verification:

- **$\mathcal{V}_{res}$ (Visual Resolution Assertion):**  
  Asserts that $\min(width, height) \ge 600\text{px}$ and $byteSize \le 12\text{MB}$.
- **$\mathcal{V}_{ar}$ (Aspect Ratio Bounds & Repair):**  
  Asserts that $0.75 \le \text{Aspect Ratio} \le 1.33$. Extreme ratios are deterministically clamped with center-weighted crop repair.
- **$\mathcal{V}_{congruence}$ (Crossmodal Congruence Matching):**  
  Matches dominant hue angles ($210^\circ$ Slate, $250^\circ$ Obsidian, $25^\circ$ Terracotta) and material keywords to assign items to the optimal atmospheric biome.

---

## 4. Project Directory Structure

```
d:\3-1\Thinkiring Lb\
├── assets\
│   └── audio\
│       ├── rain_study.ogg             # Slate Charcoal acoustic loop
│       ├── raw_terracotta.wav         # Warm Travertine acoustic loop
│       └── tokyo_nocturne.wav         # Obsidian Neon acoustic loop
├── lib\
│   ├── main.dart                      # App bootstrapper & system overlay config
│   ├── core\
│   │   ├── theme.dart                 # AetherTheme tokens & Google Fonts hierarchy
│   │   ├── theme_manager.dart         # Dynamic theme transition coordinator
│   │   ├── audio_controller.dart      # Looping audio, autoplay recovery & visualizer
│   │   ├── gateways\
│   │   │   ├── audio_gateway.dart     # IAudioGateway & JustAudioGateway
│   │   │   ├── storage_gateway.dart   # IStorageGateway & SharedPreferencesGateway
│   │   │   └── provenance_gateway.dart# IProvenanceGateway & UrlLauncherGateway
│   │   ├── pipelines\
│   │   │   └── ingestion_pipeline.dart# Graph 2 Specimen Ingestion Pipeline
│   │   ├── state\
│   │   │   └── atmosphere_state_machine.dart # Graph 1 Circadian State Machine
│   │   └── verifiers\
│   │       └── deterministic_verifiers.dart  # V_res, V_ar, V_congruence
│   ├── data\
│   │   └── catalog_repository.dart    # Aggregated catalog repository
│   ├── models\
│   │   └── specimen.dart              # Atmosphere & DesignSpecimen domain models
│   └── presentation\
│       ├── screens\
│       │   ├── canvas_screen.dart     # Primary broadsheet & masonry canvas
│       │   ├── specimen_detail_screen.dart # Monograph & Decompression Gate
│       │   └── studio_drawer.dart     # Personal Studio Moodboard
│       └── widgets\
│           ├── atmosphere_selector.dart # Biome switcher popup
│           ├── audio_dock.dart        # Frosted glass capsule with live waveform
│           └── specimen_card.dart     # Clamped masonry card with Hero transition
├── test\
│   ├── catalog_verifier_test.dart     # Verifier & domain model unit tests
│   ├── phase2_graph_gateways_test.dart# StateGraph & Semantic Gateway tests
│   ├── phase3_masonry_feed_test.dart  # Canvas, theme & masonry card tests
│   ├── phase4_audio_dock_test.dart    # Audio dock & visualizer tests
│   ├── phase5_detail_decompression_test.dart # Detail screen & Decompression Gate tests
│   ├── phase6_studio_persistence_test.dart # Studio persistence & clipping tests
│   ├── phase7_evaluator_demo_test.dart# 200% font scaling accessibility tests
│   └── widget_test.dart               # Baseline regression & smoke tests
├── audit_all_assets.py                # Comprehensive multi-point asset audit script
├── DATA_CATALOG.json                  # Baseline 10 curated specimens & 3 atmospheres
├── EVALUATOR_GUIDE.md                 # Step-by-step evaluator demo script & manual
├── PROJECT_ROADMAP.md                 # 8-phase milestone completion breakdown
├── SYSTEM_DESIGN.md                   # Full SRS & architectural specifications
├── GRAPH_WORKFLOWS.md                 # Formal StateGraph transition matrices
└── DESIGN_SYSTEM.md                   # Design tokens, typography & acoustic tokens
```

---

## 5. Verification & Testing

### Run Automated Test Suite (29/29 Tests)
```powershell
flutter test
```

### Static Analysis
```powershell
dart analyze lib/ test/
```

### Audit All Remote & Local Assets
```powershell
python audit_all_assets.py
```

---

## 6. How to Run Locally

### Chrome Web
```powershell
flutter run -d chrome
```

### Windows Desktop
```powershell
flutter run -d windows
```

> **Web Audio Note:** Modern web browsers block unprompted audio autoplay before the first user gesture. When launched in Chrome, the floating [AudioDock] displays **"CLICK TO TUNE IN"**. A single click on the dock seamlessly activates the audio engine.
