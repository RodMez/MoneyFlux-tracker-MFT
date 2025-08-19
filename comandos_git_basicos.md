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

---

# Uso de GitHub CLI (`gh`) para conectar y subir un proyecto local

## Requisitos previos

- Tener instalado Git en tu equipo.
- Tener una cuenta en [GitHub](https://github.com).
- Tener instalado GitHub CLI (`gh`).
- Tener un proyecto local ya inicializado con Git y con commits realizados.

---

## 1. Instalar GitHub CLI

```bash
choco install gh
```

Verifica la instalación:

```bash
gh --version
```

---

## 2. Iniciar sesión en GitHub desde la terminal

Ejecuta:

```bash
gh auth login
```

Verifica el estado de autenticación:

```bash
gh auth status
```

---

## 3. Crear un repositorio en GitHub desde la terminal

Desde la carpeta raíz de tu proyecto, ejecuta:

```bash
gh repo create

---

## 4. Verificar que todo esté correctamente enlazado

Verifica que el repositorio remoto esté configurado:

```bash
git remote -v
```

Para abrir tu repositorio en el navegador:

```bash
gh repo view --web
```

---


### 1. Ramas (branches)

Las ramas te permiten trabajar en nuevas funcionalidades o correcciones sin afectar la versión principal del proyecto. Así puedes experimentar y luego unir los cambios cuando estén listos.

#### **Comandos útiles:**

- **Crear una nueva rama:**
  ```sh
  git branch nombre-rama
  ```
  Crea una rama llamada `nombre-rama`.

- **Cambiar a una rama existente:**
  ```sh
  git checkout nombre-rama
  ```
  Cambia tu área de trabajo a la rama seleccionada.

- **Crear y cambiar a una nueva rama (en un solo paso):**
  ```sh
  git checkout -b nombre-rama
  ```
  Muy útil para empezar a trabajar en una nueva funcionalidad.

- **Unir una rama a la rama actual:**
  ```sh
  git merge nombre-rama
  ```
  Aplica los cambios de `nombre-rama` a la rama en la que estás.

- **Cambiar de rama (comando moderno):**
  ```sh
  git switch nombre-rama
  ```
  Alternativa moderna a `git checkout`.

#### **Consejo:**  
Trabaja siempre en ramas para mantener tu rama principal (`master` o `main`) estable.

---

### 2. Repositorios remotos (GitHub)

Un repositorio remoto es una copia de tu proyecto en la nube (por ejemplo, en GitHub). Sirve para respaldar tu trabajo, colaborar y compartir tu código.

#### **Comandos útiles:**

- **Conectar tu repositorio local con uno remoto:**
  ```sh
  git remote add origin URL
  ```
  (Reemplaza `URL` por la dirección de tu repositorio en GitHub).

- **Subir tus cambios al repositorio remoto:**
  ```sh
  git push -u origin master
  ```
  Sube la rama `master` a GitHub. La primera vez usa `-u` para establecer el seguimiento.

- **Bajar los cambios del repositorio remoto:**
  ```sh
  git pull origin master
  ```
  Descarga y aplica los cambios de la rama `master` de GitHub a tu proyecto local.

#### **Consejo:**  
Haz push frecuentemente para no perder tu trabajo y facilitar la colaboración.

---

### 3. Resolución de conflictos

Cuando dos personas (o ramas) modifican la misma parte de un archivo, Git genera un conflicto que debes resolver manualmente.

#### **¿Cómo resolver un conflicto?**

1. Git marcará el archivo en conflicto con símbolos especiales (`<<<<<<<`, `=======`, `>>>>>>>`).
2. Abre el archivo, revisa y edita el contenido para dejar solo la versión correcta.
3. Una vez resuelto, agrega el archivo y haz un commit:
   ```sh
   git add archivo_en_conflicto
   git commit -m "Resuelto conflicto en archivo_en_conflicto"
   ```
---

### 4. Buenas prácticas

- Escribe mensajes de commit claros y descriptivos.
- Haz commits pequeños y frecuentes.
- Usa `.gitignore` para excluir archivos temporales o personales.
- Sincroniza tu rama con frecuencia (`git pull`) para evitar conflictos grandes.
- Borra ramas que ya no uses para mantener el repositorio limpio.

## Recursos útiles

- [Documentación oficial de GitHub CLI](https://cli.github.com/manual/)
- [Documentación oficial de Git](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com/es)
---