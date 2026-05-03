# GuestMemories — Design System & UX Guide

> Living document. Minden UI-változás konzultálja és frissíti ezt a fájlt.
> Utolsó frissítés: 2026-05-03

---

## Tartalomjegyzék

1. [Alapelvek](#1-alapelvek)
2. [Design tokenek](#2-design-tokenek)
3. [Tipográfia](#3-tipográfia)
4. [Térköz & layout rendszer](#4-térköz--layout-rendszer)
5. [Szín-rendszer](#5-szín-rendszer)
6. [Ikonok](#6-ikonok)
7. [Animáció & motion](#7-animáció--motion)
8. [Komponensek — Admin UI](#8-komponensek--admin-ui)
9. [Komponensek — Widgetek](#9-komponensek--widgetek)
10. [Oldalak & flow-k](#10-oldalak--flow-k)
11. [State-kezelés a UI-ban](#11-state-kezelés-a-ui-ban)
12. [Akadálymentesség](#12-akadálymentesség)
13. [Reszponzív rendszer](#13-reszponzív-rendszer)
14. [i18n & lokalizáció](#14-i18n--lokalizáció)
15. [Widget beágyazási rendszer](#15-widget-beágyazási-rendszer)
16. [Soha ne lista](#16-soha-ne-lista)
17. [Döntési log](#17-döntési-log)

---

## 1. Alapelvek

### 1.1 A 7 parancsolat

**1. Egy képernyő, egy fő cselekvés.**
Minden oldal egyetlen célt kommunikál. A másodlagos műveletek el vannak rejtve (overflow menü, secondary gomb), a főcselekvés mindig nyilvánvaló és CTA-szerű.

**2. Visszajelzés 100ms-en belül.**
Ha egy gombra kattintanak, azonnal valami történik: loading state, optimistic UI, vagy legalább egy vizuális ütés. Ha a valódi eredmény 3+ mp-et vesz igénybe, progress indikátor megy.

**3. Minden képernyőnek 5 állapota van.**
Empty / Loading / Content / Zero-result (szűrt) / Error. Ha valamelyik hiányzik, az nem kész.

**4. Türelmes az ismeretlen felhasználóval.**
A hotel adminjainak nem kell tudniuk, mi az az API, RLS, vagy OAuth. Minden hibaüzenet emberi nyelven szól. Minden form tartalmaz példaértéket (`placeholder="pl. Hotel Gellért"`).

**5. Hierarchia vizualitásban, ne szövegméretben.**
A fontossági sorrendet `font-weight`, `color opacity`, `spacing` fejezi ki — nem 48px headline vs 10px test. Kerüljük a szövegméretek extremitásait.

**6. Mobil nem afterthought.**
A layout 360px-en kezd, és felfelé terjeszkedik. Minden touch target minimum 44×44px. Hover state létezik, de nem az egyetlen info-hordozó.

**7. A design a bizalmat adja el.**
Ez egy hotel-kezelő rendszer, ahol hotelek csatlakoztatják a Google és Meta fiókjukat. Minden pixel azt kell kommunikálja: "ez egy megbízható, profi eszköz". Felesleges dekoráció, stockfoto-kék gradiens, Comic Sans — nincs.

---

### 1.2 Személyiség

| Igen | Nem |
|---|---|
| Tiszta, légies | Zsúfolt, hadonászó |
| Magabiztos, közvetlen | Pöffeszkedő, szlengel |
| Precíz, adathű | Túl-dramatizált, clickbait |
| Meleg, emberi | Rideg, robotalapú |
| Progresszív, gyors | Lassú, bloated |

---

## 2. Design tokenek

### 2.1 CSS Custom Properties

A teljes token-rendszer CSS custom properties-ként él, így a white-label widget-ek és az admin UI egyazon rendszerből dolgoznak. Tailwind konfigban ezek aliasként vannak behuzalva.

```css
:root {
  /* Felületek */
  --gm-bg:               #f8fafc;  /* page background */
  --gm-bg-subtle:        #f1f5f9;  /* section bg, alt rows */
  --gm-surface:          #ffffff;  /* kártyák, inputok */
  --gm-surface-raised:   #ffffff;  /* dropdownok, tooltipek (shadow via box-shadow) */
  --gm-surface-overlay:  rgba(0,0,0,0.48); /* modal backdrop */

  /* Határok */
  --gm-border:           #e2e8f0;
  --gm-border-strong:    #cbd5e1;
  --gm-border-focus:     #3b82f6;

  /* Szöveg */
  --gm-text:             #0f172a;  /* elsődleges */
  --gm-text-secondary:   #475569;  /* másodlagos, label */
  --gm-text-muted:       #94a3b8;  /* placeholder, disabled */
  --gm-text-inverse:     #f8fafc;  /* fehér bg-n */
  --gm-text-on-primary:  #ffffff;

  /* Brand */
  --gm-primary:          #2563eb;
  --gm-primary-hover:    #1d4ed8;
  --gm-primary-active:   #1e40af;
  --gm-primary-subtle:   #eff6ff;  /* light bg tint */

  /* Szemantikus */
  --gm-success:          #16a34a;
  --gm-success-subtle:   #f0fdf4;
  --gm-warning:          #d97706;
  --gm-warning-subtle:   #fffbeb;
  --gm-danger:           #dc2626;
  --gm-danger-subtle:    #fef2f2;
  --gm-info:             #0284c7;
  --gm-info-subtle:      #f0f9ff;

  /* Értékelés */
  --gm-rating:           #f59e0b;  /* csillag szín */
  --gm-rating-empty:     #e2e8f0;

  /* Platform-brandek */
  --gm-google:           #4285f4;
  --gm-meta:             #1877f2;
  --gm-booking:          #003580;
  --gm-tripadvisor:      #34e0a1;

  /* Szegmens-színek */
  --gm-seg-family:       #8b5cf6;  /* lila */
  --gm-seg-couple:       #ec4899;  /* pink */
  --gm-seg-solo:         #f59e0b;  /* amber */
  --gm-seg-business:     #3b82f6;  /* kék */
  --gm-seg-friends:      #10b981;  /* zöld */
  --gm-seg-unknown:      #94a3b8;  /* szürke */

  /* Tipográfia */
  --gm-font:             'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --gm-font-mono:        'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;

  /* Radius */
  --gm-radius-sm:        4px;   /* chip, badge, tag */
  --gm-radius-md:        8px;   /* kártya, input, gomb */
  --gm-radius-lg:        12px;  /* modal, panel, sheet */
  --gm-radius-xl:        16px;  /* nagy kártya, hero blokk */
  --gm-radius-full:      9999px;

  /* Árnyékok */
  --gm-shadow-sm:        0 1px 2px rgba(0,0,0,0.05);
  --gm-shadow-md:        0 4px 12px rgba(0,0,0,0.08);
  --gm-shadow-lg:        0 12px 32px rgba(0,0,0,0.12);
  --gm-shadow-xl:        0 24px 64px rgba(0,0,0,0.16);
  --gm-shadow-focus:     0 0 0 3px rgba(37,99,235,0.3);

  /* Átmenetek */
  --gm-ease-default:     cubic-bezier(0.16, 1, 0.3, 1);  /* spring-like */
  --gm-ease-in:          cubic-bezier(0.4, 0, 1, 1);
  --gm-ease-out:         cubic-bezier(0, 0, 0.2, 1);
  --gm-duration-fast:    100ms;
  --gm-duration-base:    200ms;
  --gm-duration-slow:    300ms;
}

[data-theme="dark"] {
  --gm-bg:               #09090b;
  --gm-bg-subtle:        #18181b;
  --gm-surface:          #1c1c1f;
  --gm-surface-raised:   #27272a;
  --gm-surface-overlay:  rgba(0,0,0,0.72);
  --gm-border:           #27272a;
  --gm-border-strong:    #3f3f46;
  --gm-border-focus:     #60a5fa;
  --gm-text:             #fafafa;
  --gm-text-secondary:   #a1a1aa;
  --gm-text-muted:       #52525b;
  --gm-text-inverse:     #09090b;
  --gm-text-on-primary:  #ffffff;
  --gm-primary:          #3b82f6;
  --gm-primary-hover:    #60a5fa;
  --gm-primary-active:   #93c5fd;
  --gm-primary-subtle:   #172554;
  --gm-success:          #22c55e;
  --gm-success-subtle:   #052e16;
  --gm-warning:          #f59e0b;
  --gm-warning-subtle:   #1c1002;
  --gm-danger:           #ef4444;
  --gm-danger-subtle:    #1f0505;
  --gm-info:             #38bdf8;
  --gm-info-subtle:      #0c1a26;
  --gm-rating:           #fbbf24;
  --gm-rating-empty:     #3f3f46;
  --gm-shadow-sm:        0 1px 2px rgba(0,0,0,0.3);
  --gm-shadow-md:        0 4px 12px rgba(0,0,0,0.4);
  --gm-shadow-lg:        0 12px 32px rgba(0,0,0,0.5);
  --gm-shadow-xl:        0 24px 64px rgba(0,0,0,0.6);
}
```

---

## 3. Tipográfia

### 3.1 Font stack

**Elsődleges UI**: `Inter` — Variable font, betöltve Google Fonts-ról vagy önállóan hostolva (privacy).
**Mono** (code-snippetek, embed-kódok): `JetBrains Mono`

### 3.2 Skála

| Token | px | Tailwind | Használat |
|---|---|---|---|
| `text-2xs` | 11 | custom | metaadat, timestamp, platform-jelölés |
| `text-xs` | 12 | `text-xs` | chip, badge, secondary label |
| `text-sm` | 14 | `text-sm` | body copy, form label, tábla-sor |
| `text-base` | 16 | `text-base` | fő szöveg, paragraph |
| `text-lg` | 18 | `text-lg` | card title, section lead |
| `text-xl` | 20 | `text-xl` | page section title |
| `text-2xl` | 24 | `text-2xl` | page title (mobile) |
| `text-3xl` | 30 | `text-3xl` | page title (desktop), score hero |
| `text-4xl` | 36 | `text-4xl` | dashboard KPI szám |
| `text-5xl` | 48 | `text-5xl` | landing / widget score hero |

### 3.3 Font weight

| Weight | Használat |
|---|---|
| 400 (regular) | Body, description, hint |
| 500 (medium) | Label, nav item, tábla fejléc |
| 600 (semibold) | Button, card title, metric |
| 700 (bold) | Page title, hero metric |

### 3.4 Line height

- **Body szöveg**: `1.6` (légies, olvasható)
- **UI elemek, gombok**: `1.25`
- **Heading**: `1.15`
- **Mono/kód**: `1.7`

### 3.5 Szöveg-stílusok (előre definiált kombinációk)

```
display-lg    → 48px / 700 / 1.1  / tracking: -0.02em
display-md    → 36px / 700 / 1.15 / tracking: -0.02em
heading-xl    → 30px / 600 / 1.2
heading-lg    → 24px / 600 / 1.25
heading-md    → 20px / 600 / 1.25
heading-sm    → 18px / 600 / 1.3
body-lg       → 16px / 400 / 1.6
body-md       → 14px / 400 / 1.6
body-sm       → 12px / 400 / 1.5
label-lg      → 14px / 500 / 1.25
label-md      → 12px / 500 / 1.25
label-sm      → 11px / 500 / 1.2 / tracking: 0.02em / uppercase
mono-md       → 14px / JetBrains Mono / 400 / 1.7
```

---

## 4. Térköz & layout rendszer

### 4.1 Spacing scale (4px alapegység)

```
1  →  4px
2  →  8px
3  →  12px
4  →  16px
5  →  20px
6  →  24px
8  →  32px
10 →  40px
12 →  48px
16 →  64px
20 →  80px
24 →  96px
32 →  128px
```

### 4.2 Layout breakpointok

| Név | Min width | Tailwind | Használat |
|---|---|---|---|
| xs | 360px | — | minimum támogatott mobil |
| sm | 640px | `sm:` | nagy mobil, kis tablet |
| md | 768px | `md:` | tablet portrait |
| lg | 1024px | `lg:` | tablet landscape, kis laptop |
| xl | 1280px | `xl:` | asztali |
| 2xl | 1536px | `2xl:` | nagy képernyő |

### 4.3 Konténer

```
max-width: 1280px
padding-x: 16px (mobile) → 24px (md) → 32px (xl)
```

### 4.4 Grid rendszer

Az admin UI **12-oszlopos grid**-et használ (`gap-6`):

| Elem | Mobile | Tablet | Desktop |
|---|---|---|---|
| Sidebar | fullscreen (overlay) | 240px fixed | 240px fixed |
| Fő tartalom | 12/12 | 12/12 | 10/12 |
| Kártyák (lista) | 1 col | 2 col | 3 col |
| Detail panel | fullscreen | 2/3 | 3/4 |
| Stat KPI row | 1 col | 2 col | 4 col |

### 4.5 Belső komponens-spacing szabályok

- Kártya belső padding: `p-6` (24px) desktop, `p-4` (16px) mobile
- Form elem közötti gap: `gap-4` (16px)
- Section közötti gap: `gap-8` (32px)
- List item magasság (tábla sor): min 52px
- Touch target minimum: 44×44px

---

## 5. Szín-rendszer

### 5.1 Kontraszt-arányok (WCAG 2.2 AA)

| Kombináció | Arány | Megfelelőség |
|---|---|---|
| `--gm-text` on `--gm-bg` | ≥ 15:1 | ✅ AAA |
| `--gm-text-secondary` on `--gm-surface` | ≥ 4.5:1 | ✅ AA |
| `--gm-text-muted` on `--gm-surface` | ≥ 3:1 | ✅ AA nagy szöveg |
| Primary gomb (fehér on primary) | ≥ 4.5:1 | ✅ AA |
| Disabled text on surface | < 3:1 (intentional, nem info-hordozó) | ⚠️ |

> **Fontos**: a szegmens-színek (`--gm-seg-*`) önmagukban NEM hordoznak kizárólagos információt — minden szegmens-chip ikont is kap, nem csak színt.

### 5.2 Szegmens-azonosítás

| Szegmens | Szín | Ikon (Lucide) | Label HU | Label EN |
|---|---|---|---|---|
| family | `#8b5cf6` | `Users` | Családos | Family |
| couple | `#ec4899` | `Heart` | Páros | Couple |
| solo | `#f59e0b` | `User` | Szóloutazó | Solo |
| business | `#3b82f6` | `Briefcase` | Üzleti | Business |
| friends | `#10b981` | `UserGroup` | Baráti társaság | Friends |
| unknown | `#94a3b8` | `HelpCircle` | Ismeretlen | Unknown |

### 5.3 Platform-brandszínek

| Platform | Szín | Logo-kezelés |
|---|---|---|
| Google | `#4285f4` / `#EA4335 #FBBC04 #34A853 #4285F4` (multicolor) | SVG logo, soha ne módosítsd a brand-színeket |
| Meta | `#1877f2` | Facebook logo blueprint |
| Booking.com | `#003580` | Kék háttér, fehér betű |
| TripAdvisor | `#34e0a1` (zöld) + `#000000` (szöveg) | Owl logó |

> Brandlogókat mindig az eredeti formátumban jelenítsd meg. Google esetében a "G" logó multicoloros, és a Google Brand Guidelines tiltja az egyszínű használatát.

---

## 6. Ikonok

**Csomag**: `lucide-react` — konzisztens, stroke-based, méretarányos, tree-shaking friendly.

### 6.1 Ikonméretek

| Kontextus | Méret | Stroke width |
|---|---|---|
| Navigation sidebar | 20px | 1.5 |
| Button ikon (szöveg mellett) | 16px | 1.5 |
| Button ikon-only (action) | 18px | 1.5 |
| Badge / chip | 12px | 2 |
| Empty state illusztráció | 48px | 1 |
| KPI/metric | 24px | 1.5 |

### 6.2 Ikon–szöveg igazítás

Mindig `flex items-center gap-2` — soha ne `relative top-0.5` hackelés.

### 6.3 Platform-logók

SVG fájlok: `apps/admin/public/logos/` és `apps/widget-host/public/logos/`:
```
google.svg     (multicolor "G")
meta.svg       (kék "f")
booking.svg    (fehér betű kék bg)
tripadvisor.svg (owl)
```

Widgetekben az SVG-k inline kerülnek (nem külső URL), hogy ne függjön külső szerver elérhetőségétől.

---

## 7. Animáció & motion

### 7.1 Elvek

- **Funkcionális animáció** — csak akkor, ha információt hordoz (pl. egy elem helye megváltozik, egy panel csúszik be, egy töltés folyik).
- **Finom, nem ünnepies** — nem confetti, nem bounce-overdrive. Max 300ms, `--gm-ease-default`.
- **`prefers-reduced-motion: reduce`** esetén **minden tranzíció 0ms** vagy instant.

### 7.2 Szokásos tranzíciók

| Elem | Tulajdonság | Időtartam | Easing |
|---|---|---|---|
| Gomb hover/active | `background-color`, `box-shadow` | 100ms | linear |
| Input focus | `border-color`, `box-shadow` | 100ms | linear |
| Kártya hover | `box-shadow`, `transform: translateY(-2px)` | 150ms | ease-out |
| Dropdown megjelenés | `opacity` 0→1, `translateY(-4px → 0)` | 150ms | ease-out |
| Modal megjelenés | `opacity` + `scale(0.96 → 1)` | 200ms | `--gm-ease-default` |
| Toast slide-in | `translateX(100% → 0)` | 250ms | `--gm-ease-default` |
| Page transition | `opacity` 0→1 | 200ms | ease-out |
| Skeleton shimmer | `background-position` loop | 1400ms | linear, infinite |
| Sidebar collapse | `width` | 250ms | `--gm-ease-default` |
| Accordion expand | `height` (via grid trick) | 200ms | ease-out |

### 7.3 Loading shimmer

```css
@keyframes gm-shimmer {
  from { background-position: -400px 0; }
  to   { background-position: 400px 0; }
}

.skeleton {
  background: linear-gradient(
    90deg,
    var(--gm-bg-subtle) 25%,
    var(--gm-border) 50%,
    var(--gm-bg-subtle) 75%
  );
  background-size: 800px 100%;
  animation: gm-shimmer 1.4s ease-in-out infinite;
  border-radius: var(--gm-radius-sm);
}
```

---

## 8. Komponensek — Admin UI

### 8.1 Gombhierarchia

| Variáns | Mikor | Stílus |
|---|---|---|
| `primary` | Fő CTA (max 1/oldal) | Teli background, `--gm-primary` |
| `secondary` | Kísérő cselekvés | Border + bg transparent, hover: subtle fill |
| `ghost` | Sorban lévő action, kevésbé fontos | Csak szöveg, hover: subtle bg |
| `destructive` | Törlés, visszavonás | Piros, megerősítős dialog után |
| `loading` | Folyamatban lévő action | Spinner + disabled state, szöveg marad |

**Gomb-anatómia** (`md` méret, default):
```
height: 40px
padding: 0 16px
font: 14px / 500
border-radius: var(--gm-radius-md)
gap (ikon + szöveg): 8px
min-width: 80px
```

**Méretvariánsok**:
```
sm: height 32px / padding 0 12px / font 13px
md: height 40px / padding 0 16px / font 14px  ← default
lg: height 48px / padding 0 24px / font 16px
```

### 8.2 Input & Form elemek

```
height: 40px (md)
padding: 0 12px
border: 1px solid var(--gm-border)
border-radius: var(--gm-radius-md)
font: 14px / 400

:focus  → border-color: var(--gm-border-focus)
          box-shadow: var(--gm-shadow-focus)
:error  → border-color: var(--gm-danger)
          box-shadow: 0 0 0 3px rgba(220,38,38,0.2)
:disabled → opacity: 0.5, cursor: not-allowed
```

**Form layout szabály**: minden form-mezőnek van `<label>`, helpertext (`text-sm text-secondary`), és error-message (`text-sm text-danger` + `aria-describedby`). Kötelező mezőket piros `*`-gal jelöljük, de `aria-required="true"`-t is.

**Textarea**: min 3 sor magasság, auto-resize `field-sizing: content` + max-height.

### 8.3 Kártya

```
background: var(--gm-surface)
border: 1px solid var(--gm-border)
border-radius: var(--gm-radius-lg)
box-shadow: var(--gm-shadow-sm)
padding: 24px (desktop) / 16px (mobile)

hover (ha klikk-able):
  box-shadow: var(--gm-shadow-md)
  transform: translateY(-1px)
  transition: 150ms ease-out
```

**Hotel kártya felépítése**:
```
┌────────────────────────────────────┐
│ [logó/avatar]  Név                 │
│                Város, Ország       │
│                                    │
│ ─────────────────────────────────  │
│ [G] 4.7  [F] 4.5  [B] 8.9  [T]4.4 │
│ ▲ +0.2 (utóbbi 30 nap)             │
└────────────────────────────────────┘
```

### 8.4 Review sor (lista nézet)

```
┌────────────────────────────────────────────────────────┐
│ [G]  ★★★★★  "Gyönyörű szoba, kiváló reggeli, a..."    │
│      4.5/5   [family chip] [positive chip]  2026-04-12 │
└────────────────────────────────────────────────────────┘
```

Kinyitott állapot (accordion):
```
┌────────────────────────────────────────────────────────┐
│ [G]  ★★★★★  4.5/5   [family] [positive]  2026-04-12   │
│ ──────────────────────────────────────────────────────  │
│ "Gyönyörű szoba, kiváló reggeli, a személyzet         │
│  nagyon kedves volt. Ajánlom mindenkinek!"             │
│                                                        │
│ AI tag-ek: [cleanliness] [staff] [breakfast]          │
│ Bizonyosság: 94%                                       │
└────────────────────────────────────────────────────────┘
```

### 8.5 Szegmens-chip

```
border-radius: var(--gm-radius-full)
padding: 2px 10px
font: 12px / 500
gap (ikon + szöveg): 4px
background: [szín]-subtle
color: [szín] (sötétített, kontraszt-megfelelő)
border: 1px solid [szín]-20% opacity
```

### 8.6 Score badge (admin nézetben)

```
┌──────────────┐
│ [G]  4.7 ★  │
└──────────────┘
```
Platform-ikon (20px) → szám (18px bold) → csillag ikon (14px, `--gm-rating` szín).

### 8.7 Stats kártyák (dashboard)

```
┌───────────────────────────┐
│ Összes review (30 nap)    │
│                           │
│ 142                       │  ← display-md
│ ▲ 23%  előző időszakhoz   │  ← trend, zöld/piros
└───────────────────────────┘
```

**Trend indikátor**:
- ▲ pozitív → `--gm-success`, nyíl fel + % szám
- ▼ negatív → `--gm-danger`, nyíl le + % szám
- → stagnál → `--gm-text-muted`, vízszintes nyíl

### 8.8 Navigation sidebar

```
width: 240px (desktop), overlay/drawer (mobile)

Struktúra:
[logo]
──────
[hotel selector dropdown]
──────
Navigáció:
  • Áttekintés
  • Szállodák
  • Vélemények
  • Widgetek
  • Statisztikák
──────
[Beállítások]
[Kijelentkezés]
──────
[user avatar + email]
```

Nav item állapotok:
```
default: text-secondary, no bg
hover: bg-subtle, text-primary
active/current: bg-primary-subtle, text-primary, font-semibold, left-border: 2px primary
```

### 8.9 Modal & Dialog

- Max width: `480px` (confirm), `640px` (form), `80vw` (large view)
- Backdrop: `--gm-surface-overlay` blur(4px)
- Bezárás: Escape gomb, backdrop klikk, X gomb (jobb felső sarok)
- Fókusz trap: a modal nyíláskor a fókusz az első interaktív elemre ugrik
- Max 1 réteg — modal modal fölött nem lehet

**Destruktív confirm dialog**:
```
┌──────────────────────────────┐
│ Szálloda törlése             │
│                              │
│ Biztosan törölni szeretnéd   │
│ a "Hotel Gellért" szállodát? │
│ Ez a művelet visszavonható,  │
│ de az adatok 30 napig        │
│ megőrzésre kerülnek.         │
│                              │
│ [Mégsem]      [Törlés]       │
└──────────────────────────────┘
```
A `[Törlés]` gomb `destructive` variáns, és 1 mp-ig disabled (szándékos ütközési lehetőség eliminálása).

### 8.10 Toast / Notification

```
pozíció: bottom-right, stack (max 3)
width: 360px
padding: 16px
border-radius: var(--gm-radius-lg)
gap: 12px (ikon + szöveg + close)

Típusok:
  success  → zöld bal border + check ikon
  error    → piros bal border + x-circle ikon
  warning  → amber bal border + alert ikon
  info     → kék bal border + info ikon

Auto-close: 4s (success/info), 8s (warning), kézi (error)
```

### 8.11 Platform connection kártya

```
┌──────────────────────────────────────────┐
│ [Google logo]  Google Business Profile   │
│                                          │
│ ● Csatlakoztatva  —  Hotel Gellért       │
│ Utolsó szinkron: 2 perce                 │
│                                          │
│ [Szinkronizálás]        [Leválasztás]    │
└──────────────────────────────────────────┘
```

Állapotok: Nincs csatlakoztatva / Folyamatban / Csatlakoztatva / Hiba (részletes hiba expander)

### 8.12 Táblázat

```
thead: bg-subtle, text-sm/medium, sticky (ha scroll)
tbody sor: 52px min-height, border-bottom: gm-border
hover sor: bg-subtle
selected sor: bg-primary-subtle
utolsó sor: nincs border
```

Oszlopok alapszélessége: `auto` (text), `120px` (dátum), `100px` (szám/score), `160px` (szegmens).

---

## 9. Komponensek — Widgetek

### 9.1 Widget-tér elvei

A widget **idegen terepen él** — a befogadó oldal CSS-e, JS-e, betűkészlete bármi lehet. Ezért:

- **Shadow DOM** minden script-snippet widgetnél (CSS izoláció)
- **Iframe** opcionálnál full izoláció (sandboxed, csak allow-scripts)
- **Soha ne szivárogjon ki** a befogadó oldal CSS-be
- **Soha ne blokkolja** a befogadó oldal renderelését (async load, IntersectionObserver)
- **Fallback**: ha az API nem válaszol, a widget eltűnik (display:none), nem mutat hibát

### 9.2 Widget típusok

#### Score Badge — Kompakt
```
┌─────────────────────────────────────────┐
│ [G]4.8  [F]4.6  [B]9.1  [T]4.4  ★     │
└─────────────────────────────────────────┘
magasság: 40px — vízszintes strip
```

#### Score Badge — Részletes (2×2)
```
┌──────────────┬──────────────┐
│ [G] 4.8 ★   │  [F] 4.6 ★  │
│ 1 248 vélem. │  342 vélem.  │
├──────────────┼──────────────┤
│ [B]   9.1   │  [T]  4.4   │
│ Kiváló      │ Nagyon jó    │
└──────────────┴──────────────┘
```

#### Review Carousel
```
┌──────────────────────────────────────────┐
│ "Gyönyörű szoba, remek reggeli."         │
│                                          │
│ ★★★★★   K. János  •  Páros utazó        │
│ [Google]                    2026-04-12   │
│                                          │
│       ← [1/8] →                         │
└──────────────────────────────────────────┘
```
- Auto-rotate: 5s, megáll hover-re és touch-ra
- Swipe gesture: iOS/Android
- Névtelen szerző: `"K. János"` (csak kezdőbetű + vezetéknév)
- Min review hossz widgetbe: 30 karakter. Rövidebb → kihagyja.

#### Review Wall (3 col grid)
```
┌──────────┬──────────┬──────────┐
│ "..."    │ "..."    │ "..."    │
│ ★★★★★  │ ★★★★☆  │ ★★★★★  │
│ K. János │ M. Anna  │ T. Péter │
│ [G] Pár  │ [G] Csal │ [M] Solo │
└──────────┴──────────┴──────────┘
```
Mobile: 1 col, tablet: 2 col, desktop: 3 col.

#### Stat Card
```
┌────────────────────────────┐
│ Vendégeink mondják         │
│                            │
│ 4.8 ★                     │
│ 2 847 értékelés alapján   │
│                            │
│ Különösen jó:              │
│ [Tisztaság] [Személyzet]  │
└────────────────────────────┘
```

#### Floating Panel (script widget)
```
[jobb alsó sarok]
                        [★ 4.8]  ← mini pill, mindig látható
                              ↕ klikk
┌──────────────────────────────┐
│ Vendégeink véleménye     [×] │
│                              │
│ [G] 4.8  [F] 4.6  [B] 9.1  │
│                              │
│ "Tökéletes szálloda..."      │
│ ★★★★★ K. J. — Páros        │
│                ← [1/5] →    │
└──────────────────────────────┘
```

### 9.3 Widget téma-rendszer

Minden widget-instancia JSON-ból olvassa a témát (admin-ban beállítható):

```json
{
  "primaryColor": "#2563eb",
  "textColor": "#0f172a",
  "bgColor": "#ffffff",
  "borderColor": "#e2e8f0",
  "ratingColor": "#f59e0b",
  "fontFamily": "inherit",
  "borderRadius": 8,
  "mode": "auto",
  "showPlatformLogos": true,
  "showAuthorName": true,
  "showDate": true,
  "showSegmentBadge": true,
  "locale": "auto"
}
```

`"mode": "auto"` → `prefers-color-scheme` alapján vált light/dark-ra.
`"fontFamily": "inherit"` → a befogadó oldal betűkészletét örökli.

### 9.4 Widget layout-shift prevenciója

A befogadó oldalon a widget-helyet **előre lefoglaljuk** egy `min-height`-tal:

```html
<div
  data-gm-widget="review-carousel"
  data-hotel="pub_abc123"
  style="min-height: 180px"
>
</div>
```

Ha a widget betölt és kisebb, a min-height eltűnik. Ha nem tölt be, a div üres marad (collapse).

### 9.5 Widget embed-snippet formátumok

**Script (Shadow DOM)**:
```html
<div data-gm-widget="score-badge" data-hotel="pub_abc123"></div>
<script src="https://cdn.guestmemories.io/widget.js" async></script>
```

**Iframe**:
```html
<iframe
  src="https://widget.guestmemories.io/w/pub_abc123?type=score-badge&locale=hu"
  width="100%"
  height="60"
  frameborder="0"
  scrolling="no"
  allow="autoplay"
  title="Hotel értékelések"
></iframe>
```

> A `public_key` formátum: `pub_` prefix + 12 random alphanumeric karakter. Soha nem UUID — nem kell visszakövetkeztetni belőle.

---

## 10. Oldalak & flow-k

### 10.1 Bejelentkezési oldal

```
Középre igazított kártya (max-w: 400px)
[GuestMemories logó]
[heading: "Üdvözlünk"]
[email input]
[jelszó input + show/hide toggle]
[Bejelentkezés gomb]
──────
[Elfelejtett jelszó link]
```

**Állapotok**:
- Hibás adat: piros border az input-on, toast ("Hibás email vagy jelszó")
- Loading: a gomb loading state-ben
- Sikeres: redirect `/dashboard`

### 10.2 Dashboard főoldal

```
[Header: hotel selector | user menu]
[Sidebar nav]
──────────────────────────────────
[üdvözlő sor: "Jó reggelt, Zoltán!"]
[KPI sor: összes review | avg rating | legjobb szegmens | legújabb értékelés]
[Platform-overview kártyák (4 db)]
[Legutóbbi 10 review]
[Trend grafikon (30 nap)]
```

### 10.3 Szálloda létrehozás (superadmin)

Multi-step form (progress bar felül):
```
1. Alapadatok (név, slug, cím, ország, timezone, website)
2. Hotel-csoport (opcionális, dropdown)
3. Felhasználók hozzáadása (email + role, minimum 1 owner)
4. Összegzés + Létrehozás
```

### 10.4 Platform csatlakoztatás flow (Google)

```
[Platform kártya: Google Business Profile]
[Nincs csatlakoztatva]
[Csatlakoztatás gomb]
  ↓
[Popup: "Fogja megnyitni a Google bejelentkezési ablakot.
         Kérjük, add meg a szállodához tartozó Google-fiókot."]
[Folytatás]
  ↓ (OAuth popup)
[Google login]
  ↓
[Visszairányítás → platform kártya: "Csatlakoztatva"]
[Automatikus első szinkronizálás indul]
```

### 10.5 Widget-builder flow

```
1. Widget típus választó (kártya grid, vizuális preview)
2. Szűrők (szegmens, min rating, max review szám, platform)
3. Téma (color picker, font, border-radius, dark mode)
4. Elhelyezés (inline/floating) + embed metódus (script/iframe)
5. Preview (valós adat, méretező)
6. Mentés → snippet másolás
```

A preview **valós adatot mutat**, nem dummy-t.

---

## 11. State-kezelés a UI-ban

### 11.1 Minden képernyőn kötelező 5 állapot

| Állapot | Vizuális megoldás |
|---|---|
| **Loading** | Skeleton (soha ne spinner, kivéve button loading state) |
| **Empty (valódi)** | Illusztráció + magyarázat + CTA. Pl.: "Még nincs review. Csatlakoztasd a Google fiókodat." |
| **Content** | A ténylegesen megjelenített adat |
| **Zero-result (szűrt)** | "Nincs találat a szűrőkre. Módosítsd a feltételeket." + Szűrők törlése gomb |
| **Error** | Konkrét emberi hibaüzenet + Újra gomb + részletek expander (technikai info) |

### 11.2 Optimistic UI szabályok

- **Szabad optimistán**: likes, checkin-ek, kis metaadat-változások
- **Tiltott optimistán**: törlés, role-változás, payment, platform-disconnect
- Optimistic update visszavonása: toast "Hiba történt, visszavontuk a változást" + revert

### 11.3 Skeleton arányok

A skeleton pontosan a várható tartalom arányait tükrözi:
- Hotel kártya: 2 szövegsor (60% + 40%) + 4 score block
- Review sor: 1 ikon, 2 szövegsor (100% + 70%), 2 chip
- KPI kártya: 1 rövid szó, 1 nagy szám, 1 trend

### 11.4 Hibaüzenetek hangvétele

❌ Rossz: `"Error 403: Forbidden"`
❌ Rossz: `"Something went wrong"`
✅ Jó: `"Nincs jogosultságod megtekinteni ezt a szállodát. Ha ez hiba, kérj hozzáférést az adminodtól."`
✅ Jó: `"A Google kapcsolat lejárt. Csatlakoztasd újra a fiókodat."`

---

## 12. Akadálymentesség

### 12.1 WCAG 2.2 kötelező minimum (AA)

- [ ] Kontraszt ≥ 4.5:1 normál szöveg, ≥ 3:1 nagy szöveg
- [ ] Minden kép `alt` szöveggel (platform logók: `alt="Google Business Profile"`)
- [ ] Csak-ikon gombok: `aria-label` kötelező
- [ ] Csillag-értékelés: `aria-label="4.5 az 5-ből"`
- [ ] Form-mezők: `<label>` + `aria-describedby` (helpertext + hibaüzenet)
- [ ] Kötelező mezők: `aria-required="true"`
- [ ] Táblázatok: `<caption>`, `<th scope="col/row">`
- [ ] Live régiók: toast értesítésekhez `aria-live="assertive"` (error) vagy `"polite"` (info)
- [ ] Focus trap: modal, drawer, dropdown esetén
- [ ] Focus visible: minden elem `:focus-visible` kerettel (soha ne `outline: none` globálisan)
- [ ] Skip link: `"Ugrás a tartalomra"` az oldal tetején (vizuálisan rejtett, keyboard-on látható)

### 12.2 Billentyűzet-navigáció

| Elem | Billentyű |
|---|---|
| Modal bezárás | `Esc` |
| Dropdown megnyitás | `Enter` / `Space` |
| Dropdown navigáció | `↑` / `↓` |
| Dropdown bezárás | `Esc` / `Tab` (ki) |
| Review lista lapozás | `←` / `→` (ha fókuszban) |
| Dátumválasztó | Arrow keys + Enter |

### 12.3 Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    transition-duration: 0.001ms !important;
  }
}
```

### 12.4 Widget-specifikus akadálymentesség

- Widget `<iframe>` kap `title` attribútumot: `title="Hotel értékelések — Hotel Gellért"`
- Script widget Shadow DOM: `role="region"` + `aria-label`
- Review carousel: `role="region"` + `aria-roledescription="carousel"`, lapozó gombok `aria-label="Következő vélemény"`
- Csillagok: `<span role="img" aria-label="4 csillag az 5-ből">★★★★☆</span>`

---

## 13. Reszponzív rendszer

### 13.1 Layout viselkedés

| Képernyő | Sidebar | Tartalom | Kártya grid |
|---|---|---|---|
| < 640px | Overlay drawer (hamburger) | Full width | 1 col |
| 640–1023px | Kollabálható (ikonok) | Teljes maradék | 2 col |
| 1024–1279px | 240px fixed | Teljes maradék | 2–3 col |
| ≥ 1280px | 240px fixed | Max 1040px centered | 3–4 col |

### 13.2 Kritikus mobile UX

- Bottom nav (mobile) helyett hamburger sidebar drawer
- Touch target minimum 44px minden interaktív elemre
- Swipe gesture: review carousel-ben, side drawer-ben
- Tábla mobile-on: vízszintesen scrollolható (overflow-x: auto), soha ne törjük a layout-ot
- Képernyő-billentyűzet: az input-ra fókuszálva a viewport emelkedik (handled by OS), de ne tegyük a submit gombot a billentyűzet mögé

---

## 14. i18n & lokalizáció

### 14.1 Elvek

- Minden UI szöveg `t('kulcs')` — soha nincs hardcode
- Kulcsok hierarchikusak, ponttal elválasztva: `admin.nav.hotels`, `widget.carousel.next`
- Hiányzó fordítás esetén: `EN` fallback → ha az sincs: maga a kulcs jelenik meg (lokális fallback)
- Szöveg-hossz: tervezzünk +40% hosszabb szövegekkel (német/holland)
- Plurális: `t('reviews', { count: n })` — minden számnál kezelje a `reviews.one` / `reviews.other` eseteket
- Dátumok: `Intl.DateTimeFormat` lokalizáció, soha ne hardcode formátum
- Számok, valuták: `Intl.NumberFormat`
- RTL: a layout CSS `dir="ltr/rtl"` alapján tükörözhető (nem prioritás MVP-ben, de Tailwind `rtl:` prefix elő van készítve)

### 14.2 Translation kulcs-szintaxis

```
admin.*          → Admin UI
widget.*         → Widgetek
platform.*       → Platform nevei
segment.*        → Szegmens nevek
sentiment.*      → Sentiment labels
error.*          → Hibaüzenetek
confirm.*        → Megerősítő dialógok
```

---

## 15. Widget beágyazási rendszer

### 15.1 Script snippet életciklusa

```
1. Hotel befogadó oldala betölti a widget.js-t (async)
2. widget.js: DOMContentLoaded → querySelectorAll('[data-gm-widget]')
3. Minden elemhez:
   a. Shadow DOM attach
   b. public_key-ből API hívás (fetch /api/widget/{key})
   c. JSON config lekérés (theme, locale, type, filter)
   d. Render a Shadow DOM-ba
4. IntersectionObserver: lazy-load (adatlekérés only when visible)
5. Hiba esetén: console.warn + üres div, semmi látható hiba a látogatónak
```

### 15.2 Iframe URL séma

```
https://widget.guestmemories.io/w/{public_key}
  ?type=review-carousel
  &locale=hu
  &theme=light
  &seg=family,couple          (szegmens szűrő)
  &min_rating=4
```

Az iframe **postMessage**-en keresztül kommunikál a befogadó oldallal (csak magasság-resize céljából):
```js
window.parent.postMessage({ type: 'gm-resize', height: 240 }, '*')
```

A befogadó oldalon lévő snippet-kód hallgatja és átméretezi az iframe-t.

### 15.3 Caching

- Widget API válasz: `Cache-Control: public, max-age=300` (5 perc)
- Stale-while-revalidate a kliensen
- Ha 5 percnél régebbi a cache és az API nem elérhető → mutatja a cache-elt verziót (soha ne üres)

---

## 16. Soha ne lista

- **Soha** ne legyenek hardcode-olt szövegek a komponensekben
- **Soha** ne legyen `outline: none` globálisan
- **Soha** ne legyen modal modal felett (max 1 modális réteg)
- **Soha** ne jelenjen meg hibaüzenet a widgetben a látogatónak
- **Soha** ne blokkolja a widget a befogadó oldalt (async-only)
- **Soha** ne használjunk `!important`-ot, kivéve a `prefers-reduced-motion` resetet
- **Soha** ne kerüljön vendég teljes neve a widgetbe (csak "K. János" forma)
- **Soha** ne jelenjen meg platform API-kulcs vagy token a frontenden
- **Soha** ne legyen animáció >300ms az alap interakcióknál
- **Soha** ne mutassunk toastot csak azért, mert a user navigált
- **Soha** ne kerüljön szín önmagában információt hordozó szerepbe
- **Soha** ne váljon a hover az egyedüli móddá egy adat megjelenítésére (mobil!)
- **Soha** ne legyen a `disabled` gomb az egyetlen visszajelzés arról, hogy miért nem lehet kattintani
- **Soha** ne legyen betöltési spinner egész oldalra (csak skeleton)

---

## 17. Döntési log

| Dátum | Döntés | Indok |
|---|---|---|
| 2026-05-03 | Inter font | Legolvashatóbb sans-serif a data-heavy UI-khoz |
| 2026-05-03 | Shadow DOM + iframe mindkét widget-módnak | Teljes CSS izoláció; iframe opcionálisan extrabiztonsági réteg |
| 2026-05-03 | Lucide React ikoncsomag | Tree-shakeable, stroke-based, következetes |
| 2026-05-03 | Soft delete mindenhol, no DELETE policy | GDPR-barát, auditálható, visszafordítható |
| 2026-05-03 | Szegmens-coloring ikon-kísérővel | WCAG: nem kommunikálunk csak színnel |
| 2026-05-03 | Skeleton-only loading (spinner tiltott oldalszinten) | Felhasználói teszt: skeleton kevesebb szorongást okoz |
| 2026-05-03 | Widget cache 5 perc + stale-while-revalidate | Sebesség vs. freshness kompromisszum |
| 2026-05-03 | Destruktív confirm gomb 1mp disabled | Meggondolatlankattintás-prevenci, UX best practice |
