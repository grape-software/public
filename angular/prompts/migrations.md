# Angular Migrations prompts
Este archivo contiene prompts específicos para manejar migraciones en proyectos de microfrontends desarrollados con Angular. Estos prompts están diseñados para facilitar la actualización de dependencias, la adaptación a nuevas versiones de Angular y la integración de nuevas funcionalidades siguiendo las mejores prácticas de Grape Software y las recomendaciones oficiales de Angular.
## Prompts disponibles
- **Actualizar Dependencias**: Prompt para actualizar las dependencias del proyecto a las versiones más recientes compatibles.
- **Adaptar a Nueva Versión de Angular**: Prompt para guiar en la adaptación del proyecto a una nueva versión de Angular, incluyendo cambios en la configuración y el código. Tomando en cuenta las recomendaciones oficiales de Angular.
- **Integrar Nuevas Funcionalidades**: Prompt para agregar nuevas funcionalidades recomendadas en las últimas versiones de Angular, siguiendo las mejores prácticas de Grape Software y las recomendaciones oficiales de Angular.
## Uso de los Prompts
Para utilizar estos prompts, sigue los pasos a continuación:
1. Descarga el archivo `migrations.md` desde el repositorio `grape-software/public`.
2. Abre el archivo y selecciona el prompt que deseas utilizar.
3. Sigue las instrucciones proporcionadas en el prompt para realizar la migración deseada.
## Notas Adicionales
- Asegúrate de tener una copia de seguridad de tu proyecto antes de realizar cualquier migración.
- Revisa las notas de la versión oficial de Angular para entender los cambios introducidos en cada versión.
- Consulta con el equipo de arquitectura de Grape Software si tienes dudas sobre las mejores prácticas a seguir durante la migración.
- Mantente al tanto de las actualizaciones en el repositorio `grape-software/public` para obtener nuevos prompts y mejoras en los existentes.

## Actualizar Dependencias

Hay que seguir la guia que esta en https://angular.dev/update-guide?v=19.0-21.0&l=3 indica la version del paquete actual y la version a la que se quiere actualizar, por lo general es la ultima version estable. Lo que recomienda es hacer las actualizaciones mayores de una en una, es decir si se esta en la version 19 y se quiere actualizar a la 21, primero se actualiza a la 20 y luego a la 21.

```markdown
# Prompt: Actualizar Dependencias
Objetivo: Actualizar las dependencias del proyecto Angular a las versiones más recientes compatibles.
Se puede realizar manualmente con el CLI de Angular o utilizar la extensión Evengreen para automatizar este proceso.
Con el CLI de Angular:
1. Abre una terminal en la raíz del proyecto Angular.
2. Hacer una copia de seguridad del código fuente dejando un tag en el control de versiones de git. Se realiza con el siguiente comando:
   ```bash
   git tag backup-pre-update-<fecha>
   ```
3. Verifica las versiones actuales de las dependencias ejecutando:
   ```
   ng version
   ```
4. Verifica los paquetes desactualizados ejecutando:
   ```
   ng update
   ```
5. Ejecuta el siguiente comando para actualizar Angular CLI y Angular Core:
   ```
   ng update @angular/cli@VERSIONQUECORRESPONDAHASTALAULTIMA @angular/core@VERSIONQUECORRESPONDAHASTALAULTIMA
   ```
6. Revisa las dependencias adicionales que puedan necesitar actualización ejecutando:
   ```
    ng update
    ```
7. Sigue las instrucciones proporcionadas por el CLI para completar la actualización.


## Cambio en las maquetas
Todas las maquetas html se deben actualizar para utilizar:
- las directivas @if en lugar en los *ngIf, de esta forma se mejora el rendimiento de las aplicaciones angular.
- las directivas @for en lugar de los *ngFor, de esta forma se mejora el rendimiento de las aplicaciones angular.
- los nuevos componentes de CoreUI en lugar de los componentes de Bootstrap, de esta forma se mejora la consistencia visual y el rendimiento de las aplicaciones angular. 
En este caso el reemplazo sería de esta forma:
1. se reemplazan los templates de modals <ng-template #dialogAdvanced> por <c-modal id="dialogAdvanced"> y las directivas correspondientes:
El ejemplo de código completo quedaría así:
```html
<c-modal id="dialogAdvanced">
  <c-modal-header>
    <h4 cModalTitle>Filtros Avanzados</h4>
    <button cButtonClose (click)="modalService.toggle({ show: false, id: 'dialogAdvanced' })"
      aria-label="Cerrar"></button>
  </c-modal-header>
  <c-modal-body>
    <!-- Add filters elements -->
    <div class="alert alert-info" role="alert">
      No hay definido filtros avanzados para este módulo.
    </div>
  </c-modal-body>
  <c-modal-footer>
    <button type="button" cButton color="secondary" (click)="modalService.toggle({ show: false, id: 'dialogAdvanced' })"
      label="No">
      Cerrar
    </button>
    <button type="button" cButton color="primary" (click)="applyAdvanced()" label="Yes">
      Aplicar
    </button>
  </c-modal-footer>
</c-modal>
```
2. Se reemplazan las directivas tooltip por cTooltip
3. Se agregan a los componentes de botones que abren modal por cButton
4. El dropdown de orderItems se reemplaza por:
```html
                @if (orderItems.length > 0) {
                <c-dropdown>
                  <button cDropdownToggle cButton class="btn btn-light" type="button">
                    @if (searchInfo.sortValue === 'asc') {
                    <fa-icon icon="sort-amount-down-alt"></fa-icon>
                    } @else {
                    <fa-icon icon="sort-amount-down"></fa-icon>
                    }
                  </button>
                  <ul cDropdownMenu>
                    @for (o of orderItems; track o.data) {
                    <li>
                      <button cDropdownItem (click)="onSort(o.data)">{{ o.title }}</button>
                    </li>
                    }
                  </ul>
                </c-dropdown>
                }
```
5. Se quitan los parámetros de los templates en las llamadas a los modals, ya que ahora se pasan por el servicio de modals de CoreUI. Ej.
```html
                  <button class="btn btn-light" type="button" (click)="edit(data)" cTooltip="Editar">
                    <fa-icon icon="pen"></fa-icon>
                  </button>
```

## Cambios en los typescript de componentes
Hay que actualizar los typescript de los componentes para utilizar el servicio de modals de CoreUI en lugar de los templates de Bootstrap. Los ejemplos de código quedarían así:
1. Se quitan los atributos dialogAdvancedRef.
2. Reemplazar en el constructor la inyeccion de todos los servicios de private modalService: ModalService a public modalService = inject(ModalService); utilizando la nueva sintaxis de Angular.
3. Utilizar signals para manejar los estados de los componentes en lugar de variables normales.
4. Reemplazar las llamadas a los modals por el servicio de modals de Core. Ejemplo this.modalService.toggle({ show: true, id: 'dialogAdvanced' });
5. Quitar los TemplateRef y ViewChild relacionados con los modals.