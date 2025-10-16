#!/bin/bash
# Puzloc Backend Setup Script
# Automates the initial backend project creation

set -e  # Exit on error

echo "🚀 Puzloc Backend Setup Script"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET SDK not found. Please install from https://dotnet.microsoft.com/download${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker Desktop${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Check if backend already exists
if [ -d "apps/backend" ]; then
    echo -e "${YELLOW}⚠️  Backend directory already exists!${NC}"
    read -p "Do you want to delete it and start fresh? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf apps/backend
        echo -e "${GREEN}✅ Removed existing backend${NC}"
    else
        echo "Exiting..."
        exit 0
    fi
fi

# Start Docker services
echo "Starting Docker services..."
cd infrastructure/docker
if ! docker-compose ps | grep -q "Up"; then
    docker-compose up -d
    echo -e "${GREEN}✅ Docker services started${NC}"
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
else
    echo -e "${GREEN}✅ Docker services already running${NC}"
fi
cd ../..

# Test database connection
echo "Testing database connection..."
if docker exec puzloc-postgres psql -U puzloc_user -d puzloc -c "\dt" &> /dev/null; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Database connection failed${NC}"
    exit 1
fi
echo ""

# Create backend project
echo "Creating .NET Web API project..."
cd apps
dotnet new webapi -n backend --no-https false
cd backend
echo -e "${GREEN}✅ Backend project created${NC}"
echo ""

# Add NuGet packages
echo "Adding required NuGet packages..."
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0
dotnet add package BCrypt.Net-Next --version 4.0.3
dotnet add package Serilog.AspNetCore --version 8.0.0
echo -e "${GREEN}✅ Packages added${NC}"
echo ""

# Create directory structure
echo "Creating project structure..."
mkdir -p src/Core/Entities
mkdir -p src/Core/Interfaces
mkdir -p src/Infrastructure/Data
mkdir -p src/Api/Controllers
mkdir -p src/Api/DTOs
mkdir -p src/Services
echo -e "${GREEN}✅ Project structure created${NC}"
echo ""

# Test build
echo "Testing build..."
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
echo ""

# Success message
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Backend setup complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "1. cd apps/backend"
echo "2. Edit appsettings.json (see START_HERE.md)"
echo "3. Create entity models in src/Core/Entities/"
echo "4. Create DbContext in src/Infrastructure/Data/"
echo "5. dotnet run"
echo ""
echo "📚 See START_HERE.md for detailed instructions"
echo "🚀 Happy coding!"

