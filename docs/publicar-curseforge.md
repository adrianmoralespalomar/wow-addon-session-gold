# Publicar en CurseForge

Cuenta de autor: **seulgimomo** (https://www.curseforge.com/members/seulgimomo). Los proyectos se crean en https://authors.curseforge.com.

## Antes de publicar

1. El add-on probado en el juego, incluido lo que vigila de verdad (no solo `/sgold test`).
2. `.toc` con `## Author: seulgimomo`, la versión y las notas en inglés y español.
3. `LICENSE` (MIT a nombre de `seulgimomo`) y `README.md` en inglés: qué hace, uso, comandos y opciones.
4. Logo propio en `assets/logo.svg`, pasado a PNG con `npm run logo` (512×512; CurseForge pide al menos 400×400). Normas: original, sin el logo del juego ni de otro proyecto, no puede ser un cuadrado de un solo color. Fondo sin transparencia (CurseForge también tiene tema claro).
5. `npm run package` → `dist/SessionGold-<versión>.zip`, con la carpeta del add-on en la raíz. Las rutas internas deben usar `/`: `Compress-Archive` de Windows PowerShell pone `\` y otros programas las leen mal; por eso `tools/package-addon.ps1` crea el `.zip` con `System.IO.Compression` a mano.
6. Commit con la versión publicada.

## Crear el proyecto

- Nombre igual que el `## Title` del `.toc`; el resumen, la descripción y el resto de campos están listos para pegar en `docs/curseforge-info.md`.
- Categoría adecuada, licencia MIT y el logo (`assets/logo.png`).
- Subir el `.zip` como *Release* y elegir la versión del juego **WoW Forever**. Sin un fichero subido el proyecto no entra en la cola de revisión.
- La revisión de CurseForge tarda de minutos a un par de días. Hasta que se aprueba un fichero *Release* o *Beta*, el proyecto no aparece en la app.

## Normas

- CurseForge (https://support.curseforge.com/support/solutions/articles/9000197279): contenido y logo propios (nombre, resumen y descripción incluidos), nada de clonar proyectos de otros, cumplir los términos del juego.
- Blizzard (https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534): gratis, código visible sin ofuscar, sin anuncios ni peticiones de donativos dentro del juego, sin perjudicar el rendimiento ni a otros jugadores, sin contenido ofensivo. El add-on solo avisa: nunca actúa por el jugador.

## Versiones nuevas

- Subir `## Version` en el `.toc` (semántica: corrección → parche, función nueva → menor), `npm run package` y subir el nuevo `.zip` en la pestaña *Files* del proyecto con una nota de cambios.
- Pendiente de montar: publicar desde GitHub de forma automática con el empaquetador de BigWigs y GitHub Actions (https://warcraft.wiki.gg/wiki/Using_the_BigWigs_Packager_with_GitHub_Actions). Como el add-on está en una subcarpeta del repositorio, el `.pkgmeta` necesita indicarlo (`package-as` y `move-folders`). Hace falta una clave de la API de CurseForge guardada como secreto en GitHub y el ID del proyecto (`## X-Curse-Project-ID` en el `.toc`).
