# Getting Started with Puzloc

This guide will help you set up your development environment and start working on Puzloc.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required
- **Node.js** (v20 or higher)
  ```bash
  node --version  # Should be v20+
  ```
- **.NET SDK** (8.0 or higher)
  ```bash
  dotnet --version  # Should be 8.0+
  ```
- **Docker Desktop** (for database)
  ```bash
  docker --version
  docker-compose --version
  ```

### Optional but Recommended
- **PostgreSQL Client** (psql) for database inspection
- **Visual Studio Code** with extensions:
  - C# Dev Kit
  - Svelte for VS Code
  - ESLint
  - Prettier
- **Git** for version control

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd puzloc
```

### 2. Install Dependencies

```bash
# Install Node.js dependencies (for frontend and tooling)
npm install

# Restore .NET dependencies (will do later when backend is created)
# cd apps/backend
# dotnet restore
```

### 3. Start Infrastructure Services

Start PostgreSQL and other services:

```bash
cd infrastructure/docker
docker-compose up -d

# Verify services are running
docker-compose ps

# Check PostgreSQL is healthy
docker-compose logs postgres
```

You should see:
- ✅ `puzloc-postgres` running on port 5432
- ✅ `puzloc-redis` running on port 6379
- ✅ `puzloc-pgadmin` running on port 5050

### 4. Verify Database Setup

Connect to the database to verify initialization:

```bash
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc

# Inside psql:
\dt  # List all tables
\q   # Quit
```

You should see tables: `users`, `challenges`, `attempts`, etc.

## Development Workflow

### Project Structure

```
puzloc/
├── apps/
│   ├── backend/              # .NET API (to be created)
│   └── frontend-svelte/      # Svelte app (to be created)
├── packages/
│   ├── shared-types/         # Shared TypeScript types (to be created)
│   ├── game-engine/          # Game logic (to be created)
│   └── api-client/           # API client (to be created)
├── infrastructure/
│   └── docker/               # ✅ Set up
├── docs/                     # ✅ Documentation
└── nx.json                   # ✅ Nx configuration
```

### Next Steps

Now that the infrastructure is set up, you can:

#### 1. **Create the Backend Application**

```bash
cd apps
dotnet new webapi -n backend
cd backend

# Add required packages
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
```

#### 2. **Create the Frontend Application**

```bash
cd apps
npm create svelte@latest frontend-svelte
cd frontend-svelte
npm install
```

#### 3. **Create Shared Packages**

```bash
# Create shared-types package
mkdir -p packages/shared-types/src
cd packages/shared-types
npm init -y
npm install -D typescript

# Create game-engine package
mkdir -p packages/game-engine/src
cd packages/game-engine
npm init -y
npm install -D typescript jest
```

## Running the Application

Once apps are created:

### Start Everything at Once

```bash
# From project root
npm start
```

This will start:
- Backend API on https://localhost:7001
- Frontend on http://localhost:5173

### Start Individual Applications

```bash
# Backend only
nx serve backend
# or
cd apps/backend && dotnet run

# Frontend only
nx serve frontend-svelte
# or
cd apps/frontend-svelte && npm run dev
```

### Start with Logging

```bash
# Backend with detailed logging
cd apps/backend
dotnet run --environment Development

# Frontend with debugging
cd apps/frontend-svelte
npm run dev -- --debug
```

## Testing

### Run All Tests

```bash
npm test
```

### Test Specific Application

```bash
# Backend tests
cd apps/backend
dotnet test

# Frontend tests
cd apps/frontend-svelte
npm test
```

### Test Shared Packages

```bash
cd packages/game-engine
npm test
```

## Building for Production

### Build All Applications

```bash
npm run build
```

### Build Specific Application

```bash
# Backend
cd apps/backend
dotnet publish -c Release -o ./publish

# Frontend
cd apps/frontend-svelte
npm run build
```

## Database Operations

### Access pgAdmin

1. Navigate to http://localhost:5050
2. Login:
   - Email: `admin@puzloc.local`
   - Password: `admin`
3. Add server:
   - Name: Puzloc Local
   - Host: `postgres`
   - Port: `5432`
   - Database: `puzloc`
   - Username: `puzloc_user`
   - Password: `puzloc_dev_password`

### Direct Database Access

```bash
# Via Docker
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc

