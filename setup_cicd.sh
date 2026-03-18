#!/bin/bash
# ============================================================================
#  setup_cicd.sh — Script universal para CI/CD de proyectos Spring Boot
# ============================================================================
#  Autor: Jose Marco (TodoEconometria)
#  Repo:  https://github.com/TodoEconometria/spring-boot-cicd-template
#
#  ¿Qué hace este script?
#  1. Inicializa git (si no existe)
#  2. Crea .env con secretos (contraseñas BD, Docker Hub)
#  3. Genera docker-compose.yml con variables de entorno
#  4. Genera GitHub Actions workflow (CI/CD completo)
#  5. Genera application-docker.properties para producción
#  6. Hace el primer commit y push
#  7. Configura los secrets en GitHub
#
#  USO:
#    chmod +x setup_cicd.sh
#    ./setup_cicd.sh
#
#  REQUISITOS:
#    - Git, GitHub CLI (gh), Docker (opcional para test local)
# ============================================================================

set -e

# ═══════════════════════════════════════════════════════════════
# CONFIGURACIÓN — Cambia estos valores para tu proyecto
# ═══════════════════════════════════════════════════════════════

# Nombre del proyecto (se usa para imagen Docker, BD, etc.)
PROJECT_NAME="pizzeria-spring"

# Tu usuario/organización de GitHub
GITHUB_USER="TodoEconometria"

# Puerto de la aplicación Spring Boot
APP_PORT="8081"

# Base de datos
DB_NAME="pizzeria"
DB_USER="postgres"
DB_PASSWORD="$(openssl rand -base64 16 2>/dev/null || echo 'CambiaEstaPassword123!')"

# Docker Hub
DOCKERHUB_USER=""  # Déjalo vacío si no tienes cuenta aún

# Java version (17, 21...)
JAVA_VERSION="17"

# ═══════════════════════════════════════════════════════════════
# COLORES Y FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

paso() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${GREEN}  ✅ PASO $1: $2${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
info() { echo -e "${CYAN}  ℹ️  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠️  $1${NC}"; }
error() { echo -e "${RED}  ❌ $1${NC}"; exit 1; }
ok() { echo -e "${GREEN}  ✔  $1${NC}"; }

# ═══════════════════════════════════════════════════════════════
# VERIFICACIONES PREVIAS
# ═══════════════════════════════════════════════════════════════
echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║   🚀 Setup CI/CD para Spring Boot + PostgreSQL + Docker    ║${NC}"
echo -e "${BOLD}${CYAN}║   Proyecto: ${PROJECT_NAME}$(printf '%*s' $((37 - ${#PROJECT_NAME})) '')║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"

# Verificar que estamos en la raíz del proyecto
if [ ! -f "pom.xml" ]; then
    error "No se encontró pom.xml. Ejecuta este script desde la raíz del proyecto Spring Boot."
fi

# Verificar herramientas necesarias
for cmd in git gh; do
    if ! command -v $cmd &>/dev/null; then
        error "Se necesita '$cmd'. Instálalo primero."
    fi
done

# Verificar login de GitHub CLI
if ! gh auth status &>/dev/null; then
    error "No has iniciado sesión en GitHub CLI. Ejecuta: gh auth login"
fi

# ═══════════════════════════════════════════════════════════════
# PASO 1: Archivo .env (secretos locales)
# ═══════════════════════════════════════════════════════════════
paso "1" "Creando archivo .env con secretos"

if [ -f ".env" ]; then
    warn ".env ya existe. Se mantiene el existente."
else
    cat > .env << EOF
# ════════════════════════════════════════════════
# Variables de entorno — NO SUBIR A GIT
# ════════════════════════════════════════════════

# Base de datos PostgreSQL
POSTGRES_DB=${DB_NAME}
POSTGRES_USER=${DB_USER}
POSTGRES_PASSWORD=${DB_PASSWORD}

# Aplicación Spring Boot
SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/${DB_NAME}
SPRING_DATASOURCE_USERNAME=${DB_USER}
SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}

# Docker Hub (rellenar cuando tengas cuenta)
DOCKERHUB_USERNAME=${DOCKERHUB_USER}
DOCKERHUB_TOKEN=
EOF
    ok "Archivo .env creado con contraseña generada aleatoriamente"
    info "Password BD: ${DB_PASSWORD}"
fi

# Asegurar que .env está en .gitignore
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo -e "\n# Secretos locales\n.env" >> .gitignore
    ok ".env añadido a .gitignore"
fi

# ═══════════════════════════════════════════════════════════════
# PASO 2: docker-compose.yml con variables de entorno
# ═══════════════════════════════════════════════════════════════
paso "2" "Generando docker-compose.yml (sin secretos hardcodeados)"

