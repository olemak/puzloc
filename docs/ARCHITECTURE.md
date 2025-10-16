# Puzloc Architecture

This document describes the high-level architecture of the Puzloc multi-game puzzle platform.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Puzloc Platform                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌──────────────┐        ┌──────────────┐                │
│   │   Svelte     │        │ React Native │                │
│   │   Frontend   │        │   Mobile     │                │
│   └──────┬───────┘        └──────┬───────┘                │
│          │                       │                         │
│          └───────────┬───────────┘                         │
│                      │                                     │
│              ┌───────▼────────┐                            │
│              │   REST API     │                            │
│              │   (.NET 8)     │                            │
│              └───────┬────────┘                            │
│                      │                                     │
│         ┌────────────┼────────────┐                        │
│         │            │            │                        │
│    ┌────▼────┐  ┌───▼────┐  ┌───▼────┐                   │
│    │  Auth   │  │  Game  │  │  User  │                   │
│    │ Service │  │ Engine │  │Service │                   │
│    └────┬────┘  └───┬────┘  └───┬────┘                   │
│         │           │           │                         │
│         └───────────┼───────────┘                         │
│                     │                                     │
│              ┌──────▼────────┐                            │
│              │  PostgreSQL   │                            │
│              │   Database    │                            │
│              └───────────────┘                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Core Components

### Frontend Layer

#### Web Application (SvelteKit)
- **Responsibility**: User interface for web browsers
- **Tech**: SvelteKit, TypeScript, TailwindCSS
- **Features**:
  - Responsive design
  - Real-time game interactions
  - Leaderboards and statistics
  - User profile management
  - Daily challenge notifications

#### Mobile Application (React Native)
- **Responsibility**: Native mobile experience
- **Tech**: React Native, TypeScript
- **Features**:
  - Touch-optimized controls
  - Push notifications
  - Offline capabilities
  - Native performance

### Backend Layer

#### REST API (.NET 8)
- **Responsibility**: Business logic and data access
- **Tech**: ASP.NET Core, C#, Entity Framework Core
- **Endpoints**:

```
/api/v1/
├── auth/
│   ├── POST /register
│   ├── POST /login
│   ├── POST /refresh
│   └── POST /logout
├── games/
│   ├── numlock/
│   │   ├── GET  /challenge/daily
│   │   ├── GET  /challenge/{id}
│   │   ├── POST /guess
│   │   └── GET  /session/{sessionId}
│   └── phraselock/
│       ├── GET  /challenge/daily
│       ├── POST /guess/letter
│       └── POST /guess/phrase
├── users/
│   ├── GET    /profile
│   ├── PUT    /profile
│   ├── GET    /stats
│   └── GET    /achievements
├── leaderboard/
│   ├── GET    /{gameType}/{period}
│   └── GET    /user/{userId}
└── challenges/
    ├── GET    /daily
    └── POST   / (admin only)
```

#### Services

**Authentication Service**
- JWT token generation and validation
- Password hashing (BCrypt)
- Token refresh mechanism
- Role-based authorization

**Game Service**
- Game state management
- Guess validation
- Feedback calculation
- Score computation
- Session tracking

**User Service**
- Profile management
- Statistics aggregation
- Achievement tracking

**Challenge Service**
- Daily challenge generation
- Challenge retrieval
- Historical challenge access

### Data Layer

#### PostgreSQL Database
- **Purpose**: Persistent data storage
- **Key Tables**:
  - `users` - User accounts
  - `challenges` - Daily puzzles
  - `attempts` - Game attempts
  - `game_sessions` - Complete sessions
  - `user_stats` - Aggregated statistics
  - `leaderboard_entries` - Cached leaderboard data
  - `achievements` - Available achievements
  - `refresh_tokens` - JWT refresh tokens

#### Entity Relationships

