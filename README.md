# GuestMemories

Multi-tenant hotel review aggregator — gyűjti és statisztikákká dolgozza fel a vendégértékeléseket Google, Meta, Booking.com és TripAdvisor felületekről, beágyazható widgetekkel.

## Repó struktúra

- `apps/api` — Node.js + Fastify backend
- `apps/admin` — Next.js admin dashboard
- `apps/widget-host` — Next.js publikus widget renderer
- `packages/*` — megosztott könyvtárak
- `supabase/` — adatbázis migrációk és edge funkciók

## Fejlesztés

Minden a `.env` fájl alapján fut. Lásd `.env.example` a kötelező változókért.

```bash
pnpm install
pnpm dev
```
