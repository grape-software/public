# Repository Initialization

1. Run command to create a new Angular microfrontend project:

**Nota:** Angular CLI no permite usar "." como nombre de proyecto, por lo que se crea con un nombre temporal y luego se mueven los archivos a la raíz.

```bash
# Crear el proyecto con un nombre temporal (usar el nombre del directorio actual o {PROJECT_NAME})
ng new {PROJECT_NAME} --style=scss --routing=true --new-project-root . --skip-git

# Mover todos los archivos de la subcarpeta a la raíz del proyecto
# En PowerShell:
Get-ChildItem -Path {PROJECT_NAME} -Force | Move-Item -Destination . -Force
Remove-Item -Path {PROJECT_NAME} -Force -ErrorAction SilentlyContinue

# En Linux/Mac:
# mv {PROJECT_NAME}/* . 2>/dev/null || true
# mv {PROJECT_NAME}/.* . 2>/dev/null || true
# rmdir {PROJECT_NAME}

# Continuar con la configuración
ng add @angular-eslint/schematics
npm install --save-dev eslint-plugin-prettier eslint-config-prettier
npm install --save-dev --save-exact prettier
ng add @angular-architects/native-federation
ng g environments
```

2. Configurar el archivo eslint.config.js, agregando esta linea en rules:

```json
rules: {
  "@typescript-eslint/no-explicit-any": "off",
```

3. Buscar el archivo gr-common-angular.zip, descomprimirlo y copiar el contenido de gr-common-angular.zip a la carpeta del proyecto src\app

4. crear web-init.json en la carpeta public con el contenido especificado:

```json
{
  "favIcon": "favicon.ico",
  "title": "Microfrontend {PROJECT_NAME}",
  "menuConGrupos": false,
  "logoUrl": "",
  "homeTitle": "Bienvenido a {PROJECT_NAME}",
  "resetLastSearchOnMainMenu": true
}
```

5. Agregar al archivo tsconfig.json la siguiente especificacion dentro del objeto compilerOptions:

```json
"baseUrl": "./",
"paths": {
  "src/*": ["src/*"]
},
"resolveJsonModule": true,
```

6. Agregar dependencias con el siguiente comando:

```bash
npm i bootstrap
npm i ngx-toastr
npm i ngx-pagination
ng add @angular/material
ng add @coreui/angular
```

7. Acomodar angular.json:

```json
						"styles": [
							"node_modules/bootstrap/dist/css/bootstrap.min.css",
							"src/styles.scss"
						],
					"options": {
						"port": 4201
					}
```

8. Acomodar app.routes.ts:

```typescript
import { Routes } from '@angular/router';
import { LoginMfeComponent } from './login-mfe/login-mfe.component';

export const routes: Routes = [
  {
    path: 'login',
    component: LoginMfeComponent,
  },
];
```

**Nota:** Si los archivos `auth/auth.routes.ts` y `config/config.routes.ts` no existen después de descomprimir gr-common-angular.zip, crearlos con el siguiente contenido:

- src/app/auth/auth.routes.ts:

```typescript
import { Routes } from '@angular/router';

export const AUTH_ROUTES: Routes = [];
```

- src/app/config/config.routes.ts:

```typescript
import { Routes } from '@angular/router';

export const CONFIG_ROUTES: Routes = [];
```

9. Acomodar app.config.ts:

```typescript
import {
  ApplicationConfig,
  importProvidersFrom,
  inject,
  provideAppInitializer,
} from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule, provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { DOCUMENT } from '@angular/common';
import { ModalService } from '@coreui/angular';
import { TenantsService } from './services/tenants.service';
import { initializeAppFactory } from './core/initializeAppFactory';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideToastr } from 'ngx-toastr';
import { routes } from './app.routes';
import { tokenInterceptor } from './core/http-interceptor.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideAnimations(), // required animations providers
    provideToastr({}),
    provideRouter([...routes]),
    // provideRouter(routes),
    // provideAppInitializer(() => initializeAppFactory(inject(TenantsService))),
    ModalService,
    importProvidersFrom(RouterModule, FormsModule, ReactiveFormsModule),
    provideAppInitializer(() => initializeAppFactory(inject(TenantsService), inject(DOCUMENT))),
    provideHttpClient(withInterceptors([tokenInterceptor])),
  ],
};
```

