# Instrucciones para agregar workflows automáticos a nuevos proyectos .NET y Angular

## Proyectos .NET

1. Genera el proyecto siguiendo las instrucciones estándar de public/init-repos/microservice-netcore-init.md.
2. Ejecuta:

```bash
bash /ruta/a/public/init-repos/add_project_workflow.sh /ruta/al/nuevo/proyecto dotnet
```

Esto creará `.github/workflows/agnostic_workflow.yml` y, si existe, copiará el Dockerfile estándar para .NET 9.

## Proyectos Angular

1. Genera el proyecto siguiendo las instrucciones estándar de public/init-repos/angular-init.md.
2. Ejecuta:

```bash
bash /ruta/a/public/init-repos/add_project_workflow.sh /ruta/al/nuevo/proyecto angular
```

Esto creará `.github/workflows/dev_web_Server.yml` automáticamente en el nuevo proyecto Angular.

---

Puedes integrar este paso en cualquier script de inicialización o pipeline de generación de proyectos para que sea completamente automático.

### PENDIENTE para la inicializacion. 01/03/2026

00. crear secrets

0. crear  un nuevo nombbre de dominio 
    a. mi dominio.sandbox.ar en DIGITAL OCEAN
    b. crear una config de nginx basica
    c. solicitar certificado SSL (certbot)

1. actualizar el repositorio INFRA_SANDBOX   ---->> debemos saber en qué proyectos debe agregarse  
    a. creando una config de nginx nueva
    b. creando config de docker
    c. creando .env nuevo
        I. crearle acceso a base de datos.

2. restaria sumarlo al monitoreo en kuma