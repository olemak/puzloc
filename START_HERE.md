# 🚀 START HERE - Your Next Session Checklist

**Last Updated**: October 16, 2025  
**Current Phase**: Phase 1 - Backend Foundation  
**Goal**: Create the .NET backend API with authentication

---

## ✅ Before You Start (One-Time Setup on New Computer)

### 1. Install Prerequisites

```bash
# Check if you have everything installed:
node --version    # Need v20+
dotnet --version  # Need 8.0+
docker --version  # Any recent version
git --version     # Any recent version

# If missing, install:
# - Node.js: https://nodejs.org/ (or use nvm)
# - .NET SDK: https://dotnet.microsoft.com/download
# - Docker Desktop: https://www.docker.com/products/docker-desktop
```

### 2. Clone & Setup (if on new computer)

```bash
# Clone the repo
git clone <your-repo-url>
cd puzloc

# Install Node dependencies
npm install

# Start Docker services
cd infrastructure/docker
docker-compose up -d

# Verify PostgreSQL is running
docker ps  # Should see puzloc-postgres running

# Test database connection
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc -c "\dt"
# Should list all tables (users, challenges, etc.)

# Go back to root
cd ../..
```

✅ **Checkpoint**: You should have:
- All services running in Docker
- Database tables created
- Node modules installed

---

## 🎯 PHASE 1: CREATE THE BACKEND (Start Here!)

### Step 1: Create .NET Project (10 minutes)

```bash
# Create the backend project
cd apps
dotnet new webapi -n backend
cd backend

# Verify it works
dotnet run
# Press Ctrl+C to stop after you see "Now listening on: https://localhost:7001"
```

### Step 2: Add Required Packages (5 minutes)

```bash
# Still in apps/backend directory
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
dotnet add package Serilog.AspNetCore
dotnet add package Swashbuckle.AspNetCore
```

### Step 3: Create Project Structure (5 minutes)

```bash
# Create folder structure
mkdir -p src/Core/Entities
mkdir -p src/Core/Interfaces
mkdir -p src/Infrastructure/Data
mkdir -p src/Api/Controllers
mkdir -p src/Api/DTOs
mkdir -p src/Services

# Or use this one-liner:
mkdir -p src/{Core/{Entities,Interfaces},Infrastructure/Data,Api/{Controllers,DTOs},Services}
```

Your structure should look like:
```
backend/
├── src/
│   ├── Core/
│   │   ├── Entities/      # User, Challenge, Attempt, etc.
│   │   └── Interfaces/    # IRepository, IGameService, etc.
│   ├── Infrastructure/
│   │   └── Data/          # DbContext, Repositories
│   ├── Api/
│   │   ├── Controllers/   # API endpoints
│   │   └── DTOs/          # Request/Response models
│   └── Services/          # Business logic
├── Program.cs
└── appsettings.json
```

### Step 4: Configure Database Connection (10 minutes)

Create `src/Infrastructure/Data/PuzlocDbContext.cs`:

```csharp
using Microsoft.EntityFrameworkCore;
using Backend.Core.Entities;

namespace Backend.Infrastructure.Data;

public class PuzlocDbContext : DbContext
{
    public PuzlocDbContext(DbContextOptions<PuzlocDbContext> options) 
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Challenge> Challenges { get; set; } = null!;
    public DbSet<Attempt> Attempts { get; set; } = null!;
    public DbSet<GameSession> GameSessions { get; set; } = null!;
    public DbSet<UserStats> UserStats { get; set; } = null!;
    public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Table configurations will go here
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Username).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Username).IsUnique();
        });
        
        // Add other entity configurations...
    }
}
```

Update `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=puzloc;Username=puzloc_user;Password=puzloc_dev_password"
  },
  "Jwt": {
    "Secret": "your-super-secret-key-change-this-in-production-min-32-chars",
    "Issuer": "Puzloc",
    "Audience": "PuzlocApp",
    "ExpiryMinutes": 15
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

Update `Program.cs`:

```csharp
using Microsoft.EntityFrameworkCore;
using Backend.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database
builder.Services.AddDbContext<PuzlocDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### Step 5: Create Entity Models (20 minutes)

