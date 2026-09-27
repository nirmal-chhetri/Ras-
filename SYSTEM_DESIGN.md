# System Architecture & Graph Workflow Specification
**Project Codename:** Aether / Ambient Slow-Commerce  
**Domain:** Sensory Curation & Moodboard Commerce  
**Platform Target:** Flutter (Cross-platform iOS / Android / Desktop)  
**Version:** 1.0.0-PROD-SPEC  

---

## 1. System Requirements Specification (SRS)

### 1.1 Purpose & Problem Statement
Modern e-commerce and visual discovery platforms (Amazon, Pinterest, Instagram) induce cognitive overload through aggressive scarcity triggers, intrusive advertisements, and disconnected white-box product imagery. 

This system provides an ambient, distraction-free sensory sanctuary where users discover, curate, and acquire high-craftsmanship physical objects (architectural lighting, mechanical keyboards, studio tools, ceramics) organized strictly by **Atmosphere & Crossmodal Congruence**.

### 1.2 Functional Requirements (FR)
*   **FR-1 (Atmospheric State Switching):** The system shall provide at least three distinct atmospheres (*Rain & Study*, *Tokyo Nocturne*, *Raw Terracotta*), dynamically morphing visual theme tokens and background audio.
*   **FR-2 (Infinite Masonry Discovery):** The system shall render a two-column, variable-aspect-ratio staggered grid of curated design objects in-situ, free of overt price tags or discount badges.
*   **FR-3 (Specimen Inspection / Hero View):** Tapping any object expands the card seamlessly into an editorial dossier displaying material provenance, artisan studio origin, and direct acquisition links.
*   **FR-4 (Sensory Audio Dock):** A persistent, non-intrusive floating dock displaying a real-time waveform visualizer, atmosphere telemetry, and volume control.
*   **FR-5 (Studio Moodboard Collection):** Users can collect objects into a personal studio moodboard stored locally.
*   **FR-6 (URL Ingestion Engine):** Users can paste an external web link; the system scrapes metadata, validates aesthetic congruence, and creates a new specimen card.
*   **FR-7 (Affiliate Redirect Gateway):** Tapping "Acquire" passes through a pre-flight decompression modal before launching the artisan's merchant store via an external intent.

### 1.3 Non-Functional Requirements (NFR)
*   **NFR-1 (Frame Rate Stability):** The visual interface must maintain a locked 60 FPS on mid-tier mobile hardware (Snapdragon 600 series / Apple A12+) and 120 FPS on ProMotion/High-refresh displays.
*   **NFR-2 (Memory Footprint):** Client memory usage must remain strictly under **120 MB** through edge image resizing and aggressive disk-cache eviction.
*   **NFR-3 (Audio Latency & Crossfade):** Atmosphere transitions must execute a linear power crossfade over **400 ms** with zero audible click artifacts or audio dropouts.
*   **NFR-4 (Offline Resilience):** The core catalog, theme engine, and audio loops must remain 100% operational in disconnected (airplane) mode.

---

## 2. Graph Workflow Architecture (The Curation & State Engine)

The system does not rely on monolithic procedural code. It is governed by a **Deterministic State Graph**:

```
                       ┌────────────────────────────┐
                       │     INCOMING SPECIMEN      │
                       │   (URL / Ingestion Event)  │
                       └─────────────┬──────────────┘
                                     │
                                     ▼
                       ┌────────────────────────────┐
                       │   Node 1: Semantic Ingest   │
                       │   (URL Sanitization & OG)  │
                       └─────────────┬──────────────┘
                                     │
                                     ▼
                       ┌────────────────────────────┐
                       │ Node 2: Feature Extraction  │
                       │ (Palette, Aspect, Metadata)│
                       └─────────────┬──────────────┘
                                     │
                                     ▼
                       ┌────────────────────────────┐
                       │  Node 3: Crossmodal Mapper  │
                       │ (Assigns Atmosphere & Tag) │
                       └─────────────┬──────────────┘
                                     │
                                     ▼
                       ┌────────────────────────────┐
                       │  VERIFIER GATE 1: Quality   │◄────────────────┐
                       │  • Res >= 600px            │                 │
                       │  • Aspect in [0.75, 1.33]  │                 │
                       └─────────────┬──────────────┘                 │
                                     │                                │
                       ┌─────────────┴─────────────┐                  │
                       │ (Pass)                    │ (Fail)           │
                       ▼                           ▼                  │
            ┌──────────────────────┐   ┌───────────────────────┐      │
            │ VERIFIER GATE 2:     │   │ Node 4: Repair / Crop │──────┘
            │ Congruency Check     │   │ (Aspect Clamping)     │
            └──────────┬───────────┘   └───────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │ (Pass)                    │ (Fail / Incongruent)
         ▼                           ▼
┌──────────────────┐       ┌────────────────────────┐
│ Node 5: Commit   │       │ Node 6: Fallback Reject│
│ to Local Catalog │       │ (Notify User with Tip) │
└──────────────────┘       └────────────────────────┘
```

