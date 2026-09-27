# Design System & Sensory Tokens Specification
**System Codename:** Aether Design System  
**Aesthetic Style:** Nordic Minimalist & Japanese Broadsheet  

---

## 1. Typographic Hierarchy (The Dual Voice)

We implement the SSENSE-style broadsheet typographic hierarchy:

| Role | Font Family | Weight | Letter Spacing | Case | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Editorial Display** | `Playfair Display` | Regular (400) / Italic | `-0.02em` | Sentence | Atmosphere headers, Editorial story titles |
| **Monograph Subhead** | `Playfair Display` | Medium (500) | `0.0em` | Sentence | Specimen titles in Inspector |
| **Functional UI Label**| `Plus Jakarta Sans`| SemiBold (600) | `+0.08em` | UPPERCASE | Buttons, Navigation, Studio counter, Origin |
| **Body Narrative** | `Plus Jakarta Sans`| Regular (400) | `+0.01em` | Normal | Material stories, Artisan background |
| **Telemetry / Specs** | `Space Grotesk` | Medium (500) | `+0.04em` | Normal | Audio frequency (432Hz), Pricing ($145), Dimensions |

---

## 2. Atmosphere Palette Tokens

Color values are calibrated to prevent optical fatigue. No pure `#000000` or `#FFFFFF` is used.

### Atmosphere 1: Rain & Study
*   `bgPrimary`: `#16181D` (Slate Charcoal)
*   `bgSurface`: `#1E2128` (Mist Gray Surface)
*   `textPrimary`: `#F0F2F5` (Paper White)
*   `textSecondary`: `#8C93A0` (Muted Slate)
*   `borderHairline`: `#2A2E38` (1px Hairline)
*   `accentGlow`: `#5E81AC` (Nordic Frost)

### Atmosphere 2: Tokyo Nocturne
*   `bgPrimary`: `#0B0C10` (Obsidian Onyx)
*   `bgSurface`: `#14161E` (Dark Neon Surface)
*   `textPrimary`: `#EAEAEA` (Vapor Silver)
*   `textSecondary`: `#6B7280` (Carbon)
*   `borderHairline`: `#1F2330` (Subtle Obsidian Edge)
*   `accentGlow`: `#3D5AFE` (Cobalt Pulse)

### Atmosphere 3: Raw Terracotta
*   `bgPrimary`: `#F5F2EB` (Sun-baked Travertine)
*   `bgSurface`: `#ECE7DD` (Linen Surface)
*   `textPrimary`: `#2A221E` (Dark Espresso Ink)
*   `textSecondary`: `#7C726B` (Clay Earth)
*   `borderHairline`: `#DDD6C8` (Muted Sand Line)
*   `accentGlow`: `#C86432` (Burnt Terracotta)

---

## 3. Auditory Tokens & Acoustic Engineering

| Token ID | Atmosphere Tag | Primary Freq Bands | Acoustic Description | Loop Duration | LUFS Target |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `SND_RAIN_01` | `rain_study` | $800\text{ Hz} - 3.5\text{ kHz}$ | Soft rain on window glass + distant lo-fi electric chords | 32 seconds | $-18\text{ LUFS}$ |
| `SND_TOKYO_02`| `tokyo_nocturne`| $50\text{ Hz} - 250\text{ Hz}$ | 60Hz analog sub-bass synthesizer drone + night breeze | 40 seconds | $-19\text{ LUFS}$ |
| `SND_TERRA_03`| `raw_terracotta`| $200\text{ Hz} - 1.2\text{ kHz}$ | Acoustic tape flutter, wood resonance, muted acoustic strings| 30 seconds | $-18\text{ LUFS}$ |

*   **Crossfade Curve:** `Curves.easeInOutCubic` over $400\text{ ms}$.
*   **Audio Ducking Ratio:** $0.20$ (Volume dips to 20% when an interactive inspection video or artisan interview audio plays).

---

## 4. Spacing, Geometry & Layout Tokens

```
Scale: 4px | 8px | 16px | 24px | 32px | 48px | 64px
```
*   **Screen Padding:** `20px` horizontal gutter.
*   **Masonry Gutter:** `16px` cross-axis spacing; `20px` main-axis spacing.
*   **Card Corner Radius:** `6px` (Architectural softness without bubbly mobile radius).
*   **Pill Radius (Controls & Audio Dock):** `100px` (Full capsule).
*   **Hairline Thickness:** `1.0px` (Physical print broadsheet discipline).

---

## 5. Haptic Feedback Mapping

Tactile feedback simulates mechanical hardware:

*   **Atmosphere Dial Switch:** `HapticFeedback.selectionClick()` (Fine mechanical cog click).
*   **Card Tap / Expand:** `HapticFeedback.lightImpact()` (Subtle optical shutter feel).
*   **Pin to Studio Moodboard:** `HapticFeedback.mediumImpact()` (Solid latch closure).
*   **Remove from Studio:** `HapticFeedback.vibrate()` (Light warning tap).
