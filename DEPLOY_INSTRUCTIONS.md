# 🚀 Instrucciones de Despliegue a GitHub

Este proyecto incluye scripts automatizados para facilitar el despliegue a GitHub.

## 📋 Scripts Disponibles

### 1️⃣ **deploy-to-github.sh** (Para Git Bash / Linux / Mac)
Script bash con colores y validaciones completas.

### 2️⃣ **deploy-to-github.ps1** (Para Windows PowerShell)
Script PowerShell nativo de Windows con interfaz colorida.

---

## 🔧 Cómo Usar

### Opción A: Git Bash en Windows (Recomendado)

```bash
# Ejecutar el script
./deploy-to-github.sh
```

### Opción B: PowerShell en Windows

```powershell
# Si es la primera vez, habilitar ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar el script
.\deploy-to-github.ps1
```

### Opción C: Desde CMD (Windows)

```cmd
# Usar Git Bash
bash deploy-to-github.sh
```

---

## ✨ ¿Qué hace el script?

El script automatiza TODO el proceso de despliegue:

1. ✅ **Verifica** que estás en un repositorio Git
2. ✅ **Confirma** que el remote está configurado
3. ✅ **Muestra** el estado actual y cuenta de archivos
4. ✅ **Solicita confirmación** antes de proceder
5. ✅ **Agrega** todos los cambios (`git add .`)
6. ✅ **Crea commit** con mensaje descriptivo profesional
7. ✅ **Sube** los cambios a GitHub (`git push`)
8. ✅ **Maneja errores** automáticamente (rebase si es necesario)
9. ✅ **Muestra resumen** de lo que se subió

---

## 📝 Mensaje de Commit Incluido

El script crea automáticamente un commit con este formato:

```
feat: Implementar mejoras completas del sistema hotelero

✨ Nuevas Características:
- Permitir reservas desde HOY con validación correcta de fechas
- Implementar minibar con AJAX sin recarga de página
- Agregar validación de cancelación 24 horas antes del check-in
- Crear archivo Huespedes.txt con 56 huéspedes de 15 nacionalidades
- Mejorar UI con mensajes de error visibles en pantalla

🔧 Mejoras Técnicas:
- Reemplazar Console.WriteLine con logging profesional (ILogger)
- Corregir validaciones de fecha en frontend y backend
- Implementar endpoint AJAX para registro de consumos del minibar

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 🔐 Autenticación

Si es la primera vez que haces push, Git te pedirá autenticación:

### Windows:
1. Se abrirá una ventana de **Git Credential Manager**
2. Selecciona **"Sign in with your browser"**
3. Autoriza en GitHub
4. ¡Listo! Las credenciales se guardarán automáticamente

### Linux/Mac:
```bash
# Configurar credenciales (una sola vez)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Usar token de acceso personal
# Ve a GitHub → Settings → Developer settings → Personal access tokens
```

---

## 🐛 Solución de Problemas

### Error: "Permission denied"
```bash
# Dar permisos de ejecución
chmod +x deploy-to-github.sh
```

### Error: "cannot be loaded because running scripts is disabled"
```powershell
# Habilitar scripts en PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "failed to push some refs"
El script intentará hacer `pull --rebase` automáticamente. Si falla:
```bash
# Resolver manualmente
git pull origin main --rebase
git push origin main
```

---

## 📊 Archivos que se Subirán

### Modificados (11):
- `Controllers/HabitacionController.cs`
- `Controllers/RecepcionController.cs`
- `Controllers/ReservaController.cs`
- `Views/Habitacion/ReservarHabitacion.cshtml`
- `Views/Recepcion/GestionarMinibar.cshtml`
- `Views/Reserva/Crear.cshtml`
- `Views/Reserva/Detalles.cshtml`
- `Views/Reserva/Index.cshtml`
- `Servicios/ReservaService.cs`
- `Program.cs`
- `hotel_web_final.csproj`

### Nuevos (3):
- `Arhivos/Huespedes.txt` (56 huéspedes)
- `deploy-to-github.sh` (este script)
- `deploy-to-github.ps1` (versión PowerShell)

---

## 🎯 Resultado Esperado

```
✓ DEPLOY COMPLETADO EXITOSAMENTE
═══════════════════════════════════════════════════════

🌐 Repositorio: https://github.com/SanTacrZ/hotel_MVC_ASP.NET.git
📝 Rama: main
🔗 Commit: abc1234 feat: Implementar mejoras completas del sistema hotelero

¡Proceso completado! Tu código está en GitHub 🚀
```

---

## 🔄 Uso Futuro

Para futuros cambios, simplemente ejecuta el script de nuevo:

```bash
# Hacer cambios en tu código...
# Luego ejecutar:
./deploy-to-github.sh

# El script te mostrará qué cambios hay y te pedirá confirmación
```

---

## 💡 Comandos Manuales (Alternativa)

Si prefieres hacerlo manualmente:

```bash
# Ver cambios
git status

# Agregar todo
git add .

# Commit
git commit -m "Tu mensaje aquí"

# Push
git push origin main
```

---

## 📞 Soporte

Si tienes problemas:
1. Revisa que Git esté instalado: `git --version`
2. Verifica tu conexión a internet
3. Confirma que tienes permisos en el repositorio
4. Revisa el archivo de log si el script falla

---

**Creado con ❤️ por Claude Code**
