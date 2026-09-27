# Design System & Sensory Tokens Specification
**System Codename:** Aether Design System  
**Aesthetic Style:** Nordic Minimalist & Japanese Broadsheet  
**Scientific Foundation:** Neuroaesthetics, Slow Technology, Psychoacoustics & Cognitive Load Theory

---

## 1. Typographic Hierarchy (The Dual Voice)

We implement the SSENSE-style broadsheet typographic hierarchy grounded in legibility and visual rhythm research:

| Role | Font Family | Weight | Letter Spacing | Case | Scientific Rationale & Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Editorial Display** | `Playfair Display` | Regular (400) / Italic | `-0.02em` | Sentence | Atmosphere headers, Editorial story titles. Optical kerning balances large display serif glyphs. |
| **Monograph Subhead** | `Playfair Display` | Medium (500) | `0.0em` | Sentence | Specimen titles in Inspector and Masonry Cards. High stroke modulation aids recognition. |
| **Functional UI Label**| `Plus Jakarta Sans`| SemiBold (600) | `+0.125em` (1.5) | UPPERCASE | Buttons, Navigation, Telemetry badges. *Empirical Rule:* All-caps micro-text (<12pt) lacks word-shape bouma; expanding tracking by 12–15% eliminates character crowding and elevates reading speed (Bringhurst, 2004; Tinker, 1963). |
| **Body Narrative** | `Plus Jakarta Sans`| Regular (400) | `+0.01em` | Normal | Material stories, Artisan background. Generous x-height prevents fatigue during deep reading. |
| **Telemetry / Specs** | `Space Grotesk` | Medium (500) | `+0.04em` | Normal | Audio frequency (432Hz), Pricing ($145 USD), Dimensions. Tabular figures ensure uniform numeric alignment. |

---

## 2. Atmosphere Palette Tokens & Anti-Halation Calibration

Color values are calibrated to prevent ocular fatigue and visual light scatter. Neither pure `#000000` nor pure `#FFFFFF` is used.

### Atmosphere 1: Rain & Study (Slate Charcoal)
*   `bgPrimary`: `#16181D` (Slate Charcoal Canvas)
*   `bgSurface`: `#1A1C23` (Weber-Fechner Layer Surface — Subtle luminance separation preventing harsh card borders)
*   `textPrimary`: `#EAEAEA` (Anti-Halation Silver — **Preventing Retinal Irradiation**: Pure white text on dark fields causes light bleed and glare across adjacent retinal photoreceptors, especially for users with astigmatism. `#EAEAEA` maintains an optimal ~13.5:1 Weber contrast ratio, exceeding WCAG AAA standards while extinguishing ocular glare; Piepenbrock et al., 2014; Dobres et al., 2017).
*   `textSecondary`: `#8C93A0` (Muted Slate)
*   `borderHairline`: `#2A2E38` (1px Hairline)
*   `accentGlow`: `#5E81AC` (Nordic Frost)

### Atmosphere 2: Tokyo Nocturne (Obsidian Neon)
*   `bgPrimary`: `#0B0C10` (Obsidian Onyx)
*   `bgSurface`: `#14161E` (Dark Neon Surface)
*   `textPrimary`: `#EAEAEA` (Vapor Silver)
*   `textSecondary`: `#6B7280` (Carbon)
*   `borderHairline`: `#1F2330` (Subtle Obsidian Edge)
*   `accentGlow`: `#3D5AFE` (Cobalt Pulse)

### Atmosphere 3: Raw Terracotta (Warm Travertine)
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

*   **Crossfade Curve:** `Curves.easeInOutCubic` over $400\text{ ms}$ with dynamic 4-step volume interpolation.
*   **Psychoacoustic Ducking:**  
    *   **Attenuation Target:** $0.20$ (Volume smoothly dips to 20% over $400\text{ ms}$).  
    *   **Cognitive Rationale:** Sudden auditory cutoffs trigger the acoustic startle reflex (Davis, 1984), whereas ambient sound competing with monograph reading causes Split-Attention cognitive interference (Sweller, 2011; Spence, 2011). Ducking clears working memory bandwidth for mindful consideration without destroying spatial presence.
    *   **Restoration Curve:** Volume smoothly returns to pre-attenuation baseline over $800\text{ ms}$ upon modal dismissal, ensuring a calm, non-intrusive re-entry.

---

## 4. Spacing, Geometry & Layout Tokens

```
Modular Scale: 4px | 8px | 16px | 24px | 32px | 48px | 64px | 120px
```

*   **Masonry Feed Gutters (Cognitive Pacing & Motor Deceleration):**
    *   **Main-Axis Spacing:** `48px` (Expansive vertical separation between cards forces ocular saccades and micro-reflection pauses, dismantling the passive doomscrolling motor loop typical of fast-commerce feeds; Hallnäs & Redström, 2001; Mark et al., 2016).
    *   **Cross-Axis Spacing:** `24px` (Balanced column separation preserving card autonomy).
*   **Specimen Card Internal Padding:** `24px` (`1.5rem`) (Gestalt Law of Proximity; Wertheimer, 1923; Sweller, 1988 — ensures generous whitespace chunking to reduce visual noise).
*   **Card Telemetry-to-Title Gap:** `16px` vertical space creating clear semantic separation between functional metadata and editorial title.
*   **Card Hover Affordance:** `8px` vertical translation (`Offset(0, 8)`) and `20px` shadow blur (Gibson's Ecological Affordance, 1979 — simulates physical elevation).
*   **Card Corner Radius:** `8px` (Architectural softness without bubbly mobile radius).
*   **Pill Radius (Controls & Audio Dock):** `100px` (Full capsule).
*   **Hairline Thickness:** `1.0px` (Physical print broadsheet discipline).

---

## 5. Behavioral Friction & The Labor Illusion

*   **The Slow-Commerce Decompression Gate:** Replaces 1-click impulse purchasing with an intentional pause that educates the user on authentic atelier provenance.
*   **The Labor Illusion (Buell & Norton, 2011; Harvard Business School):**  
    Tapping "VISIT OFFICIAL STORE ➔" initiates a calibrated $2000\text{ ms}$ verification state displaying operational transparency ("Connecting directly to atelier store..."). Empirical research demonstrates that displaying verification labor increases perceived authenticity, psychological valuation, and purchase satisfaction while neutralizing post-purchase regret.

---

## 6. Haptic Feedback Mapping

Tactile feedback simulates mechanical hardware:

*   **Atmosphere Dial Switch:** `HapticFeedback.selectionClick()` (Fine mechanical cog click).
*   **Card Tap / Expand:** `HapticFeedback.lightImpact()` (Subtle optical shutter feel).
*   **Pin to Studio Moodboard:** `HapticFeedback.mediumImpact()` (Solid latch closure).
*   **Remove from Studio:** `HapticFeedback.vibrate()` (Light warning tap).