cat > docker-compose.yml << 'COMPOSE_EOF'
# ════════════════════════════════════════════════════════════════
# Docker Compose — Spring Boot + PostgreSQL + Adminer
# ════════════════════════════════════════════════════════════════
# Uso:
#   docker compose up -d          (arrancar todo)
#   docker compose logs -f app    (ver logs de la app)
#   docker compose down -v        (parar y borrar volúmenes)
# ════════════════════════════════════════════════════════════════

services:
  # ─── Aplicación Spring Boot ──────────────────────────────────
  app:
    build: .
    ports:
      - "${APP_PORT:-8081}:${APP_PORT:-8081}"
    environment:
      - SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL:-jdbc:postgresql://db:5432/pizzeria}
      - SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME:-postgres}
      - SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD:-secret}
      - SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver
      - SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_SQL_INIT_MODE=never
      - SPRING_H2_CONSOLE_ENABLED=false
    depends_on:
      db:
        condition: service_healthy
    restart: on-failure

  # ─── PostgreSQL ──────────────────────────────────────────────
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB=${POSTGRES_DB:-pizzeria}
      - POSTGRES_USER=${POSTGRES_USER:-postgres}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-secret}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 5s
      timeout: 5s
      retries: 5

  # ─── Adminer (panel web para ver la BD) ──────────────────────
  adminer:
    image: adminer
    ports:
      - "9090:8080"
    depends_on:
      db:
        condition: service_healthy

volumes:
  postgres_data:
COMPOSE_EOF

ok "docker-compose.yml generado con variables de entorno"

# ═══════════════════════════════════════════════════════════════
# PASO 3: application-docker.properties
# ═══════════════════════════════════════════════════════════════
paso "3" "Creando perfil Docker para Spring Boot"

PROPS_DIR="src/main/resources"
DOCKER_PROPS="${PROPS_DIR}/application-docker.properties"

if [ ! -f "$DOCKER_PROPS" ]; then
    cat > "$DOCKER_PROPS" << 'PROPS_EOF'
# ════════════════════════════════════════════════
# Perfil "docker" — Se activa en contenedores
# ════════════════════════════════════════════════
# Las variables ${...} se resuelven desde environment del docker-compose

spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

spring.h2.console.enabled=false
spring.sql.init.mode=never

server.port=${APP_PORT:8081}
PROPS_EOF
    ok "application-docker.properties creado"
else
    warn "application-docker.properties ya existe, se mantiene"
fi

# ═══════════════════════════════════════════════════════════════
# PASO 4: GitHub Actions Workflow
# ═══════════════════════════════════════════════════════════════
paso "4" "Generando GitHub Actions CI/CD pipeline"

mkdir -p .github/workflows

cat > .github/workflows/ci-cd.yml << 'WORKFLOW_EOF'
# ════════════════════════════════════════════════════════════════
# CI/CD Pipeline — Spring Boot + Docker
# ════════════════════════════════════════════════════════════════
# Qué hace:
#   1. Compila y ejecuta tests con Maven
#   2. Construye imagen Docker
#   3. (Opcional) Sube imagen a Docker Hub
#
# Secrets necesarios en GitHub:
#   - DOCKERHUB_USERNAME  (opcional, para push a Docker Hub)
#   - DOCKERHUB_TOKEN     (opcional, para push a Docker Hub)
# ════════════════════════════════════════════════════════════════

name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  # ─── Job 1: Compilar y testear ───────────────────────────────
  build-and-test:
    name: "🔨 Build & Test"
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: pizzeria_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd="pg_isready -U postgres"
          --health-interval=5s
          --health-timeout=5s
          --health-retries=5

    steps:
      - name: "📥 Checkout código"
        uses: actions/checkout@v4

      - name: "☕ Configurar JDK 17"
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: "🧪 Compilar y ejecutar tests"
        run: mvn clean verify -B
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/pizzeria_test
          SPRING_DATASOURCE_USERNAME: postgres
          SPRING_DATASOURCE_PASSWORD: test_password

      - name: "📊 Subir reportes de test"
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-reports
          path: target/surefire-reports/

  # ─── Job 2: Construir imagen Docker ─────────────────────────
  docker-build:
    name: "🐳 Docker Build"
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.ref == 'refs/heads/main'

    steps:
      - name: "📥 Checkout código"
        uses: actions/checkout@v4

      - name: "🐳 Configurar Docker Buildx"
        uses: docker/setup-buildx-action@v3

      - name: "🔑 Login en Docker Hub"
        if: ${{ secrets.DOCKERHUB_USERNAME != '' }}
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: "📋 Metadata de la imagen"
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKERHUB_USERNAME }}/${{ github.event.repository.name }}
          tags: |
            type=sha,prefix=
            type=raw,value=latest

      - name: "🏗️ Construir y publicar imagen"
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ secrets.DOCKERHUB_USERNAME != '' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: "✅ Resumen"
        run: |
          echo "### 🐳 Docker Build Completado" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "**Imagen:** \`${{ steps.meta.outputs.tags }}\`" >> $GITHUB_STEP_SUMMARY
