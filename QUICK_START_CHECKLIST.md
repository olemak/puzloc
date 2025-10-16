# ⚡ Quick Start Checklist

**Print this out or keep it on a second monitor!**

---

## 🔧 ONE-TIME SETUP (New Computer)

```bash
# 1. Clone repo
git clone <repo-url> && cd puzloc

# 2. Install dependencies
npm install

# 3. Start Docker
cd infrastructure/docker && docker-compose up -d && cd ../..

# 4. Verify database
docker exec -it puzloc-postgres psql -U puzloc_user -d puzloc -c "\dt"
```

✅ **Works?** You should see list of tables. If yes, you're ready!

---

## 🎯 DAY 1: CREATE BACKEND (60 mins)

### Step 1: Create Project (10 min)
```bash
cd apps
dotnet new webapi -n backend
cd backend
dotnet run  # Test it works, then Ctrl+C
```

### Step 2: Add Packages (5 min)
```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
dotnet add package Serilog.AspNetCore
```

### Step 3: Create Folders (2 min)
```bash
mkdir -p src/{Core/{Entities,Interfaces},Infrastructure/Data,Api/{Controllers,DTOs},Services}
```

### Step 4: Setup DbContext (15 min)
- [ ] Create `src/Infrastructure/Data/PuzlocDbContext.cs`
- [ ] Update `appsettings.json` with connection string
- [ ] Update `Program.cs` to add DbContext
- [ ] See START_HERE.md for code templates

### Step 5: Create Entities (20 min)
- [ ] Create `src/Core/Entities/User.cs`
- [ ] Create other entity files (Challenge, Attempt, etc.)
- [ ] Reference: `infrastructure/docker/postgres/init.sql`

### Step 6: Test (5 min)
```bash
dotnet build
dotnet run
# Open: https://localhost:7001/swagger
```

✅ **Success?** Swagger UI loads? Great! Day 1 done! 🎉

---

## 🎯 DAY 2: AUTHENTICATION (Next Session)

```bash
# Create migrations
dotnet ef migrations add InitialCreate
dotnet ef database update

# Then implement:
# - Auth service (JWT)
# - Register endpoint
# - Login endpoint
```

---

## 🆘 QUICK FIXES

**Docker not running?**
```bash
cd infrastructure/docker && docker-compose up -d
```

**Port 5432 in use?**
```bash
lsof -i :5432  # Find what's using it
```

**Build errors?**
```bash
dotnet clean && dotnet restore && dotnet build
```

---

## 📍 KEY LOCATIONS

- **Database Schema**: `infrastructure/docker/postgres/init.sql`
- **Full Guide**: `START_HERE.md`
- **Game Rules**: `docs/GAME_RULES.md`
- **Architecture**: `docs/ARCHITECTURE.md`

---

## 🔗 KEY URLS

- **API**: https://localhost:7001
- **Swagger**: https://localhost:7001/swagger  
- **pgAdmin**: http://localhost:5050
- **PostgreSQL**: localhost:5432

---

## ⚡ SUPER QUICK START

Already set up? Jump right in:

```bash
cd puzloc
cd infrastructure/docker && docker-compose up -d && cd ../..
cd apps/backend
dotnet watch run
```

Open https://localhost:7001/swagger

**You're coding!** 🚀

---

**Stuck?** Read `START_HERE.md` for detailed steps!

