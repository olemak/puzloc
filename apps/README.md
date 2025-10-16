# Puzloc Applications

This directory contains all applications (deployable units) in the Puzloc monorepo.

## Applications

### 🔧 backend/
**.NET 8 Web API**

The main backend service providing:
- RESTful API for all game operations
- JWT-based authentication & authorization
- Game logic and validation
- Database access via Entity Framework Core
- Real-time features (SignalR for multiplayer, future)

**Tech Stack:**
- .NET 8
- ASP.NET Core Web API
- Entity Framework Core
- PostgreSQL
- JWT Authentication
- xUnit for testing

**API Endpoints:**
- `/api/auth/*` - Authentication (register, login, refresh)
- `/api/users/*` - User profile management
- `/api/games/numlock/*` - NumLock game endpoints
- `/api/games/phraselock/*` - PhraseLock game endpoints
- `/api/challenges/*` - Daily challenges
- `/api/leaderboard/*` - Leaderboard queries
- `/api/stats/*` - User statistics

**Getting Started:**
```bash
cd backend
dotnet restore
dotnet run
# API will be available at https://localhost:7001
```

---

### 🎨 frontend-svelte/
**SvelteKit Web Application**

Modern, responsive web interface for playing Puzloc games.

**Features:**
- Responsive game interfaces
- Real-time feedback animations
- User authentication
- Leaderboards and statistics
- Daily challenge tracking
- Profile management

**Tech Stack:**
- SvelteKit
- TypeScript
- TailwindCSS
- Svelte stores for state management
- Typed API client

**Getting Started:**
```bash
cd frontend-svelte
npm install
npm run dev
# App will be available at http://localhost:5173
```

---

### 📱 frontend-native/ (Future)
**React Native Mobile App**

Cross-platform mobile application for iOS and Android.

**Planned Features:**
- Native mobile experience
- Push notifications for daily challenges
- Offline play (cached challenges)
- Touch-optimized game controls
- Native sharing capabilities

**Tech Stack (Planned):**
- React Native
- TypeScript
- React Navigation
- React Query
- Async Storage

---

## Creating New Applications

### Adding a .NET Application:
```bash
# From monorepo root
cd apps
dotnet new webapi -n my-new-service
```

### Adding a SvelteKit Application:
```bash
# From monorepo root
cd apps
npm create svelte@latest my-new-app
```

### Adding to Nx:
Create a `project.json` in your new app directory:
```json
{
  "name": "my-new-app",
  "sourceRoot": "apps/my-new-app/src",
  "projectType": "application",
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "npm run build",
        "cwd": "apps/my-new-app"
      }
    },
    "serve": {
      "executor": "nx:run-commands",
      "options": {
        "command": "npm run dev",
        "cwd": "apps/my-new-app"
      }
    }
  }
}
```

## Inter-Application Communication

### Backend ↔ Frontend
- RESTful JSON API
- JWT tokens in Authorization headers
- WebSocket for real-time features (future)

### Shared Types
Use the `@puzloc/shared-types` package for type safety across applications.

## Development Workflow

### Start all applications:
```bash
# From monorepo root
npm start
```

### Start specific application:
```bash
nx serve backend
nx serve frontend-svelte
```

### Build all applications:
```bash
npm run build
```

### Run tests:
```bash
npm test
```

## Environment Variables

Each application should have its own `.env` file:

**backend/.env:**
```env
DATABASE_URL=postgresql://puzloc_user:puzloc_dev_password@localhost:5432/puzloc
JWT_SECRET=your-secret-key
JWT_ISSUER=Puzloc
JWT_AUDIENCE=PuzlocApp
ASPNETCORE_ENVIRONMENT=Development
```

**frontend-svelte/.env:**
```env
VITE_API_URL=https://localhost:7001
VITE_API_TIMEOUT=30000
```

## Deployment

### Backend:
- Containerize with Docker
- Deploy to Azure App Service / AWS ECS / Cloud Run
- Configure connection strings via environment variables

### Frontend (SvelteKit):
- Build for Node adapter (SSR)
- Deploy to Vercel / Netlify / Cloud Run
- Configure API URL via environment variables

### Frontend (React Native):
- Build for iOS via Xcode
- Build for Android via Gradle
- Publish to App Store / Google Play

## Architecture Principles

1. **Separation of Concerns**: Each app has a single responsibility
2. **API-First**: Backend exposes well-documented REST APIs
3. **Type Safety**: Shared types ensure contract consistency
4. **Testability**: Unit, integration, and E2E tests for all apps
5. **Scalability**: Apps can be scaled independently

