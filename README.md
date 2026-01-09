# Grape Software - Public Repository

Este repositorio contiene plantillas, instrucciones y archivos de configuración estándar para inicializar proyectos de microfrontends y microservicios en Grape Software.

## 📁 Estructura del Repositorio

### Angular (Microfrontends)
Archivos y configuraciones para inicializar microfrontends con Angular y Native Federation:

- **`angular-init.md`**: Instrucciones paso a paso para crear e inicializar un nuevo proyecto de microfrontend Angular
- **`gr-common.zip`**: Archivo comprimido con componentes y servicios comunes (shared) que se deben copiar a `src/app` en cada microfrontend
- **`instructions/angular.md`**: Guías y mejores prácticas para desarrollo con Angular
- **`prompts/builds.md`**: Prompts y configuraciones para builds y despliegues

### NetCore (Microservicios)
Archivos y configuraciones para inicializar microservicios con .NET Core:

- **`microservice-netcore-init.md`**: Instrucciones para crear e inicializar un nuevo microservicio .NET Core
- **`microservice-netcore-artifacts.md`**: Artefactos y configuraciones necesarias para microservicios

## 🚀 Uso

### Para inicializar un nuevo microfrontend Angular:

1. Descargar `angular-init.md` y `gr-common.zip` de este repositorio
2. Seguir las instrucciones en `angular-init.md`
3. Extraer el contenido de `gr-common.zip` en la carpeta `src/app` del proyecto
4. Consultar `instructions/angular.md` para guías adicionales de desarrollo

### Para inicializar un nuevo microservicio .NET Core:

1. Descargar los archivos `.md` de la carpeta `netcore`
2. Seguir las instrucciones en `microservice-netcore-init.md`
3. Consultar `microservice-netcore-artifacts.md` para configuraciones adicionales

## 📦 Archivos Clave

| Archivo | Descripción |
|---------|-------------|
| `angular/gr-common.zip` | Componentes compartidos para microfrontends Angular |
| `angular/angular-init.md` | Guía de inicialización de microfrontends |
| `netcore/microservice-netcore-init.md` | Guía de inicialización de microservicios |

## 🔗 Automatización

Este repositorio está diseñado para ser referenciado por prompts y scripts de automatización que:
- Descargan automáticamente los archivos necesarios desde `grape-software/public`
- Inicializan nuevos repositorios con las configuraciones estándar
- Aplican las mejores prácticas de desarrollo de Grape Software

## 📝 Notas

- Todos los archivos están versionados y se mantienen actualizados con las últimas configuraciones estándar
- Se recomienda revisar este repositorio periódicamente para obtener actualizaciones
- Para sugerencias o mejoras, contactar al equipo de arquitectura