```
┌────────┐       ┌──────────────┐       ┌──────────┐
│ users  │◄──────┤ game_sessions│──────►│challenges│
└───┬────┘       └──────┬───────┘       └──────────┘
    │                   │
    │                   │
    │            ┌──────▼────────┐
    │            │   attempts    │
    │            └───────────────┘
    │
    ├──────────►┌──────────────┐
    │           │  user_stats  │
    │           └──────────────┘
    │
    ├──────────►┌───────────────────┐
    │           │leaderboard_entries│
    │           └───────────────────┘
    │
    └──────────►┌──────────────────┐
                │user_achievements │
                └──────────────────┘
```

## Shared Packages

### @puzloc/shared-types
Common TypeScript type definitions used across frontend and backend.

### @puzloc/game-engine
Core game logic that can run on both client and server:
- Guess validation
- Feedback calculation
- Score computation

### @puzloc/api-client
Type-safe API client for frontend applications.

### @puzloc/utils
Common utility functions and constants.

## Data Flow

### NumLock Game Flow

```
1. User requests daily challenge
   ┌─────────┐     GET /api/games/numlock/challenge/daily     ┌─────────┐
   │Frontend │────────────────────────────────────────────────►│ Backend │
   └─────────┘                                                 └────┬────┘
                                                                    │
                                                            ┌───────▼────────┐
                                                            │ Create session │
                                                            │ Return masked  │
                                                            │   challenge    │
                                                            └───────┬────────┘
   ┌─────────┐                                                     │
   │Frontend │◄────────────────────────────────────────────────────┘
   └─────────┘     { challengeId, sessionId, maxAttempts }

2. User makes a guess
   ┌─────────┐     POST /api/games/numlock/guess               ┌─────────┐
   │Frontend │     { sessionId, guess: "1234" }                │ Backend │
   └─────────┘────────────────────────────────────────────────►└────┬────┘
                                                                    │
                                                        ┌───────────▼────────────┐
                                                        │ 1. Validate session    │
                                                        │ 2. Check guess         │
                                                        │ 3. Calculate feedback  │
                                                        │ 4. Update stats        │
                                                        │ 5. Check win condition │
                                                        └───────────┬────────────┘
   ┌─────────┐                                                     │
   │Frontend │◄────────────────────────────────────────────────────┘
   └─────────┘     { feedback: [{digit, status}], isWon, isGameOver }

3. Display feedback
   ┌─────────┐
   │Frontend │  Show colored feedback for each digit
   │ Update  │  Update attempt counter
   │   UI    │  Check if game won/lost
   └─────────┘
```

### PhraseLock Game Flow

Similar to NumLock, but with letter/phrase guessing mechanics.

## Authentication Flow

### Registration
```
┌────────┐    POST /auth/register     ┌────────┐
│ Client │───────────────────────────►│ Server │
└────────┘   {username, email, pwd}   └───┬────┘
                                          │
                                  ┌───────▼────────┐
                                  │1. Validate input│
                                  │2. Hash password │
                                  │3. Create user   │
                                  │4. Generate JWT  │
                                  └───────┬────────┘
┌────────┐                                │
│ Client │◄───────────────────────────────┘
└────────┘   { accessToken, refreshToken, user }
```

### Login
```
┌────────┐    POST /auth/login         ┌────────┐
│ Client │───────────────────────────►│ Server │
└────────┘   {username, password}      └───┬────┘
                                          │
                                  ┌───────▼────────┐
                                  │1. Find user    │
                                  │2. Verify pwd   │
                                  │3. Generate JWT │
                                  └───────┬────────┘
┌────────┐                                │
│ Client │◄───────────────────────────────┘
└────────┘   { accessToken, refreshToken, user }
```

### Protected Request
```
┌────────┐    GET /api/users/profile   ┌────────┐
│ Client │───────────────────────────►│ Server │
└────────┘   Authorization: Bearer JWT └───┬────┘
                                          │
                                  ┌───────▼────────┐
                                  │1. Validate JWT │
                                  │2. Extract user │
                                  │3. Authorize    │
                                  │4. Fetch data   │
                                  └───────┬────────┘
┌────────┐                                │
│ Client │◄───────────────────────────────┘
└────────┘   { user profile data }
```

