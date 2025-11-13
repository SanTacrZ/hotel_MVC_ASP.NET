# ============================================================================
# Script de Despliegue a GitHub - Sistema de Gestión Hotelera (PowerShell)
# ============================================================================
# Este script automatiza el proceso de commit y push a GitHub
# con un mensaje descriptivo de todos los cambios realizados
# ============================================================================

# Configuración
$ErrorActionPreference = "Stop"

# Colores
function Write-Step {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] " -NoNewline -ForegroundColor Blue
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -NoNewline -ForegroundColor Green
    Write-Host $Message
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ " -NoNewline -ForegroundColor Yellow
    Write-Host $Message
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ " -NoNewline -ForegroundColor Red
    Write-Host $Message
}

# ============================================================================
# PASO 1: Verificar que estamos en un repositorio Git
# ============================================================================
Write-Step "Verificando repositorio Git..."

if (-not (Test-Path .git)) {
    Write-Error-Custom "No estás en un repositorio Git. Inicializando..."
    git init
    git remote add origin https://github.com/SanTacrZ/hotel_MVC_ASP.NET.git
    Write-Success "Repositorio Git inicializado"
} else {
    Write-Success "Repositorio Git detectado"
}

# ============================================================================
# PASO 2: Verificar remote
# ============================================================================
Write-Step "Verificando remote de GitHub..."

try {
    $remoteUrl = git remote get-url origin 2>$null
    Write-Success "Remote configurado: $remoteUrl"
} catch {
    Write-Warning-Custom "No hay remote configurado. Agregando origin..."
    git remote add origin https://github.com/SanTacrZ/hotel_MVC_ASP.NET.git
    Write-Success "Remote 'origin' agregado"
}

# ============================================================================
# PASO 3: Mostrar estado actual
# ============================================================================
Write-Step "Estado actual del repositorio:"
Write-Host ""
git status --short
Write-Host ""

# Contar archivos
$statusOutput = git status --short
$modified = ($statusOutput | Select-String "^ M").Count
$new = ($statusOutput | Select-String "^\?\?").Count
$deleted = ($statusOutput | Select-String "^ D").Count

Write-Host "Resumen:" -ForegroundColor Blue
Write-Host "  📝 Archivos modificados: $modified"
Write-Host "  📄 Archivos nuevos: $new"
Write-Host "  🗑️  Archivos eliminados: $deleted"
Write-Host ""

# ============================================================================
# PASO 4: Confirmar con el usuario
# ============================================================================
$response = Read-Host "¿Deseas continuar con el commit y push? (s/n)"

if ($response -notmatch '^[SsYy]$') {
    Write-Warning-Custom "Operación cancelada por el usuario"
    exit 0
}

# ============================================================================
# PASO 5: Agregar todos los cambios
# ============================================================================
Write-Step "Agregando todos los cambios al staging area..."

git add .

Write-Success "Todos los archivos agregados"

# ============================================================================
# PASO 6: Crear commit con mensaje descriptivo
# ============================================================================
Write-Step "Creando commit con mensaje descriptivo..."

$commitMessage = @"
feat: Implementar mejoras completas del sistema hotelero

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

Co-Authored-By: Claude <noreply@anthropic.com>
"@

git commit -m $commitMessage

Write-Success "Commit creado exitosamente"

# Mostrar información del commit
Write-Host ""
Write-Step "Información del commit:"
git log -1 --oneline
Write-Host ""

# ============================================================================
# PASO 7: Push a GitHub
# ============================================================================
Write-Step "Subiendo cambios a GitHub..."

# Obtener la rama actual
$currentBranch = git branch --show-current

if ([string]::IsNullOrEmpty($currentBranch)) {
    Write-Warning-Custom "No hay rama actual. Creando rama 'main'..."
    git checkout -b main
    $currentBranch = "main"
}

Write-Step "Subiendo a la rama: $currentBranch"

# Intentar push
try {
    git push origin $currentBranch
    Write-Success "¡Cambios subidos exitosamente a GitHub!"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "✓ DEPLOY COMPLETADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Repositorio: $(git remote get-url origin)"
    Write-Host "📝 Rama: $currentBranch"
    Write-Host "🔗 Commit: $(git log -1 --oneline)"
    Write-Host ""
} catch {
    Write-Error-Custom "Error al hacer push. Posibles razones:"
    Write-Host "  1. No tienes permisos en el repositorio"
    Write-Host "  2. Necesitas autenticarte (usa Git Credential Manager)"
    Write-Host "  3. Hay conflictos con el repositorio remoto"
    Write-Host ""
    Write-Step "Intentando solución alternativa..."

    # Intentar pull primero si hay conflictos
    try {
        git pull origin $currentBranch --rebase
        Write-Success "Rebase exitoso, intentando push nuevamente..."
        git push origin $currentBranch
        Write-Success "¡Push exitoso después del rebase!"
    } catch {
        Write-Error-Custom "No se pudo hacer pull. Revisa conflictos manualmente."
        exit 1
    }
}

# ============================================================================
# PASO 8: Resumen final
# ============================================================================
Write-Host ""
Write-Step "Resumen de archivos subidos:"
Write-Host ""
git diff --stat HEAD~1 HEAD
Write-Host ""

Write-Success "¡Proceso completado! Tu código está en GitHub 🚀"

# Pausa para que el usuario pueda ver el resultado
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
