---
name: software-architect
description: >
  Use when asked to create architecture documentation, DrawIO diagrams, deployment diagrams,
  CI/CD pipelines, or system design descriptions for Grape Software projects.
  Triggers: "create architecture doc", "documenta la arquitectura", "crea un diagrama drawio",
  "document microservice", "ci/cd pipeline", "deployment diagram", "architecture diagram",
  "system design", "documenta el sistema", "crea documentación de arquitectura",
  "diagrama de despliegue", "diagrama de componentes", "diagrama de secuencia".
  Stack: .NET microservices, Angular micro-frontends with Native Federation, SQL Server/PostgreSQL, GitHub Actions, Docker.
---

# Software Architect — Grape Software

Guía de referencia para crear documentación de arquitectura, diagramas DrawIO y pipelines CI/CD para proyectos de Grape Software.

---

## Stack de Referencia

| Capa | Tecnología |
|------|-----------|
| Backend | .NET 10, ASP.NET Core Web API |
| Frontend | Angular 21+, Native Federation (micro-frontends) |
| Base de datos | SQL Server o PostgreSQL (env `UsePostgreSQL=true` para PG) |
| Autenticación | JWT Bearer + API Key (`Grape.Core` package) |
| Logging | Serilog → SQL Server o PostgreSQL |
| Contenedor | Docker + Nginx |
| CI/CD | GitHub Actions (auto-deploy en push a `main`) |
| NuGet privado | `nuget.pkg.github.com/grape-software` |

**Convención de nombres de repositorios:**
- `ms-{dominio}` → microservicio (e.g. `ms-colegios`)
- `mf-{dominio}` → microfrontend (e.g. `mf-colegios`)
- Organización: `grape-software` o `neox-software`

---

## Estructura de un Microservicio

```
{repo}/
  lib/           ← Modelos EF Core (entidades)
  services/      ← ASP.NET Core Web API
  tests/         ← Tests xUnit
  docs/          ← Documentación del microservicio
  .rests/        ← Archivos .http para testing manual
  .sql/          ← Scripts DDL/DML de migración
  Dockerfile
  NuGet.Config
```

**Componentes clave:**
- `BaseApiController` — hereda `[Authorize]`, provee `JWTUser`, `HandleException()`, `ModelErrors()`
- `AppDBContext` — DbContext EF Core con `SystemsParameters`, `SystemsIntegrations`, `Tenants`
- `SearchModel` — modelo de paginación/filtrado para todos los endpoints GET lista
- `ApiLogMiddleware` — loguea request/response bodies vía Serilog
- `StatusController` — health check en `/status`

---

## Estructura de Angular Micro-frontends

```
layout-repo/   ← Shell (punto de entrada, carga microfronts desde DB)
core-repo/     ← Auth compartida, rutas de configuración
mf-{dominio}/  ← Microfront de negocio
```

**Patrón Native Federation:**
- Layout inicializa con `initFederation()` en `main.ts`
- Cada microfront expone rutas en `federation.config.js`:
  ```js
  exposes: { './BusinessRoutes': './src/app/business/business.routes.ts' }
  ```
- Nginx sirve cada microfront bajo un path distinto: `/layout/`, `/core/`, `/mf-name/`
- `publicPath` en webpack config debe coincidir con el location block de nginx

---

## Qué Crear para Cada Pedido

| El usuario pide | Qué producir |
|----------------|-------------|
| "Diagrama de arquitectura" | Archivo `.drawio` con template de Sistema |
| "Diagrama de despliegue" o "CI/CD" | Archivo `.drawio` con template de Despliegue |
| "Documento de arquitectura" | Markdown con el template de Documento |
| "Pipeline CI/CD para ms-{x}" | YAML de GitHub Actions (ver sección CI/CD) |
| "Documentar microservicio {x}" | Doc de arquitectura + DrawIO de componentes |
| "Diagrama de secuencia" | DrawIO con template de secuencia |

---

## Template: Documento de Arquitectura (Markdown)

