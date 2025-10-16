# 🎮 Puzloc - Multi-Game Puzzle Platform

[![GitHub repo](https://img.shields.io/badge/GitHub-puzloc-blue?logo=github)](https://github.com/olemak/puzloc)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Svelte](https://img.shields.io/badge/Svelte-Kit-FF3E00?logo=svelte)](https://kit.svelte.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)](https://www.postgresql.org/)

A monorepo project for exploring modern full-stack technologies through building an engaging puzzle game platform.

## 🎯 Concept

**Puzloc** (Puzzle Lock) is a collection of puzzle games where players attempt to "unlock" challenges through logic and deduction.

### Game 1: NumLock 🔢
A Wordle-inspired number guessing game with a keypad interface.

**How it works:**
- Players have to guess a 4-digit code
- Each guess provides feedback:
  - ❌ **Gray**: Digit not in the code
  - 🟡 **Yellow**: Digit in code but wrong position
  - 🟢 **Green**: Digit correct and in right position
- Limited attempts to crack the code
- Daily challenges with leaderboards

### Game 2: PhraseLock 📝
A Hangman/Countdown-style phrase guessing game.

**How it works:**
- Players see a masked phrase: `*** **** ***** ***`
- Can guess individual letters or the whole phrase
- Optional: Unlock letters using "coins" or attempts
- Daily phrases with varying difficulty
- Category hints available

## ⚡ Quick Start

**Just want to start coding?**

```bash
# 1. Clone and setup
git clone https://github.com/olemak/puzloc.git
cd puzloc
npm install

# 2. Start development environment
npm run dev

# 3. Create backend (automated)
npm run setup:backend

# 4. Start coding!
cd apps/backend
dotnet watch run
```

**OR** follow the detailed guide: **[START_HERE.md](START_HERE.md)** 📖

### Helpful Commands

```bash
npm run dev              # Start Docker services
npm run setup:backend    # Auto-create backend project
npm run docker:start     # Start Docker only
npm run docker:stop      # Stop Docker services
npm run db               # Open PostgreSQL CLI
```

## 🏗️ Architecture

### Monorepo Structure
```
puzloc/
├── apps/
│   ├── backend/              # .NET Web API
│   │   ├── src/
│   │   │   ├── Api/          # API controllers & endpoints
│   │   │   ├── Core/         # Domain models & business logic
│   │   │   ├── Infrastructure/ # Database, auth, external services
│   │   │   └── Services/     # Game logic services
│   │   └── tests/
│   ├── frontend-svelte/      # Svelte web application
│   │   ├── src/
│   │   │   ├── lib/
│   │   │   │   ├── components/ # Shared UI components
│   │   │   │   ├── games/     # Game-specific components
│   │   │   │   └── services/  # API client, state management
│   │   │   └── routes/        # SvelteKit routes
│   │   └── tests/
│   └── frontend-native/      # React Native app (future)
├── packages/
│   ├── shared-types/         # Shared TypeScript types
│   ├── game-engine/          # Shared game logic
│   └── api-client/           # Typed API client
├── infrastructure/
│   └── docker/
│       ├── docker-compose.yml
│       └── postgres/
└── docs/
    ├── api/                  # API documentation
    └── architecture/         # Architecture decisions
```

### Technology Stack

#### Backend
- **Framework**: .NET 8 Web API
- **Database**: PostgreSQL
- **ORM**: Entity Framework Core
- **Authentication**: JWT tokens
- **Testing**: xUnit

#### Frontend (Web)
- **Framework**: SvelteKit
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **State**: Svelte stores
- **API Client**: Custom typed client

#### Infrastructure
- **Database**: PostgreSQL (Docker)
- **Caching**: Redis (optional, future)
- **Containerization**: Docker & Docker Compose

#### Monorepo
- **Tool**: Nx
- **Package Manager**: npm

## 🗄️ Database Schema (Initial)

```sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Daily Challenges
CREATE TABLE challenges (
    id UUID PRIMARY KEY,
    game_type VARCHAR(20) NOT NULL, -- 'numlock' or 'phraselock'
    challenge_date DATE NOT NULL,
    solution TEXT NOT NULL, -- encrypted/hashed
    difficulty VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(game_type, challenge_date)
);

-- Game Attempts
CREATE TABLE attempts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    challenge_id UUID REFERENCES challenges(id),
    guess TEXT NOT NULL,
    result JSONB NOT NULL, -- Feedback data
    attempt_number INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User Stats
CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    game_type VARCHAR(20) NOT NULL,
    games_played INT DEFAULT 0,
    games_won INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    max_streak INT DEFAULT 0,
    average_attempts DECIMAL(4,2),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, game_type)
);

-- Leaderboards (computed view or materialized)
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    game_type VARCHAR(20) NOT NULL,
    period VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'all_time'
    score INT NOT NULL,
    rank INT,
    calculated_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 Getting Started

### Prerequisites
- Node.js 20+ (for frontend & tooling)
- .NET 8 SDK
- Docker & Docker Compose
- PostgreSQL (via Docker)

### Setup

1. **Clone and install dependencies:**
```bash
git clone <repo-url>
cd puzloc
npm install
```

2. **Start PostgreSQL:**
```bash
cd infrastructure/docker
docker-compose up -d postgres
```

3. **Run backend:**
```bash
cd apps/backend
dotnet restore
dotnet run
```

4. **Run frontend:**
```bash
cd apps/frontend-svelte
npm install
npm run dev
```

## 🎮 Game Logic

### NumLock Algorithm
```typescript
function checkGuess(guess: string, solution: string): Feedback[] {
  // Compare each digit
  // Return array of: 'correct' | 'wrong-position' | 'not-in-answer'
}
```

### PhraseLock Algorithm
```typescript
function revealLetter(phrase: string, guessedLetters: Set<string>): string {
  // Reveal guessed letters, keep rest masked
}
```

## 📈 Future Features

- [ ] **More Games**: Add Sudoku, Crossword, Logic puzzles
- [ ] **Social Features**: Friends, challenges, shared scores
- [ ] **Achievements**: Badges, milestones, rewards
- [ ] **Multiplayer**: Head-to-head challenges
- [ ] **Mobile App**: React Native or Flutter
- [ ] **Analytics**: Game difficulty balancing, player insights
- [ ] **Observability**: Structured logging, metrics (Serilog + Seq?)

## 🧪 Learning Goals

This project is designed to explore:
- ✅ .NET backend development
- ✅ PostgreSQL database design
- ✅ JWT authentication
- ✅ SvelteKit frontend
- ✅ Nx monorepo management
- ✅ Docker containerization
- ✅ RESTful API design
- ✅ TypeScript type safety across stack

## 📝 License

MIT

## 👤 Author

Built as a learning project to explore modern full-stack technologies.

