#!/bin/bash

# ============================================================================
# Script de Despliegue a GitHub - Sistema de Gestión Hotelera
# ============================================================================
# Este script automatiza el proceso de commit y push a GitHub
# con un mensaje descriptivo de todos los cambios realizados
# ============================================================================

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_step() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# ============================================================================
# PASO 1: Verificar que estamos en un repositorio Git
# ============================================================================
print_step "Verificando repositorio Git..."

if [ ! -d .git ]; then
    print_error "No estás en un repositorio Git. Inicializando..."
    git init
    git remote add origin https://github.com/SanTacrZ/hotel_MVC_ASP.NET.git
    print_success "Repositorio Git inicializado"
else
    print_success "Repositorio Git detectado"
fi

# ============================================================================
# PASO 2: Verificar remote
# ============================================================================
print_step "Verificando remote de GitHub..."

if ! git remote get-url origin &> /dev/null; then
    print_warning "No hay remote configurado. Agregando origin..."
    git remote add origin https://github.com/SanTacrZ/hotel_MVC_ASP.NET.git
    print_success "Remote 'origin' agregado"
else
    REMOTE_URL=$(git remote get-url origin)
    print_success "Remote configurado: $REMOTE_URL"
fi

# ============================================================================
# PASO 3: Mostrar estado actual
# ============================================================================
print_step "Estado actual del repositorio:"
echo ""
git status --short
echo ""

# Contar archivos modificados y nuevos
MODIFIED=$(git status --short | grep "^ M" | wc -l)
NEW=$(git status --short | grep "^??" | wc -l)
DELETED=$(git status --short | grep "^ D" | wc -l)

echo -e "${BLUE}Resumen:${NC}"
echo "  📝 Archivos modificados: $MODIFIED"
echo "  📄 Archivos nuevos: $NEW"
echo "  🗑️  Archivos eliminados: $DELETED"
echo ""

# ============================================================================
# PASO 4: Confirmar con el usuario
# ============================================================================
read -p "¿Deseas continuar con el commit y push? (s/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    print_warning "Operación cancelada por el usuario"
    exit 0
fi

# ============================================================================
# PASO 5: Agregar todos los cambios
# ============================================================================
print_step "Agregando todos los cambios al staging area..."

git add .

print_success "Todos los archivos agregados"

# ============================================================================
# PASO 6: Crear commit con mensaje descriptivo
# ============================================================================
print_step "Creando commit con mensaje descriptivo..."

COMMIT_MESSAGE="feat: Implementar mejoras completas del sistema hotelero

✨ Nuevas Características:
- Permitir reservas desde HOY con validación correcta de fechas
- Implementar minibar con AJAX sin recarga de página
- Agregar validación de cancelación 24 horas antes del check-in
- Crear archivo Huespedes.txt con 56 huéspedes de 15 nacionalidades
- Mejorar UI con mensajes de error visibles en pantalla

🔧 Mejoras Técnicas:
- Reemplazar Console.WriteLine con logging profesional (ILogger)
- Corregir validaciones de fecha en frontend y backend usando DateTime.Today
- Implementar endpoint AJAX para registro de consumos del minibar
- Mejorar manejo de excepciones con TempData

🐛 Correcciones:
- Resolver problema de zona horaria en selección de fechas
- Eliminar archivo 'nul' innecesario
- Normalizar fechas correctamente con .Date

📦 Archivos Agregados:
- Arhivos/Huespedes.txt (56 registros con diversas nacionalidades)

🔄 Archivos Modificados:
- Controllers: HabitacionController, RecepcionController, ReservaController
- Servicios: ReservaService
- Views: ReservarHabitacion, GestionarMinibar, Crear, Detalles, Index
- Program.cs

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git commit -m "$COMMIT_MESSAGE"

print_success "Commit creado exitosamente"

# Mostrar información del commit
echo ""
print_step "Información del commit:"
git log -1 --oneline
echo ""

# ============================================================================
# PASO 7: Push a GitHub
# ============================================================================
print_step "Subiendo cambios a GitHub..."

# Obtener la rama actual
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
    print_warning "No hay rama actual. Creando rama 'main'..."
    git checkout -b main
    CURRENT_BRANCH="main"
fi

print_step "Subiendo a la rama: $CURRENT_BRANCH"

# Intentar push
if git push origin "$CURRENT_BRANCH"; then
    print_success "¡Cambios subidos exitosamente a GitHub!"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ DEPLOY COMPLETADO EXITOSAMENTE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "🌐 Repositorio: $(git remote get-url origin)"
    echo "📝 Rama: $CURRENT_BRANCH"
    echo "🔗 Commit: $(git log -1 --oneline)"
    echo ""
else
    print_error "Error al hacer push. Posibles razones:"
    echo "  1. No tienes permisos en el repositorio"
    echo "  2. Necesitas autenticarte (usa Git Credential Manager)"
    echo "  3. Hay conflictos con el repositorio remoto"
    echo ""
    print_step "Intentando solución alternativa..."

    # Intentar pull primero si hay conflictos
    if git pull origin "$CURRENT_BRANCH" --rebase; then
        print_success "Rebase exitoso, intentando push nuevamente..."
        if git push origin "$CURRENT_BRANCH"; then
            print_success "¡Push exitoso después del rebase!"
        else
            print_error "Push falló. Revisa manualmente con: git status"
            exit 1
        fi
    else
        print_error "No se pudo hacer pull. Revisa conflictos manualmente."
        exit 1
    fi
fi

# ============================================================================
# PASO 8: Resumen final
# ============================================================================
echo ""
print_step "Resumen de archivos subidos:"
echo ""
git diff --stat HEAD~1 HEAD
echo ""

print_success "¡Proceso completado! Tu código está en GitHub 🚀"