## Security Considerations

### Authentication
- ✅ JWT tokens with short expiration (15 minutes)
- ✅ Refresh tokens stored securely
- ✅ Passwords hashed with BCrypt (cost factor 12)
- ✅ HTTPS only in production
- ✅ Token rotation on refresh

### Authorization
- ✅ Role-based access control (user, admin)
- ✅ Resource ownership validation
- ✅ Rate limiting on endpoints
- ✅ Input validation and sanitization

### Data Protection
- ✅ Challenge solutions stored hashed
- ✅ Prepared statements (EF Core) prevent SQL injection
- ✅ CORS configured for known origins only
- ✅ Sensitive data encrypted at rest

### Anti-Cheat Measures
- ✅ Server-side validation of all guesses
- ✅ Rate limiting on guess attempts
- ✅ Session validation and expiration
- ✅ Timing analysis for suspicious patterns
- ✅ Client-side code obfuscation (production)

## Performance Considerations

### Caching Strategy
- **Redis** (optional): Session data, leaderboards
- **EF Core**: Second-level cache for challenges
- **Frontend**: Local storage for user preferences
- **CDN**: Static assets (CSS, JS, images)

### Database Optimization
- Indexed columns: user IDs, challenge dates, game types
- Materialized views for leaderboards
- Partitioning for historical data
- Connection pooling

### API Optimization
- Pagination for list endpoints
- Selective field projection
- Compression (gzip/brotli)
- HTTP/2 support

### Frontend Optimization
- Code splitting
- Lazy loading routes
- Asset minification
- Service workers for offline support

## Scalability

### Horizontal Scaling
- Stateless API servers
- Load balancer (nginx/HAProxy)
- Database read replicas
- Redis for distributed caching

### Vertical Scaling
- Database connection pooling
- Async/await patterns throughout
- Efficient queries (no N+1 problems)

### Monitoring
- Application logs (Serilog)
- Performance metrics (Application Insights)
- Database query analytics
- Error tracking (Sentry)

## Deployment Architecture

```
                    ┌──────────────┐
                    │  CloudFlare  │
                    │  CDN + SSL   │
                    └──────┬───────┘
                           │
                 ┌─────────┴─────────┐
                 │                   │
          ┌──────▼─────┐      ┌─────▼──────┐
          │   Vercel   │      │   Azure    │
          │  (Frontend)│      │  (Backend) │
          └────────────┘      └─────┬──────┘
                                    │
                         ┌──────────┴──────────┐
                         │                     │
                  ┌──────▼────────┐    ┌──────▼────────┐
                  │  PostgreSQL   │    │    Redis      │
                  │  (Azure DB)   │    │  (Azure Cache)│
                  └───────────────┘    └───────────────┘
```

## Future Enhancements

### Phase 2
- [ ] Real-time multiplayer mode (SignalR)
- [ ] Social features (friends, challenges)
- [ ] More game types
- [ ] Achievement system completion

### Phase 3
- [ ] Mobile apps (React Native)
- [ ] Push notifications
- [ ] Offline play support
- [ ] In-app purchases

### Phase 4
- [ ] Tournament system
- [ ] Streaming integration
- [ ] Custom puzzle creator
- [ ] API for third-party integrations

## Technology Decisions

### Why .NET for Backend?
- Strong typing and performance
- Excellent tooling (Visual Studio, Rider)
- Cross-platform (Linux containers)
- Mature ecosystem (EF Core, Identity, etc.)
- Learning opportunity for team

### Why SvelteKit for Frontend?
- Excellent developer experience
- Minimal boilerplate
- Built-in SSR/SSG
- Small bundle sizes
- Reactive by default

### Why PostgreSQL?
- ACID compliance
- JSON support for flexible schemas
- Strong community and tooling
- Excellent performance
- Free and open-source

### Why Nx Monorepo?
- Shared code between apps
- Consistent tooling
- Dependency graph management
- Cached builds
- Scalable architecture