# Common queries
SELECT * FROM users;
SELECT * FROM challenges WHERE challenge_date = CURRENT_DATE;
SELECT * FROM game_sessions WHERE is_won = true;
```

### Database Migrations (EF Core)

```bash
cd apps/backend

# Create migration
dotnet ef migrations add MigrationName

# Apply migrations
dotnet ef database update

# Rollback migration
dotnet ef database update PreviousMigrationName

# Remove last migration
dotnet ef migrations remove
```

### Reset Database

```bash
cd infrastructure/docker
docker-compose down -v  # ⚠️ This deletes all data!
docker-compose up -d
```

## Common Issues

### Port Already in Use

**Problem**: PostgreSQL port 5432 is already in use.

**Solution**:
```bash
# Find what's using the port
lsof -i :5432

# Kill the process or change port in docker-compose.yml
ports:
  - "5433:5432"  # Use 5433 on host
```

### Docker Connection Issues

**Problem**: Can't connect to PostgreSQL from app.

**Solution**:
```bash
# Check Docker network
docker network ls
docker network inspect docker_default

# Use correct host in connection string:
# From host machine: localhost:5432
# From another container: postgres:5432
```

### .NET SDK Not Found

**Problem**: `dotnet: command not found`

**Solution**:
```bash
# macOS
brew install --cask dotnet-sdk

# Windows
# Download from https://dotnet.microsoft.com/download

# Linux (Ubuntu)
sudo apt-get install -y dotnet-sdk-8.0
```

### Node Version Issues

**Problem**: npm install fails with node version error.

**Solution**:
```bash
# Using nvm
nvm install 20
nvm use 20

# Using brew (macOS)
brew upgrade node
```

## Development Tips

### Hot Reload

Both frontend and backend support hot reload:

- **Backend**: Edit .cs files and save - dotnet watch will reload
- **Frontend**: Edit .svelte files and save - Vite HMR will update instantly

### API Testing

Use the Swagger UI when backend is running:
- Navigate to https://localhost:7001/swagger
- Test endpoints directly in the browser

Or use curl/HTTPie:

```bash
# Register user
curl -X POST https://localhost:7001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"Test123!"}'

# Login
curl -X POST https://localhost:7001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"Test123!"}'

# Get daily challenge (with auth)
curl -X GET https://localhost:7001/api/games/numlock/challenge/daily \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Debugging

**Backend (.NET)**:
- Set breakpoints in VS Code or Visual Studio
- Press F5 to start debugging
- Or use `dotnet run --debug`

**Frontend (Svelte)**:
- Use browser DevTools
- Install Svelte DevTools extension
- Use `console.log()` and debugger statements

### Database Seeding

Add test data for development:

```bash
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc

-- Insert test challenge
INSERT INTO challenges (game_type, challenge_date, solution, solution_hash, difficulty)
VALUES ('numlock', CURRENT_DATE, '1234', 'hash_here', 'medium');

-- Insert test user
INSERT INTO users (username, email, password_hash, display_name)
VALUES ('testuser', 'test@example.com', 'bcrypt_hash_here', 'Test User');
```

## Learning Resources

### .NET
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [Entity Framework Core](https://docs.microsoft.com/ef/core)
- [.NET API Tutorial](https://docs.microsoft.com/aspnet/core/tutorials/first-web-api)

### SvelteKit
- [SvelteKit Documentation](https://kit.svelte.dev/docs)
- [Svelte Tutorial](https://svelte.dev/tutorial)
- [SvelteKit Blog Tutorial](https://kit.svelte.dev/docs/introduction)

### PostgreSQL
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)

### Nx Monorepo
- [Nx Documentation](https://nx.dev)
- [Nx .NET Plugin](https://www.nx.dev/packages/dotnet)

## Getting Help

- Check the [Architecture Documentation](./ARCHITECTURE.md)
- Review [API Documentation](./api/) (when created)
- Check GitHub Issues
- Ask in team chat

## Next Steps

1. ✅ Infrastructure is set up
2. ⬜ Create backend application
3. ⬜ Set up Entity Framework and models
4. ⬜ Implement authentication endpoints
5. ⬜ Create frontend application
6. ⬜ Build game UI components
7. ⬜ Implement game logic in shared packages
8. ⬜ Connect frontend to backend
9. ⬜ Add tests
10. ⬜ Deploy!

Happy coding! 🚀