WORKFLOW_EOF

ok "Pipeline CI/CD creado en .github/workflows/ci-cd.yml"

# ═══════════════════════════════════════════════════════════════
# PASO 5: Inicializar Git y hacer primer commit
# ═══════════════════════════════════════════════════════════════
paso "5" "Configurando Git"

REMOTE_URL="https://github.com/${GITHUB_USER}/${PROJECT_NAME}.git"

if [ ! -d ".git" ]; then
    git init
    ok "Repositorio git inicializado"
else
    ok "Git ya inicializado"
fi

# Configurar remote
if git remote get-url origin &>/dev/null; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [ "$CURRENT_REMOTE" != "$REMOTE_URL" ]; then
        warn "Remote actual: $CURRENT_REMOTE"
        warn "Cambiando a: $REMOTE_URL"
        git remote set-url origin "$REMOTE_URL"
    fi
    ok "Remote origin: $REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
    ok "Remote origin añadido: $REMOTE_URL"
fi

# Asegurar rama main
git branch -M main 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════
# PASO 6: Primer commit y push
# ═══════════════════════════════════════════════════════════════
paso "6" "Primer commit y push"

# Verificar si hay commits
if git log --oneline -1 &>/dev/null; then
    info "Ya hay commits. Añadiendo cambios del CI/CD..."
    git add -A
    if git diff --cached --quiet; then
        info "No hay cambios nuevos que commitear"
    else
        git commit -m "feat: añadir CI/CD pipeline y configuración Docker

- GitHub Actions: build, test, docker build
- docker-compose.yml con variables de entorno (.env)
- application-docker.properties para perfil de producción
- Secretos externalizados (no más passwords en el código)"
        ok "Commit creado"
    fi
else
    git add -A
    git commit -m "feat: proyecto inicial con CI/CD completo

- Aplicación Spring Boot con API REST
- Docker multi-stage build
- docker-compose (PostgreSQL + Adminer)
- GitHub Actions CI/CD pipeline
- Secretos externalizados via .env"
    ok "Primer commit creado"
fi

# Push
info "Haciendo push a GitHub..."
if git push -u origin main 2>&1; then
    ok "Push completado"
else
    warn "Push falló. Si el repo tiene commits previos, intenta:"
    warn "  git pull origin main --rebase && git push -u origin main"
fi

# ═══════════════════════════════════════════════════════════════
# PASO 7: Configurar GitHub Secrets (opcional)
# ═══════════════════════════════════════════════════════════════
paso "7" "Configurar GitHub Secrets"

if [ -n "$DOCKERHUB_USER" ]; then
    info "Configurando secrets de Docker Hub en GitHub..."
    echo "$DOCKERHUB_USER" | gh secret set DOCKERHUB_USERNAME --repo "${GITHUB_USER}/${PROJECT_NAME}"
    ok "DOCKERHUB_USERNAME configurado"

    echo ""
    warn "Falta configurar DOCKERHUB_TOKEN manualmente:"
    info "  1. Ve a https://hub.docker.com/settings/security"
    info "  2. Crea un Access Token"
    info "  3. Ejecuta: gh secret set DOCKERHUB_TOKEN --repo ${GITHUB_USER}/${PROJECT_NAME}"
else
    warn "DOCKERHUB_USER no configurado. Docker Hub push desactivado."
    info "Cuando tengas cuenta, ejecuta:"
    info "  gh secret set DOCKERHUB_USERNAME --repo ${GITHUB_USER}/${PROJECT_NAME}"
    info "  gh secret set DOCKERHUB_TOKEN --repo ${GITHUB_USER}/${PROJECT_NAME}"
fi

# ═══════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                    🎉 ¡SETUP COMPLETADO!                    ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}  📁 Archivos creados/modificados:${NC}"
echo -e "     • .env                              (secretos locales)"
echo -e "     • docker-compose.yml                (servicios Docker)"
echo -e "     • application-docker.properties      (perfil producción)"
echo -e "     • .github/workflows/ci-cd.yml       (pipeline CI/CD)"
echo ""
echo -e "${CYAN}  🔗 Enlaces útiles:${NC}"
echo -e "     • Repo:     https://github.com/${GITHUB_USER}/${PROJECT_NAME}"
echo -e "     • Actions:  https://github.com/${GITHUB_USER}/${PROJECT_NAME}/actions"
echo -e "     • Adminer:  http://localhost:9090 (cuando Docker está corriendo)"
echo ""
echo -e "${CYAN}  🧪 Comandos útiles:${NC}"
echo -e "     • docker compose up -d        → Arrancar todo"
echo -e "     • docker compose logs -f app   → Ver logs"
echo -e "     • docker compose down -v       → Parar y limpiar"
echo -e "     • mvn clean verify             → Tests locales"
echo ""
echo -e "${YELLOW}  ⚠️  IMPORTANTE: No subas el archivo .env a git${NC}"
echo ""
