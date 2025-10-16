# Puzloc Scripts

Helpful automation scripts for development.

## Available Scripts

### `dev.sh`
**Start the development environment**

```bash
./scripts/dev.sh
# OR
npm run dev
```

What it does:
- Starts Docker services (PostgreSQL, Redis, pgAdmin)
- Waits for services to be ready
- Shows helpful next steps

### `setup-backend.sh`
**Automated .NET backend project creation**

```bash
./scripts/setup-backend.sh
# OR
npm run setup:backend
```

What it does:
- Checks prerequisites (.NET, Docker)
- Starts Docker services if needed
- Creates .NET Web API project
- Adds required NuGet packages
- Creates project structure
- Runs initial build test

**Note**: This is a one-time setup. After running, you'll need to manually:
- Configure `appsettings.json`
- Create entity models
- Set up DbContext
- See [START_HERE.md](../START_HERE.md) for details

## NPM Script Shortcuts

These can be run from the project root:

```bash
npm run dev              # Start dev environment
npm run setup:backend    # Setup backend project
npm run docker:start     # Start Docker services
npm run docker:stop      # Stop Docker services  
npm run docker:logs      # View Docker logs
npm run db               # Open PostgreSQL CLI
```

## Direct Usage

Scripts can also be run directly:

```bash
cd puzloc

# Start dev environment
./scripts/dev.sh

# Setup backend
./scripts/setup-backend.sh
```

## Creating New Scripts

When adding new scripts:

1. Create the script file in this directory
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add npm script in `package.json`
4. Document it here

### Template

```bash
#!/bin/bash
# Script description

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Your script starting...${NC}"

# Your logic here

echo -e "${GREEN}✅ Done!${NC}"
```

## Troubleshooting

### Permission denied
```bash
chmod +x scripts/*.sh
```

### Script not found
```bash
# Run from project root
cd /path/to/puzloc
./scripts/script-name.sh
```

### Docker errors
```bash
# Check Docker is running
docker ps

# Restart Docker Desktop if needed
```

