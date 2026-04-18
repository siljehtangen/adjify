# Adjify

A multiplayer adjective storytelling game where players collaborate (or compete) to fill in the blanks and build stories together.

## What it does

Adjify lets players join rooms and play one of three game modes:

- **Fill & Reveal** — A story is shown with `[ADJ]` blanks. Players fill them in solo or as a group, then the completed story is revealed.
- **Rotating Chain** — 3–6 players alternate between writing sentences and filling adjective blanks. No one ever sees the full story until the end.
- **Adjective Battle** — A master player creates a prompt. Everyone independently fills the blanks and writes a continuation, then the group votes on the best result.

Authentication is handled via Google OAuth through Supabase. Rooms are real-time using WebSockets.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| Backend API & WebSockets | Node.js + TypeScript + Express + Socket.io |
| Database & Auth | Supabase (PostgreSQL + Google OAuth) |
| Navigation (app) | GoRouter |
| Environment config (app) | envied + build_runner |

The majority of the product is Flutter/Dart. TypeScript is used only for the backend server — real-time room management, game state, and auth middleware.

---

## Project Structure

```
adjify/
├── app/                     # Flutter mobile app
│   └── lib/
│       ├── main.dart        # Entry point, Supabase init
│       ├── router.dart      # GoRouter navigation
│       ├── config/env.dart  # Environment variables
│       ├── models/          # Dart data models
│       ├── screens/         # UI screens
│       ├── services/        # API + socket clients
│       └── widgets/         # Shared UI components
│
├── backend/                 # Node.js + TypeScript server
│   └── src/
│       ├── index.ts         # Express + Socket.io entry point
│       ├── middleware/      # JWT auth (Supabase JWKS)
│       ├── routes/          # REST endpoints
│       ├── services/        # Room, story, chain, battle logic
│       └── types/           # Shared TypeScript types
│
└── supabase/
    └── migrations/
        ├── 001_initial_schema.sql   # Full schema + RLS policies
        └── 002_rpc.sql              # increment_vote RPC
```

---

## Database Tables

`profiles` · `rooms` · `room_players` · `stories` · `story_blanks` · `chain_segments` · `battle_entries` · `votes`

---

## Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Node.js 18+
- A [Supabase](https://supabase.com) project with Google OAuth enabled

### 1. Environment variables

```bash
# Backend
cp backend/.env.example backend/.env

# Flutter app
cp app/.env.example app/.env
```

Fill in your Supabase URL, anon key, and service role key.

### 2. Backend

```bash
cd backend
npm install
npm run dev
```

### 3. Flutter app

```bash
cd app
flutter pub get
flutter pub run build_runner build
flutter run
```

### 4. Database

Apply migrations via the Supabase CLI or dashboard:

```bash
supabase db push
```

Then enable **Google OAuth** in your Supabase project under Authentication → Providers.
