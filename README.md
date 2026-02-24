# Grape Software - Public Repository

Este repositorio contiene plantillas, instrucciones y archivos de configuración estándar para inicializar proyectos de microfrontends y microservicios en Grape Software.

## Prompt para inicializar un nuevo microfrontend Angular en Github:

Se va a inicializar el proyecto con el nombre del repositorio. Buscar el detalle de las acciones a ejecutar en la web https://github.com/grape-software/docs/blob/main/docs/agents/init-repos/angular-init.md en el punto 3 el archivo gr-common-angular.zip se encuentra en https://github.com/grape-software/docs/blob/main/docs/agents/init-repos/gr-common-angular.zip
Con estas instrucciones puedes construir el microfrontend con las configuraciones estándar de Grape Software, incluyendo la estructura del proyecto, dependencias, y componentes compartidos.

## 📁 Estructura del Repositorio

### 📂 init-repos/
Archivos para inicializar nuevos repositorios:

- **`angular-init.md`**: Instrucciones paso a paso para crear e inicializar un nuevo proyecto de microfrontend Angular
- **`gr-common-angular.zip`**: Archivo comprimido con componentes y servicios comunes (shared) que se deben copiar a `src/app` en cada microfrontend
- **`microservice-netcore-init.md`**: Instrucciones para crear e inicializar un nuevo microservicio .NET Core

### 📂 instructions/
Guías y mejores prácticas para desarrollo:

- **`angular.md`**: Guías y mejores prácticas para desarrollo con Angular
- **`net.md`**: Guías y mejores prácticas para desarrollo con .NET Core

### 📂 prompts/
Prompts y configuraciones especializadas:

- **`migrations.md`**: Prompts para migraciones y actualizaciones
- **`new-layout.md`**: Prompts para nuevos layouts y estructuras

## 🚀 Uso

### Para inicializar un nuevo microfrontend Angular:

1. Descargar `init-repos/angular-init.md` y `init-repos/gr-common-angular.zip` de este repositorio
2. Seguir las instrucciones en `angular-init.md`
3. Extraer el contenido de `gr-common-angular.zip` en la carpeta `src/app` del proyecto
4. Consultar `instructions/angular.md` para guías adicionales de desarrollo

### Para inicializar un nuevo microservicio .NET Core:

1. Descargar `init-repos/microservice-netcore-init.md` de este repositorio
2. Seguir las instrucciones en el archivo
3. Consultar `instructions/net.md` para guías adicionales de desarrollo

## 📦 Archivos Clave

| Archivo | Descripción |
|---------|-------------|
| `init-repos/gr-common-angular.zip` | Componentes compartidos para microfrontends Angular |
| `init-repos/angular-init.md` | Guía de inicialización de microfrontends |
| `init-repos/microservice-netcore-init.md` | Guía de inicialización de microservicios |
| `instructions/angular.md` | Mejores prácticas para Angular |
| `instructions/net.md` | Mejores prácticas para .NET Core |
| `prompts/migrations.md` | Prompts para migraciones |
| `prompts/new-layout.md` | Prompts para nuevos layouts |

## 🔗 Automatización

Este repositorio está diseñado para ser referenciado por prompts y scripts de automatización que:
- Descargan automáticamente los archivos necesarios desde `grape-software/public`
- Inicializan nuevos repositorios con las configuraciones estándar
- Aplican las mejores prácticas de desarrollo de Grape Software

## 📝 Notas

- Todos los archivos están versionados y se mantienen actualizados con las últimas configuraciones estándar
- Se recomienda revisar este repositorio periódicamente para obtener actualizaciones
- Para sugerencias o mejoras, contactar al equipo de arquitectura