# Puzloc Infrastructure

Docker-based local development infrastructure for the Puzloc platform.

## Services

### PostgreSQL Database
- **Image**: `postgres:16-alpine`
- **Port**: `5432`
- **Database**: `puzloc`
- **User**: `puzloc_user`
- **Password**: `puzloc_dev_password` (dev only!)

### Redis Cache (Optional)
- **Image**: `redis:7-alpine`
- **Port**: `6379`
- Used for caching, session storage, and rate limiting

### pgAdmin (Optional)
- **Image**: `dpage/pgadmin4`
- **Port**: `5050`
- **URL**: http://localhost:5050
- **Email**: `admin@puzloc.local`
- **Password**: `admin`

## Quick Start

### Start all services:
```bash
cd infrastructure/docker
docker-compose up -d
```

### Start specific service:
```bash
docker-compose up -d postgres
```

### Stop all services:
```bash
docker-compose down
```

### Stop and remove volumes (⚠️ deletes all data):
```bash
docker-compose down -v
```

### View logs:
```bash
docker-compose logs -f postgres
```

## Database Connection

### Connection String (.NET)
```
Host=localhost;Port=5432;Database=puzloc;Username=puzloc_user;Password=puzloc_dev_password
```

### Connection URL (Node.js)
```
postgresql://puzloc_user:puzloc_dev_password@localhost:5432/puzloc
```

### Using pgAdmin
1. Navigate to http://localhost:5050
2. Login with credentials above
3. Add new server:
   - **Name**: Puzloc Local
   - **Host**: `postgres` (Docker network) or `host.docker.internal` (if not working)
   - **Port**: `5432`
   - **Database**: `puzloc`
   - **Username**: `puzloc_user`
   - **Password**: `puzloc_dev_password`

## Database Schema

The database is automatically initialized with the schema defined in `postgres/init.sql` on first run.

### Main Tables:
- `users` - User accounts
- `challenges` - Daily puzzles for each game type
- `attempts` - Individual guess attempts
- `game_sessions` - Complete game sessions
- `user_stats` - Aggregated user statistics
- `leaderboard_entries` - Computed leaderboard data
- `achievements` - Available achievements
- `user_achievements` - Unlocked achievements
- `refresh_tokens` - JWT refresh tokens

## Database Migrations

For production, use Entity Framework Core migrations:

```bash
cd apps/backend
dotnet ef migrations add InitialCreate
dotnet ef database update
```

## Environment Variables

Create a `.env` file in the docker directory for custom configuration:

```env
# PostgreSQL
POSTGRES_DB=puzloc
POSTGRES_USER=puzloc_user
POSTGRES_PASSWORD=your_secure_password

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@puzloc.local
PGADMIN_DEFAULT_PASSWORD=your_admin_password
```

Then update docker-compose.yml:
```yaml
env_file:
  - .env
```

## Backup & Restore

### Backup database:
```bash
docker exec puzloc-postgres pg_dump -U puzloc_user puzloc > backup.sql
```

### Restore database:
```bash
docker exec -i puzloc-postgres psql -U puzloc_user puzloc < backup.sql
```

## Troubleshooting

### Port already in use:
```bash
# Check what's using the port
lsof -i :5432

# Change port in docker-compose.yml
ports:
  - "5433:5432"  # Use 5433 on host instead
```

### Permission issues:
```bash
# Reset volumes
docker-compose down -v
docker-compose up -d
```

### Connection refused:
```bash
# Check if service is healthy
docker-compose ps

# Check logs
docker-compose logs postgres
```

## Production Considerations

⚠️ **Do not use these settings in production!**

For production deployments:
- Use strong, randomly generated passwords
- Enable SSL/TLS connections
- Configure proper backup strategies
- Set up replication
- Use managed database services (AWS RDS, Azure Database, etc.)
- Implement proper secret management
- Configure connection pooling
- Set up monitoring and alerting