---

## 3. Deterministic Harnessing & Verifier Contracts

To eliminate silent failures, every node transition is governed by strict mathematical contracts:

### 3.1 Aspect Ratio Verifier Contract
$$\text{Aspect Ratio } AR = \frac{\text{Width}}{\text{Height}}$$
$$\text{Contract: } 0.75 \le AR \le 1.33$$
*   **Rule**: Any image with $AR < 0.75$ (extreme vertical) or $AR > 1.33$ (extreme panorama) is routed to `Node 4 (Repair / Crop)` for center-weighted clamping to preserve masonry grid stability.

### 3.2 Visual Resolution Verifier Contract
$$\text{Min Dimension: } \min(\text{Width}, \text{Height}) \ge 600\text{ px}$$
*   **Rule**: Low-resolution, pixelated, or compressed thumbnail images are rejected immediately to maintain luxury editorial aesthetics.

### 3.3 Crossmodal Audio-Visual Congruency Contract
Atmospheres are bound to physical color temperature bands (Kelvin) and auditory frequency profiles:

| Atmosphere | Color Temp ($K$) | Target Frequency Envelope | Texture / Noise Type |
| :--- | :--- | :--- | :--- |
| **Rain & Study** | $4500K - 6500K$ (Slate/Cool) | $800\text{ Hz} - 4000\text{ Hz}$ | Pink Noise (Rain) + 432Hz Piano |
| **Tokyo Nocturne** | $6500K - 9000K$ (Obsidian/Neon) | $50\text{ Hz} - 250\text{ Hz}$ | Sub-bass Analog Drone + Air |
| **Raw Terracotta** | $2500K - 3200K$ (Travertine/Warm) | $200\text{ Hz} - 1200\text{ Hz}$ | $1/f$ Tape Hiss + Wood Resonance |

---

## 4. Semantic Tool Gateways (The Safe Boundary)

Direct system hardware access is abstracted behind three typed gateways:

### 4.1 AudioEngineGateway
```dart
abstract class AudioEngineGateway {
  Future<void> initializeSession();
  Future<void> crossfadeAtmosphere(String atmosphereId, {Duration duration});
  Future<void> setVolume(double level);
  Stream<double> get visualizerAmplitudeStream;
  bool get isExternalAudioPlaying;
}
```

### 4.2 StorageGateway
```dart
abstract class StorageGateway {
  Future<List<DesignSpecimen>> getCatalogByAtmosphere(String atmosphereId);
  Future<void> pinSpecimenToStudio(DesignSpecimen specimen);
  Future<void> removeSpecimenFromStudio(String specimenId);
  Future<List<DesignSpecimen>> getStudioSpecimens();
}
```

### 4.3 ProvenanceGateway
```dart
abstract class ProvenanceGateway {
  Future<bool> launchArtisanStore(String url);
}
```

---

## 5. Data Entity Schema

```dart
class DesignSpecimen {
  final String id;
  final String title;
  final String maker;
  final String studioLocation;
  final double estimatedUsd;
  final String atmosphereTag;
  final String imageUrl;
  final double aspectRatio;
  final String materialStory;
  final String provenanceUrl;
  final DateTime createdAt;
  final bool isUserPinned;
}
```