Create `src/Core/Entities/User.cs`:

```csharp
namespace Backend.Core.Entities;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
```

Create similar files for:
- `Challenge.cs`
- `Attempt.cs`
- `GameSession.cs`
- `UserStats.cs`
- `RefreshToken.cs`

(Reference: `/infrastructure/docker/postgres/init.sql` for exact schema)

### Step 6: Test Database Connection (5 minutes)

```bash
# Still in apps/backend
dotnet build

# Run the app
dotnet run

# Open browser to https://localhost:7001/swagger
# You should see Swagger UI (even if no endpoints yet)
```

✅ **Checkpoint**: You should have:
- .NET project running
- Database connection configured
- Swagger UI accessible
- No build errors

---

## 📋 DAY 1 COMPLETE! Next Tasks:

### Tomorrow's Session (Day 2):
- [ ] Create EF Core migrations
- [ ] Implement User repository
- [ ] Add JWT authentication service
- [ ] Create registration endpoint
- [ ] Create login endpoint
- [ ] Test authentication flow

### Commands for Tomorrow:

```bash
# Create migration
cd apps/backend
dotnet ef migrations add InitialCreate
dotnet ef database update

# This will sync your C# models with the existing PostgreSQL tables
```

---

## 🆘 Troubleshooting

### Docker not running?
```bash
docker-compose up -d
docker ps  # Check status
```

### Database connection fails?
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Verify you can connect
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc
```

### Port 5432 already in use?
```bash
# Check what's using it
lsof -i :5432

# Either stop that service or change port in docker-compose.yml
```

### .NET build errors?
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

---

## 📚 Quick Reference

### Useful Commands

```bash
# Backend
cd apps/backend
dotnet run              # Start dev server
dotnet watch run        # Start with hot reload
dotnet test             # Run tests
dotnet ef migrations add MyMigration  # Create migration
dotnet ef database update             # Apply migrations

# Docker
cd infrastructure/docker
docker-compose up -d       # Start all services
docker-compose down        # Stop all services
docker-compose logs -f     # View logs
docker-compose ps          # Check status

# Database
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc
\dt                    # List tables
\d users               # Describe users table
SELECT * FROM users;   # Query users
\q                     # Quit
```

### Key URLs

- Backend API: https://localhost:7001
- Swagger UI: https://localhost:7001/swagger
- pgAdmin: http://localhost:5050
- PostgreSQL: localhost:5432

### Key Files to Reference

- Database schema: `infrastructure/docker/postgres/init.sql`
- Game rules: `docs/GAME_RULES.md`
- Architecture: `docs/ARCHITECTURE.md`
- Full roadmap: `docs/ROADMAP.md`

---

## 🎯 Your Goal This Week

By end of Week 1, you should have:
- ✅ .NET project created
- ✅ Database connected
- ✅ Entity models defined
- ✅ EF Core migrations working
- ✅ Basic project structure

**You're on track if**: You can run `dotnet run` and see "Now listening on: https://localhost:7001"

---

## 💡 Pro Tips

1. **Use `dotnet watch run`** for hot reload during development
2. **Keep Swagger open** - great for testing endpoints
3. **Check `docker-compose logs`** if things break
4. **Commit often** - commit after each working step
5. **Read the docs** - everything is documented in `/docs`

---

## 🎉 Ready to Start?

1. Open a terminal
2. Navigate to your project: `cd puzloc`
3. Start Docker: `cd infrastructure/docker && docker-compose up -d && cd ../..`
4. Follow Step 1 above!

**You got this!** 🚀

---

**Questions?** Check:
- [GETTING_STARTED.md](docs/GETTING_STARTED.md) for detailed setup
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
- [ROADMAP.md](docs/ROADMAP.md) for the full plan