```markdown
# Arquitectura: {Nombre del Proyecto}

## Resumen
Breve descripción del propósito del sistema y los módulos involucrados.

## Stack Tecnológico
| Componente | Tecnología |
|-----------|-----------|
| Backend | .NET 10 Web API |
| Frontend | Angular {versión} + Native Federation |
| Base de datos | SQL Server / PostgreSQL |
| Autenticación | JWT Bearer (Grape.Core) |
| Contenedor | Docker + Nginx |
| CI/CD | GitHub Actions |

## Microservicios
| Repositorio | Dominio | Puerto |
|------------|---------|--------|
| ms-{dominio} | Descripción | {puerto} |

## Micro-frontends
| Repositorio | Ruta Nginx | Descripción |
|------------|-----------|-------------|
| mf-{dominio} | /{path}/ | Descripción |

## Flujo de Autenticación
1. Login en Core (`/auth/login`) con identifier + password + tenantId
2. Core devuelve JWT token
3. Angular envía token en header `Authorization: Bearer {token}`
4. Cada microservicio valida JWT con el secreto compartido (`JwtSecret`)

## Integración entre Microservicios
Describir comunicación HTTP entre servicios usando el patrón `CoreService` (HttpClient + bearer token).

## Base de Datos
- Tablas base de `grape-software/core`: SystemParameters, SystemIntegrations, Tenants
- Scripts de migración en `.sql/` de cada repositorio

## Variables de Entorno Requeridas
| Variable | Descripción | Requerida |
|----------|-------------|-----------|
| `ConnectionStrings__Default` | Connection string DB | Sí |
| `JwtSecret` | Secreto JWT (alternativa a DB) | No |
| `UsePostgreSQL` | `"true"` para PostgreSQL | No |

## CI/CD
Push a `main` → GitHub Actions → Docker build → push registry → SSH deploy.
Ver `.github/workflows/deploy.yml` en cada repositorio.
```

---

## Template: GitHub Actions CI/CD

Crear en `.github/workflows/deploy.yml` de cada repositorio:

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: |
          docker build -t ${{ secrets.REGISTRY }}/${{ github.event.repository.name }}:latest .

      - name: Push to registry
        run: |
          echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login ${{ secrets.REGISTRY }} \
            -u ${{ secrets.REGISTRY_USER }} --password-stdin
          docker push ${{ secrets.REGISTRY }}/${{ github.event.repository.name }}:latest

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            docker pull ${{ secrets.REGISTRY }}/${{ github.event.repository.name }}:latest
            docker stop ${{ github.event.repository.name }} || true
            docker rm ${{ github.event.repository.name }} || true
            docker run -d --name ${{ github.event.repository.name }} \
              --restart unless-stopped \
              -p ${{ secrets.PORT }}:8080 \
              -e ConnectionStrings__Default="${{ secrets.DB_CONNECTION }}" \
              -e JwtSecret="${{ secrets.JWT_SECRET }}" \
              -e UsePostgreSQL="${{ secrets.USE_POSTGRESQL }}" \
              ${{ secrets.REGISTRY }}/${{ github.event.repository.name }}:latest
