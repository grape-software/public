# Prompt para generar un nuevo layout en Angular con Native Federation
Este prompt está diseñado para guiarte en la creación de un nuevo layout en un proyecto de microfrontend desarrollado con Angular y Native Federation, siguiendo las mejores prácticas de Grape Software.
```markdown
# Prompt: Crear Nuevo Layout en Angular con Native Federation
Objetivo: Generar un nuevo layout en un proyecto de microfrontend Angular utilizando Native Federation, siguiendo las mejores prácticas de Grape Software.
Instrucciones:
1. Abre una terminal en la raíz del proyecto Angular.
2. Asegurate que el Angular CLI esté instalado globalmente se corresponde con la version de angular que se desea instalar ej. 21.0.1, si no lo está, primero tienens que desinstalar la version anterior y luego instalar la version que corresponde:
    ```bash
    npm uninstall -g @angular/cli @angular/core
    npm install -g @angular/cli@latest @angular/core@latest
    ```
2. Crear el proyecto de angular Layout con la version correspondiente ej. Layout21
    ```bash
    ng new layout21 --style=scss --routing=true --ssr=false --ai-config=none
    ```
3. Navega al directorio del nuevo layout:
    ```bash
    cd layout21
    ```
4. Configurar el proyecto layout como HOST
    ```bash
    ng add @angular-eslint/schematics
    npm install --save-dev eslint-plugin-prettier eslint-config-prettier
    npm install --save-dev --save-exact prettier
    npm i @angular-architects/native-federation -D
    ng g @angular-architects/native-federation:init --project layout21 --port 4200 --type dynamic-host
    ng add @coreui/angular
    ```
5. Crear el archivo de configuración de Module Federation `federation.manifest.json` en la carpeta public del proyecto layout21 con el siguiente contenido:
    ```json
    {}
    ```
6. Crear el archivo extensions.json en la carpeta .vscode del proyecto layout21 con el siguiente contenido:
```json
{
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
7. Crear el archivo launch.json en la carpeta .vscode del proyecto layout21 con el siguiente contenido:
```json
{
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome against localhost",
      "url": "http://localhost:4200",
      "webRoot": "${workspaceFolder}"
    },
    {
      "name": "ng serve",
      "type": "chrome",
      "request": "launch",
      "preLaunchTask": "npm: start",
      "url": "http://localhost:4200/"
    }
  ]
}
```
8. Crear el archivo tasks.json en la carpeta .vscode del proyecto layout21 con el siguiente contenido:
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
9. Crear el archivo settings.json en la carpeta .vscode del proyecto layout21 con el siguiente contenido:
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
    "source.fixAll.tslint": "explicit"
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
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
10. El archivo index.html debe quedar con la siguiente configuración básica:
```html
<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <title></title>
    <base href="/" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- Disable cache for this HTML and all loaded resources -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <link id="favicon" rel="icon" type="image/x-icon" href="" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet" />
    <link
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"
      rel="stylesheet" />
  </head>
  <body>
    <app-root></app-root>
  </body>
</html>
```
11. Se debe crear la carpeta environments dentro de src y agregar los archivos environment.ts y environment.prod.ts con la configuración básica:
archivo environment.ts:
```typescript
export const environment = {
  production: false,
  useBrowserUrl: false, // if set to true origin is replace by browser url
  coreUrl: 'https://supermuni.sandbox.ar/api/core',
  // clubesUrl: 'https://www.mapadeclubes.ar/api/clubes',
  // coreUrl: 'https://localhost:5001',
  clubesUrl: 'https://localhost:7048',
  // URL base del servicio de Assistant (SSE)
  assistantUrl: 'https://supermuni.sandbox.ar/api/ms-grapeai',
  // coreUrl: 'https://comunidadcmcpsi.ar/api/core',
  // coreUrl: 'https://vm.superentrada.sandbox.ar/api/core',
  // coreUrl: 'https://localhost:5001',
  // coreUrl: 'https://www.mapadeclubes.ar/api/core',
  // coreUrl: 'https://localhost:5001',
  // clubesUrl: 'https://localhost:7048',
  //calendlyUrl:'https://comunidadescmcpsi.sandbox.ar/api/calendly/status'
  calendlyUrl: 'https://comunidadescmcpsi.sandbox.ar/api/calendly',
  version: '3.0.0',
  signalNotifications: false,
};
```
archivo environment.prod.ts:
```typescript
export const environment = {
  production: true,
  useBrowserUrl: true, // if set to true origin is replace by browser url
  assistantUrl: 'https://dominio.sandbox.ar/api/ms-grapeai',
  coreUrl: 'https://dominio.sandbox.ar/api/core',
  clubesUrl: 'https://dominio.sandbox.ar/api/clubes',
  signalUrl: 'https:///dominio.sandbox.ar/api/jobs',
  calendlyUrl: 'https://comunidadescmcpsi.sandbox.ar/api/calendly',
  version: '3.0.0',
  signalNotifications: false,
};
```
12. Dentro de App crear WebConfig.ts con la siguiente configuración básica:
```typescript
export class WebConfig {
  favIcon: string = '';
  title: string = '';
  tenantId: string = '';
  styleSheetName: string = '';
  logoUrl: string = '';
  backgroundUrl: string = '';
  menuConGrupos: boolean = false;
  homeTitle: string = '';
  homeUrl: string = '/';
  resetLastSearchOnMainMenu: boolean = false;
  useLayout: boolean = false;
  analytics: string = '';
  // landingPage: string = '';
  loginUrl: string = '';
  // customHome: string = '';
  registerUrl: string = '/register';
  validationCodeUrl: string = '/verification-code';
  afterInitUrl: string = '';
  afterLoginUrl: string = '';
  requiresTermsOnRegister: boolean = false;
  recaptchaPublicKey: string = '';
  termsRequired: boolean = false;
}
```
13. Crear el archivo token.interceptor.ts en la carpeta app con la siguiente configuración básica:
```typescript
import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { catchError, finalize, throwError } from 'rxjs';

import { DOCUMENT } from '@angular/common';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { environment } from '../environments/environment';
import { LoadingService } from './services/loading.service';

let totalRequests = 0;

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const document = inject(DOCUMENT);
  const loadingService = inject(LoadingService);
  const router = inject(Router);

  let newUrl = req.url;
  // change url origin with set in browser url
  // only affect when useBrowserUrl is set to true
  if (environment.useBrowserUrl) {
    const browserOrigin = document.location.origin;
    const currentOrigin = new URL(req.url).origin;
    newUrl = newUrl.replace(currentOrigin, browserOrigin);
  }

  // sets x-api-key header from tenantId
  const configString = localStorage.getItem('webConfig');
  let xapikey = '';
  if (configString) {
    const config = JSON.parse(configString);
    xapikey = config.tenantId || '';
  }

  const userString = localStorage.getItem('user');
  let isLoggedIn = false;
  let user = null;
  if (userString) {
    user = JSON.parse(userString);
    isLoggedIn = user && user.token;
  }

  // const iscoreUrl = req.url.startsWith(environment.coreUrl);
  if (isLoggedIn && user) {
    // && iscoreUrl) {
    req = req.clone({
      url: newUrl,
      setHeaders: {
        Authorization: `Bearer ${user.token}`,
        version: environment.version,
        'x-api-key': xapikey,
      },
    });
  } else {
    req = req.clone({
      url: newUrl,
      setHeaders: {
        version: environment.version,
        'x-api-key': xapikey,
      },
    });
  }

  // Global loader
  totalRequests++;
  loadingService.startLoading('Cargando...');
  // console.log(totalRequests + '-' + req.url);

  return next(req).pipe(
    // TODO: 401 al login
    catchError((error: HttpErrorResponse) => {
      // console.log('err-' + totalRequests + '-' + req.url);
      totalRequests--;
      if (totalRequests <= 0) {
        totalRequests = 0;
        loadingService.stopLoading();
      }
      if (error.status === 401) {
        // Verificar si estamos en una ruta de autenticación para evitar redirecciones no deseadas
        const currentUrl = router.url;
        const isAuthRoute =
          currentUrl.includes('/login') ||
          currentUrl.includes('/request-password') ||
          currentUrl.includes('/landing-login') ||
          currentUrl.includes('/validate-user') ||
          currentUrl.includes('/landing');

        if (!isAuthRoute) {
          const configString = localStorage.getItem('webConfig');
          const config = configString ? JSON.parse(configString) : null;
          const loginUrl = config ? config.loginUrl : '/route-not-found';
          router.navigate([loginUrl]);
        }
      } else if (error.status === 500) {
        console.error('Server error (500):', error);
      }
      return throwError(() => error);
    }),
    finalize(() => {
      // console.log('fin-' + totalRequests + '-' + req.url);
      totalRequests--;
      if (totalRequests <= 0) {
        totalRequests = 0;
        loadingService.stopLoading();
      }
    }),
  );
};
```
14. Crear el archivo auth.guard.ts en la carpeta app con la siguiente configuración básica:
```typescript
import { Router, RouterStateSnapshot } from '@angular/router';

export function authGuard(router: Router) {
  return (state: RouterStateSnapshot) => {
    const u = localStorage.getItem('user');
    // busca el webConfig de la app para mandarlo al loginUrl si no esta config lo manda al config-not-found
    const webConfigString = localStorage.getItem('webConfig');
    const config = webConfigString ? JSON.parse(webConfigString) : null;
    if (!config) {
      router.navigate(['/config-not-found']);
      return false;
    }
    if (!u) {
      router.navigate([config.loginUrl], { queryParams: { returnUrl: state.url } });
      return false;
    } else {
      const user = JSON.parse(u);
      if (user) {
        // user is logged
        return true;
      } else {
        router.navigate([config.loginUrl], { queryParams: { returnUrl: state.url } });
        return false;
      }
    }
  };
}
```
15. Crear el archivo app.initializer.ts en la carpeta app con la siguiente configuración básica:
```typescript
import { Injector, inject, runInInjectionContext } from '@angular/core';

import { AnalyticsService } from './services/analytics.service';
import { DOCUMENT } from '@angular/common';
import { InitService } from './services/init.service';
import { LoadingService } from './services/loading.service';
import { Router } from '@angular/router';
import { RoutesLoadingService } from './services/routes-loading.service';
import { TenantsService } from './services/tenants.service';
import { Title } from '@angular/platform-browser';
import { WebConfig } from './WebConfig';
import { buildRoutes } from './shared/buildRoutes';
import { environment } from 'src/environments/environment';
import { firstValueFrom } from 'rxjs';

/**
 * Factory para inicializar la aplicacion con la configuracion del tenant basado en la URL
 * En la base de datos TenantsInfo se configura un parámetro que encuentra el TenantId basado en la URL
 * Con el TenantId se busca WEB-INIT con la configuracion de la aplicacion
 * @param tenantsService Servicio de tenants
 * @param document Document
 * @returns Observable<any>
 */
export async function initializeApp() {
  const tenantsService = inject(TenantsService);
  const initService = inject(InitService);
  const titleService = inject(Title);
  const document = inject(DOCUMENT);
  const injector = inject(Injector);
  const loadingService = inject(LoadingService);
  const analyticsService = inject(AnalyticsService);

  loadingService.startLoading('Cargando datos...');
  const defaultConfig = Object.assign(new WebConfig(), { title: 'Portal Admin' });
  try {
    const { config, microfronts } = await firstValueFrom(initService.getConfig());
    if (config) {
      let webInitParam = new WebConfig();
      try {
        webInitParam = Object.assign(new WebConfig(), JSON.parse(config.config || '{}'));
      } catch (e) {
        console.error('Error parsing webConfig JSON:', e);
      }
      if (webInitParam) {
        Object.assign(defaultConfig, webInitParam);
        if (webInitParam.title && webInitParam.title.trim()) {
          titleService.setTitle(webInitParam.title.trim());
        }
        if (webInitParam.favIcon && webInitParam.favIcon.trim()) {
          let faviconElement = document.getElementById('favicon') as HTMLLinkElement | null;
          if (!faviconElement) {
            faviconElement = document.createElement('link');
            faviconElement.rel = 'icon';
            faviconElement.id = 'favicon';
            document.head.appendChild(faviconElement);
          }
          faviconElement.href = webInitParam.favIcon.trim();
        }
      }
      defaultConfig.tenantId = config.tenantId;
    }
    tenantsService.config = defaultConfig;
    localStorage.setItem('webConfig', JSON.stringify(defaultConfig));
    // Recaptcha se carga bajo demanda en login-base (no de forma global)
    if (defaultConfig.analytics && defaultConfig.analytics.trim()) {
      configureGoogleTagManager(defaultConfig.analytics);
      analyticsService.initialize(defaultConfig.analytics);
    }

    loadingService.stopLoading();

    // si estas en dev no cargo los microfronts
    if (environment.production) {
      await runInInjectionContext(injector, async () => {
        let router = inject(Router);
        let routesLoadingService = inject(RoutesLoadingService);
        await buildRoutes(router, microfronts, document, routesLoadingService);
      });
    }
  } catch (error: any) {
    let errorMessage = '';
    if (error.status === 0) {
      errorMessage = 'No pudimos obtener la configuración desde el servidor.';
    } else {
      errorMessage = 'Error initializing app: ' + (error.message || error);
    }
    loadingService.errorMessage.set(errorMessage);

    console.error('Error initializing app:', errorMessage);
    throw error;
  }
}

function configureGoogleTagManager(gtmId: string): void {
  try {
    const gtmScript = document.createElement('script');
    gtmScript.async = true;
    gtmScript.src = `https://www.googletagmanager.com/gtag/js?id=${gtmId}`;
    document.head.appendChild(gtmScript);

    const configScript = document.createElement('script');
    configScript.innerHTML = `
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', '${gtmId}');
      `;
    document.head.appendChild(configScript);

    // console.log('Google Tag Manager configurado correctamente con ID:', gtmId);
  } catch (error) {
    console.error('Error al configurar Google Tag Manager:', error);
  }
}
```
