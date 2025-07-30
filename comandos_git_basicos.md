# Comandos básicos de Git para MFT

## Inicializar repositorio
```sh
git init
```
Crea un nuevo repositorio Git en la carpeta actual.

## Ver el estado de los archivos
```sh
git status
```
Muestra los archivos nuevos, modificados o listos para guardar (commit).

## Agregar archivos al área de preparación
```sh
git add README.md
```
Prepara el archivo README.md para ser guardado en el historial. Puedes usar `git add .` para agregar todos los archivos.

## Configurar nombre y correo (solo la primera vez)
```sh
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```
Configura tu identidad para que Git registre quién hace los cambios.

## Guardar los cambios (commit)
```sh
git commit -m "Mensaje descriptivo"
```
Guarda los cambios preparados con un mensaje que explique qué hiciste.

## Ver el historial de cambios
```sh
git log
```
Muestra la lista de todos los commits realizados en el proyecto. 