```

**Secrets requeridos en el repositorio GitHub:**
`REGISTRY`, `REGISTRY_USER`, `REGISTRY_PASSWORD`, `SERVER_HOST`, `SERVER_USER`, `SSH_KEY`, `PORT`, `DB_CONNECTION`, `JWT_SECRET`

---

## Template DrawIO: Diagrama de Arquitectura del Sistema

Guardar como `{proyecto}-arquitectura.drawio`:

```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />

    <!-- CAPA FRONTEND -->
    <mxCell id="10" value="Frontend (Angular + Native Federation)" style="swimlane;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="20" y="20" width="360" height="180" as="geometry" />
    </mxCell>
    <mxCell id="11" value="Layout Shell" style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="10">
      <mxGeometry x="20" y="40" width="140" height="50" as="geometry" />
    </mxCell>
    <mxCell id="12" value="MF — Core&#xa;(Auth, Config)" style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="10">
      <mxGeometry x="20" y="110" width="120" height="50" as="geometry" />
    </mxCell>
    <mxCell id="13" value="MF — {Dominio}" style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="10">
      <mxGeometry x="200" y="110" width="120" height="50" as="geometry" />
    </mxCell>

    <!-- NGINX -->
    <mxCell id="20" value="Nginx&#xa;(reverse proxy)" style="rounded=1;fillColor=#f5f5f5;strokeColor=#666666;fontColor=#333333;" vertex="1" parent="1">
      <mxGeometry x="450" y="85" width="120" height="50" as="geometry" />
    </mxCell>

    <!-- CAPA BACKEND -->
    <mxCell id="30" value="Backend (.NET 10)" style="swimlane;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="650" y="20" width="360" height="180" as="geometry" />
    </mxCell>
    <mxCell id="31" value="ms-core&#xa;Auth, Users, Tenants" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="30">
      <mxGeometry x="20" y="40" width="140" height="50" as="geometry" />
    </mxCell>
    <mxCell id="32" value="ms-{dominio}&#xa;Lógica de negocio" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="30">
      <mxGeometry x="200" y="40" width="140" height="50" as="geometry" />
    </mxCell>
    <mxCell id="33" value="Grape.Core (NuGet)&#xa;Base controllers, JWT, EF entities" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="30">
      <mxGeometry x="20" y="120" width="320" height="40" as="geometry" />
    </mxCell>

    <!-- CAPA BASE DE DATOS -->
    <mxCell id="40" value="Base de Datos" style="swimlane;fillColor=#ffe6cc;strokeColor=#d6b656;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="650" y="240" width="360" height="100" as="geometry" />
    </mxCell>
    <mxCell id="41" value="SQL Server / PostgreSQL&#xa;(switchable vía env UsePostgreSQL)" style="shape=mxgraph.flowchart.database;fillColor=#ffe6cc;strokeColor=#d6b656;" vertex="1" parent="40">
      <mxGeometry x="110" y="15" width="140" height="70" as="geometry" />
    </mxCell>

    <!-- CONEXIONES -->
    <mxCell id="50" edge="1" source="10" target="20" value="HTTP" parent="1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="51" edge="1" source="20" target="30" value="proxy /api/*" parent="1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="52" edge="1" source="30" target="40" value="EF Core" parent="1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

---

## Template DrawIO: Diagrama de Despliegue / CI/CD

Guardar como `{proyecto}-deploy.drawio`:

```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" page="1" pageWidth="1169" pageHeight="827">
  <root>
    <mxCell id="0" /><mxCell id="1" parent="0" />

    <mxCell id="10" value="Developer" style="shape=mxgraph.flowchart.start_2;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="60" y="180" width="60" height="60" as="geometry" />
    </mxCell>

    <mxCell id="20" value="GitHub&#xa;(push to main)" style="rounded=1;fillColor=#f5f5f5;strokeColor=#666666;" vertex="1" parent="1">
      <mxGeometry x="200" y="180" width="130" height="60" as="geometry" />
    </mxCell>

    <mxCell id="30" value="GitHub Actions&#xa;dotnet build / ng build&#xa;docker build + push" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="410" y="170" width="160" height="80" as="geometry" />
    </mxCell>

    <mxCell id="40" value="Docker Registry" style="shape=mxgraph.flowchart.database;fillColor=#ffe6cc;strokeColor=#d6b656;" vertex="1" parent="1">
      <mxGeometry x="650" y="160" width="100" height="80" as="geometry" />
    </mxCell>

    <mxCell id="50" value="Production Server&#xa;Docker run&#xa;(SSH deploy)" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="650" y="320" width="160" height="70" as="geometry" />
    </mxCell>

    <mxCell id="60" value="Nginx&#xa;+ Containers" style="rounded=1;fillColor=#f5f5f5;strokeColor=#666666;" vertex="1" parent="1">
      <mxGeometry x="890" y="310" width="130" height="70" as="geometry" />
    </mxCell>

    <mxCell id="70" edge="1" source="10" target="20" value="git push" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
    <mxCell id="71" edge="1" source="20" target="30" value="trigger" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
    <mxCell id="72" edge="1" source="30" target="40" value="push image" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
    <mxCell id="73" edge="1" source="30" target="50" value="SSH script" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
    <mxCell id="74" edge="1" source="50" target="40" value="docker pull" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
    <mxCell id="75" edge="1" source="50" target="60" value="docker run" parent="1"><mxGeometry relative="1" as="geometry" /></mxCell>
  </root>
</mxGraphModel>
```

---

## Template DrawIO: Diagrama de Secuencia

Para flujos de autenticación u operaciones entre servicios:

```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" page="1" pageWidth="1169" pageHeight="827">
  <root>
    <mxCell id="0" /><mxCell id="1" parent="0" />

    <!-- Actores (cabeceras de lifeline) -->
    <mxCell id="10" value="Angular&#xa;Frontend" style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="80" y="30" width="100" height="50" as="geometry" />
    </mxCell>
    <mxCell id="11" value="ms-core&#xa;(Auth)" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="280" y="30" width="100" height="50" as="geometry" />
    </mxCell>
    <mxCell id="12" value="ms-{dominio}" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="480" y="30" width="100" height="50" as="geometry" />
    </mxCell>
    <mxCell id="13" value="SQL Server /&#xa;PostgreSQL" style="shape=mxgraph.flowchart.database;fillColor=#ffe6cc;strokeColor=#d6b656;" vertex="1" parent="1">
      <mxGeometry x="680" y="20" width="100" height="70" as="geometry" />
    </mxCell>

    <!-- Lifelines verticales -->
    <mxCell id="20" edge="1" style="endArrow=none;dashed=1;" source="10" target="10" parent="1">
      <mxGeometry relative="1" as="geometry"><Array as="points"><mxPoint x="130" y="80" /><mxPoint x="130" y="500" /></Array></mxGeometry>
    </mxCell>
    <mxCell id="21" edge="1" style="endArrow=none;dashed=1;" source="11" target="11" parent="1">
      <mxGeometry relative="1" as="geometry"><Array as="points"><mxPoint x="330" y="80" /><mxPoint x="330" y="500" /></Array></mxGeometry>
    </mxCell>
    <mxCell id="22" edge="1" style="endArrow=none;dashed=1;" source="12" target="12" parent="1">
      <mxGeometry relative="1" as="geometry"><Array as="points"><mxPoint x="530" y="80" /><mxPoint x="530" y="500" /></Array></mxGeometry>
    </mxCell>
    <mxCell id="23" edge="1" style="endArrow=none;dashed=1;" source="13" target="13" parent="1">
      <mxGeometry relative="1" as="geometry"><Array as="points"><mxPoint x="730" y="90" /><mxPoint x="730" y="500" /></Array></mxGeometry>
    </mxCell>

    <!-- Mensajes -->
    <mxCell id="30" edge="1" source="10" target="11" value="POST /auth/login" style="endArrow=open;" parent="1">
      <mxGeometry relative="1" y="150" as="geometry" />
    </mxCell>
    <mxCell id="31" edge="1" source="11" target="13" value="SELECT user" style="endArrow=open;" parent="1">
      <mxGeometry relative="1" y="200" as="geometry" />
    </mxCell>
    <mxCell id="32" edge="1" source="13" target="11" value="user record" style="endArrow=open;dashed=1;" parent="1">
      <mxGeometry relative="1" y="240" as="geometry" />
    </mxCell>
    <mxCell id="33" edge="1" source="11" target="10" value="JWT token" style="endArrow=open;dashed=1;" parent="1">
      <mxGeometry relative="1" y="290" as="geometry" />
    </mxCell>
    <mxCell id="34" edge="1" source="10" target="12" value="GET /resource&#xa;Authorization: Bearer {token}" style="endArrow=open;" parent="1">
      <mxGeometry relative="1" y="340" as="geometry" />
    </mxCell>
    <mxCell id="35" edge="1" source="12" target="13" value="SELECT data" style="endArrow=open;" parent="1">
      <mxGeometry relative="1" y="390" as="geometry" />
    </mxCell>
    <mxCell id="36" edge="1" source="13" target="12" value="data" style="endArrow=open;dashed=1;" parent="1">
      <mxGeometry relative="1" y="420" as="geometry" />
    </mxCell>
    <mxCell id="37" edge="1" source="12" target="10" value="200 OK + data" style="endArrow=open;dashed=1;" parent="1">
      <mxGeometry relative="1" y="460" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

---

## Cómo Usar Esta Skill

1. **Identificar qué documentación se necesita** usando la tabla "Qué Crear para Cada Pedido".
2. **Pedir al usuario los datos del proyecto** si no están especificados: nombre del servicio, dominio, base de datos, repositorios involucrados.
3. **Completar los templates** reemplazando los placeholders `{nombre}`, `{dominio}`, `{puerto}`, etc.
4. **Los archivos `.drawio`** se abren directamente en [draw.io](https://app.diagrams.net/) o en la extensión de VS Code "Draw.io Integration".
5. **Los workflows de GitHub Actions** van en `.github/workflows/deploy.yml` del repositorio correspondiente.
