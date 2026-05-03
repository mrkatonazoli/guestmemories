# GuestMemories — Design System & UX Guide

Living document. Every UI change consults and updates this file.

## Vezérelvek

1. **Tisztaság elsőbbsége** — kevesebb elem, több whitespace. Egy képernyőn egy fő cselekvés.
2. **Visszajelzés azonnal** — minden user action ad feedbacket: skeleton, toast, optimistic UI.
3. **Türelmes alapállapot** — minden képernyőnek van empty / loading / error / zero-data state-je.
4. **Akadálymentesség alapból** — WCAG 2.2 AA kontraszt, billentyűzet-navigáció, screen-reader feliratok.
5. **Mobile-first** — minden layout 360px-en is használható.
6. **Több nyelv barátság** — minden szöveg `t(key)`, soha nem hardcoded; tervezz hosszabb német/holland szöveggel.

## Design tokenek (előzetes — finomítjuk később)

### Színek

| Szerep | Érték (light) | Érték (dark) |
|---|---|---|
| `--gm-bg` | `#fafafa` | `#0a0a0a` |
| `--gm-surface` | `#ffffff` | `#171717` |
| `--gm-border` | `#e5e5e5` | `#262626` |
| `--gm-text` | `#0a0a0a` | `#fafafa` |
| `--gm-text-muted` | `#525252` | `#a3a3a3` |
| `--gm-primary` | `#1a73e8` | `#5c9eff` |
| `--gm-success` | `#15803d` | `#22c55e` |
| `--gm-warning` | `#b45309` | `#f59e0b` |
| `--gm-danger` | `#b91c1c` | `#ef4444` |
| `--gm-rating` | `#f59e0b` | `#fbbf24` |

### Tipográfia

- Stack: `Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`
- Skála: 12 / 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48 px (Tailwind `text-xs` … `text-5xl`)
- Body line-height: 1.5; heading: 1.2

### Térköz

- 4px alapegység: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96
- Konténer-padding: mobile 16, tablet 24, desktop 32

### Border radius

- Inline elemek (chip, badge): 4
- Kártya: 8
- Modal/sheet: 12
- Pill (avatar, gomb teljesen kerek): 9999

## Komponens-receptek

### Hotel kártya (admin)
- Bal oldal: hotel logó / placeholder, név, város
- Jobb oldal: 4-platform score sor (logó + score), trend nyíl
- Hover: enyhe shadow lift
- Klikk: hotel részletes nézetbe navigál

### Review-sor (admin lista)
- Platform-ikon | rating (csillagok + szám) | snippet (max 2 sor) | szegmens-chip | dátum
- Kiterjesztett nézet: teljes szöveg, AI-osztályozás (sentiment, topics), válasz mező (jövőbeli)

### Score badge (widget)
- Kompakt: platform logó + szám (1 soros, 32-44px magas)
- Részletes: 2x2 grid mind a 4 platformról

### Widget review carousel
- Auto-magasság (a beágyazott oldalon nincs scrollbar a widgeten belül)
- Lapozható + auto-rotate (kikapcsolható)
- Mindig látható: platform-forrás logó + dátum (transzparencia)

## State-ek minden képernyőhöz

| State | Mit mutat |
|---|---|
| Loading | Skeleton (kártya-vázak), nem spinner |
| Empty (még nincs adat) | Illusztráció + "Még nincs review. Csatlakoztasd a Google fiókodat." + CTA gomb |
| Zero-result (szűrt) | "Nincs ilyen review. Próbálj más szűrőt." |
| Error | Konkrét üzenet + retry gomb + "Mi történt?" lenyíló |
| Offline / sync-error | Banner: "Utolsó frissítés: 3 órája. Hiba a Google API-val." |

## Widget-specifikus UX

- **Soha ne legyen layout shift** a befogadó oldalon (előre lefoglalt magasság / aspect-ratio).
- **Lazy load** alapból: csak akkor töltsön adatot, ha a viewport-ba kerül.
- **Fallback**: ha az API nem elérhető, a widget vagy nem render-el (üres div), vagy egy korábbi cache-elt verziót mutat — soha ne hiba-üzenetet a látogatónak.
- **Dark mode auto-detekció** a befogadó oldal `prefers-color-scheme`-jéből, override lehetőség.
- **Locale auto-detekció** a befogadó oldal `<html lang>`-jéből, override lehetőség.

## Akadálymentesség checklist

- [ ] Minden interaktív elem `:focus-visible` indikátorral
- [ ] `aria-label` minden ikon-only gombhoz
- [ ] Csillagok: `aria-label="4.5 csillag az 5-ből"`
- [ ] Form hibák: `aria-describedby` + látható szöveg
- [ ] Kontraszt: szöveg ≥ 4.5:1, nagy szöveg ≥ 3:1
- [ ] Csak színnel ne kommunikáljunk (sentiment-jelölés ikonnal is)
- [ ] Reduced motion: `prefers-reduced-motion` esetén anim-ok kikapcsolva

## Soha ne

- Hardcode-olt magyar/angol szöveg a komponensben (mindig `t()`)
- Modal modal felett (max 1 réteg)
- Csak hover-en megjelenő info (mobil!)
- Túl hosszú toast (3 mp max, kivéve hibaüzenet)
- Animáció >300ms az alap interakcióknál
