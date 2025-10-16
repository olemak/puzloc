#!/bin/bash
# Puzloc Development Environment Startup Script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🎮 Starting Puzloc Development Environment${NC}"
echo ""

# Start Docker services
echo "Starting Docker services..."
cd infrastructure/docker
docker-compose up -d
echo -e "${GREEN}✅ Docker services started${NC}"
cd ../..

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
sleep 3

# Check PostgreSQL
if docker exec puzloc-postgres pg_isready -U puzloc_user > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL ready${NC}"
else
    echo -e "${YELLOW}⚠️  PostgreSQL not ready yet, waiting...${NC}"
    sleep 3
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Development environment ready!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Services running:"
echo "  📊 PostgreSQL: localhost:5432"
echo "  🔴 Redis: localhost:6379"
echo "  🖥️  pgAdmin: http://localhost:5050"
echo ""

# Check if backend exists
if [ -d "apps/backend" ]; then
    echo "To start backend:"
    echo "  cd apps/backend && dotnet watch run"
    echo ""
fi

# Check if frontend exists
if [ -d "apps/frontend-svelte" ]; then
    echo "To start frontend:"
    echo "  cd apps/frontend-svelte && npm run dev"
    echo ""
fi

if [ ! -d "apps/backend" ]; then
    echo "To create backend:"
    echo "  ./scripts/setup-backend.sh"
    echo "  OR see START_HERE.md for manual steps"
    echo ""
fi

echo "To stop services:"
echo "  npm run stop"
echo ""
echo "Happy coding! 🚀"