10. Acomodar main.ts:

```typescript
import { initFederation } from '@angular-architects/native-federation';

initFederation()
  .catch((err) => console.error(err))
  .then((_) => import('./bootstrap'))
  .catch((err) => console.error(err));
```

## Configuracion de carpeta .vscode

Crear carpeta .vscode en la raiz del proyecto y agregar los siguientes archivos:

- settings.json

```json
{
  "debug.openExplorerOnEnd": true,
  "editor.tabSize": 2,
  "editor.rulers": [120],
  "editor.autoIndent": "full",
  "editor.cursorBlinking": "solid",
  "editor.formatOnType": false,
  "editor.formatOnPaste": false,
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit",
    "source.fixAll.tslint": "never"
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[html]": {
    "editor.defaultFormatter": "vscode.html-language-features"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "explorer.openEditors.visible": 1,
  "files.trimTrailingWhitespace": true,
  "files.autoSave": "off",
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "typescript.tsdk": "node_modules/typescript/lib",
  "workbench.iconTheme": "material-icon-theme",
  "auto-close-tag.SublimeText3Mode": true,
  "html.autoClosingTags": true,
  "ng-evergreen.upgradeChannel": "Latest"
}
```

- extensions.json

```json
{
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=827846
  "recommendations": [
    "angular.ng-template",
    "amatiasq.sort-imports",
    "DSKWRK.vscode-generate-getter-setter",
    "esbenp.prettier-vscode",
    "johnpapa.vscode-peacock",
    "ms-azuretools.vscode-docker",
    "PKief.material-icon-theme",
    "expertly-simple.ng-evergreen",
    "formulahendry.auto-close-tag",
    "johnpapa.angular-essentials"
  ]
}
```

- launch.json

```json
{
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome against localhost",
      "url": "http://localhost:4201",
      "webRoot": "${workspaceFolder}"
    }
  ]
}
```

- tasks.json

```json
{
  // For more information, visit: https://go.microsoft.com/fwlink/?LinkId=733558
  "version": "2.0.0",
  "tasks": [
    {
      "type": "npm",
      "script": "start",
      "isBackground": true,
      "problemMatcher": {
        "owner": "typescript",
        "pattern": "$tsc",
        "background": {
          "activeOnStart": true,
          "beginsPattern": {
            "regexp": "(.*?)"
          },
          "endsPattern": {
            "regexp": "bundle generation complete"
          }
        }
      }
    },
    {
      "type": "npm",
      "script": "test",
      "isBackground": true,
      "problemMatcher": {
        "owner": "typescript",
        "pattern": "$tsc",
        "background": {
          "activeOnStart": true,
          "beginsPattern": {
            "regexp": "(.*?)"
          },
          "endsPattern": {
            "regexp": "bundle generation complete"
          }
        }
      }
    }
  ]
}
```

11. Configurar los environments en src/environments:

- environment.ts

```typescript
export const environment = {
  production: false,
  useBrowserUrl: false, // if set to true origin is replace by browser url
  useRenaper: false,
  version: '1.0.0',
  coreUrl: 'https://cmcpsi.sandbox.ar/api/core',
};
```

- environment.development.ts, eliminar el archivo si existe

- environment.prod.ts

```typescript
export const environment = {
  production: true,
  useBrowserUrl: false,
  version: '1.0.0',
  coreUrl: 'https://cmcpsi.sandbox.ar/api/core',
};
```

Acomodar el angular.json para que use el environment en modo dev y si se hace un npm run build se configure el replace de prod.

En la configuración de producción de esbuild, agregar:

```json
"production": {
  "fileReplacements": [
    {
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.prod.ts"
    }
  ],
  ...
}
```

La configuración de development ya debería tener el fileReplacements configurado para usar environment.development.ts.

12. probar que todo funcione correctamente con ng build

13. Acomodar la maquetacion de app.html segun la siguiente especificacion:

```html
<app-spinner /> <router-outlet />
```

**Importante:** También es necesario importar SpinnerComponent en app.ts:

```typescript
import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { LayoutSpinnerComponent } from './shared/spinner/layout-spinner.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, LayoutSpinnerComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected readonly title = signal('{PROJECT_NAME}');
}
```
