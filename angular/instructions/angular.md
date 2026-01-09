# Grape Angular Copilot Instructions

You are a helpful assistant that provides best practices and instructions for initializing and developing microfrontend repositories in Angular based on Native Federation and Grape Software standards. This prompts serves as a guideline for developers to ensure consistency, maintainability, and quality across microfrontend projects. It includes instructions on repository structure, development environment setup, configuration management, logging, and deployment practices. You should follow these guidelines when creating or contributing to microfrontend repositories. You should ask the user for the name of the project when needed and replace {PROJECT_NAME} with the provided name in the instructions.

# Coding best practices

This document outlines the coding best practices to be followed in our projects to ensure code quality, maintainability, and collaboration efficiency.

## General Guidelines

- Follow consistent naming conventions for variables, methods, classes, and files. Use name that are descriptive and meaningful.
- Write clean and readable code. Use proper indentation, spacing, and line breaks to enhance code readability.
- Comment your code where necessary to explain complex logic or decisions. Avoid redundant comments that do not add value.
- Adhere to the DRY (Don't Repeat Yourself) principle. Avoid code duplication by creating reusable functions or modules.
- Use version control systems (e.g., Git) effectively. Commit changes with clear and concise messages.

## Language-Specific Practices

### JavaScript/TypeScript

- Use `const` and `let` instead of `var` for variable declarations.
- Prefer arrow functions for anonymous functions to maintain the lexical scope of `this`.
- Use template literals for string interpolation instead of concatenation.
- Leverage TypeScript's type system to define interfaces and types for better code safety.
- Methods with one line and not reusable should be written as arrow functions or in lined.
- Consider warning: Type boolean trivially inferred from a boolean literal, remove type annotation
- Avoid creating typed models for API responses when not necessary, use `any` type instead.

### Angular

- Use same html templates defined in Grape Design System for each component type.
- Do not use inline styles in components; instead, use external CSS or SCSS files. Don't create style file for components.
- Do not create tests in angular on each component.
- Organize code into modules, components, and services following Angular's best practices.
- Use Angular CLI for generating components, services, and other artifacts to ensure consistency.
- Use Angular's built-in directives and pipes for common tasks instead of reinventing the wheel.
- Implement lazy loading for modules to improve application performance.
- Numbers in tables should be right-aligned.
- label tag should have for= and id= input related
- Routes names should be plural in Upper Case separated with \_. Example RECIBOS_ROUTES
- Sort columns th should be implemented only in las column of the table, with a dropdown with all sortable columns like is in html sample template.

### Component types

#### Standard Search Model

This is the result for Grape Standard Search Model returning by http get search endpoints.

```json
{
  "totalCount": 0,
  "res": [],
  "search": {
    "pageIndex": 1,
    "pageSize": 1,
    "sortBy": null,
    "sortValue": null,
    "onlyActive": false,
    "searchText": null,
    "fromDate": null,
    "toDate": null
  }
}
```

where `res` is the array of items found with dynamic structure depending on the entity searched.

#### Crud Service

This is sample for a Crud Service, class name and endpoint route should be changed accordingly.

```typescript
import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { HelperService } from 'src/app/services/helper.service';
import { environment } from 'src/environments/environment';

export class NameService {
  private apiUrl = environment.paymentsUrl;
  private http = inject(HttpClient);
  private helper = inject(HelperService);

  search(par: any) {
    return this.http.get(this.apiUrl + '/Name/', {
      params: this.helpers.createHttpParams(par),
    });
  }
  get(id: number) {
    return this.http.get(this.apiUrl + '/Name/' + id);
  }
  delete(id: number) {
    return this.http.delete(this.apiUrl + '/Name/' + id);
  }
  add(Name: any) {
    return this.http.post(this.apiUrl + '/Name', Name);
  }
  update(Name: any) {
    return this.http.put(this.apiUrl + `/Name/${Name.NameId}`, Name);
  }
}
```

#### Search Component

For search components name should be entity-search.component.ts and entity-search.component.html.
Are used to search, create, update and delete entities. They should have this structure:

```html
<div class="card">
  <div class="card-header">
    <!-- <h3></h3> -->
  </div>
  <div class="card-body">
    <div class="d-flex justify-content-between">
      <!-- Autocomplete or search elements -->
      <div class="d-flex form-row flex-fill me-1">
        <input type="search" [(ngModel)]="searchInfo.searchText" class="form-control"
          placeholder="Ingrese el valor a buscar" (keyup.enter)="searchData(true)" />
      </div>

      <!-- Buttons -->
      <div class="d-flex float-end">
        <button
          type="button"
          (click)="searchData(true)"
          [disabled]="searchInfo.searching"
          value="Search"
          cTooltip="Buscar"
          class="btn btn-light"
        >
          <fa-icon icon="search"></fa-icon>
        </button>
        <button
          class="btn btn-light"
          type="button"
          cButton
          cTooltip="Filtros Avanzados"
          (click)="showAdvanced()"
        >
          <fa-icon icon="filter"></fa-icon>
          @if (searchInfo.totalCount>0) {
          <span class="badge bg-info">{{searchInfo.totalCount}}</span>
          }
        </button>
        <button class="btn btn-light" type="button" (click)="add()" cTooltip="Agregar">
          <fa-icon icon="plus"></fa-icon>
        </button>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-body">
      @if (items.length>0) {
      <div class="table-responsive">
        <table class="table">
          <thead class="align-middle">
            <tr>
              <th></th>
              <th>XXXX</th>
              <th>XXXX</th>
              <th class="text-end">
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
              </th>
            </tr>
          </thead>
          <tbody>
            @for (data of items | paginate: {id:'', itemsPerPage: searchInfo.pageSize, currentPage:
            searchInfo.pageIndex, totalItems: searchInfo.totalCount}; track data) {
            <tr>
              <td>{{data.algo}}</td>
              <td>
                @if (data.XXXX>0) {
                <div>{{data.XXXX}}</div>
                }
                <!-- if you need to show more than a field by column -->
                {{data.value | currency: 'ARS':'symbol'}}
              </td>
              <td>{{data.fecha | date: "dd/MM/yyyy" }}</td>
              <td>
                <div class="float-end d-flex">
                  <button class="btn btn-light" type="button" (click)="edit(data)" cTooltip="Editar">
                    <fa-icon icon="pen"></fa-icon>
                  </button>
                  <button class="btn btn-light" type="button" (click)="showDetail(data)" cTooltip="Detalle">
                    <fa-icon icon="info"></fa-icon>
                  </button>
                  <button class="btn btn-light" type="button" (click)="showDelete(data)" cTooltip="Eliminar">
                    <fa-icon icon="trash-alt" class="text-danger"></fa-icon>
                  </button>
                </div>
                </div>
              </td>
            </tr>
            }
          </tbody>
        </table>
      </div>
      <div class="row">
        <div class="text-center">
          <pagination-controls
            id=""
            [autoHide]="true"
            previousLabel=""
            nextLabel=""
            [responsive]="true"
            (pageChange)="pageChanged($event)"
          ></pagination-controls>
        </div>
      </div>
      } @if (items.length===0 && searched) {
      <div class="clearfix">
        <p class="p-3 my-3 bg-warning text-dark">
          <fa-icon icon="inbox"></fa-icon>
          Sin resultados
        </p>
      </div>
      }
    </div>
  </div>
</div>

<c-modal id="dialogDelete">
  <c-modal-header>
    <h4 cModalTitle>Confirmar Eliminar</h4>
    <button
      cButtonClose
      (click)="modalService.toggle({ show: false })"
      aria-label="Cerrar"
    ></button>
  </c-modal-header>
  <c-modal-body>
    <p>¿Confirma la eliminación?. Este proceso no se puede revertir.</p>
  </c-modal-body>
  <c-modal-footer>
    <button type="button" cButton color="danger" (click)="delete()">Eliminar</button>
    <button type="button" cButton color="secondary" (click)="modalService.toggle({ show: false })">
      Cancelar
    </button>
  </c-modal-footer>
</c-modal>
<c-modal id="dialogAdvanced">
  <c-modal-header>
    <h4 cModalTitle>Filtros Avanzados</h4>
    <button
      cButtonClose
      (click)="modalService.toggle({ show: false })"
      aria-label="Cerrar"
    ></button>
  </c-modal-header>
  <c-modal-body>
    <!-- Add filters elements -->
    <div class="alert alert-info" role="alert">
      No hay definido filtros avanzados para este módulo.
    </div>
  </c-modal-body>
  <c-modal-footer>
    <button
      type="button"
      cButton
      color="secondary"
      (click)="modalService.toggle({ show: false })"
      label="No"
    >
      Cerrar
    </button>
    <button type="button" cButton color="primary" (click)="applyAdvanced()" label="Yes">
      Aplicar
    </button>
  </c-modal-footer>
</c-modal>
```

```typescript
imports: [...sharedDeclarations],
  private router = inject(Router);
  private helpers = inject(HelperService);
  public modalService = inject(ModalService);
  private CRUDService = inject(CRUDService);
  private faLib = inject(FaIconLibrary);

  storagekey = '';
  searchInfo: any;
  items: any[] = [];
  selected: any;
  searched = false;
  orderItems = [{ title: 'Item', data: 'nameOfField', selected: false }];

constructor() {
    this.faLib.addIcons(
      faPlus,
      faFilter,
      faSearch,
      faInbox,
      faSortAmountDown,
      faTicketAlt,
      faSortAmountDownAlt,
      faSort,
      faChartPie,
      faEye,
    );
  }
  ngOnInit(): void {
    // Last search saved in local storage
    // It's reseted when any menu item is clicked
    let reset = true;
    this.storagekey = `search.${this.helpers.getUrlName(this.router.url)}`;
    if (this.helpers.existsInStorage(this.storagekey)) {
      this.searchInfo = this.helpers.readFromStorage(this.storagekey);
      reset = false;
    } else {
      // Read LocalStorage to setup last searchInfo with defaults
      this.searchInfo = this.helpers.readFromStorage(this.storagekey);
      this.searchInfo.searching = false;
      this.searchInfo.onlyActive = true;
      this.searchInfo.totalCount = 0;
      // this.searchInfo.fromDate = this.helpers.fechaDias(-30);
    }
    this.searchData(reset);
  }
  /**
   * Fires when page numbers is clicked
   * @param event the page clicked
   */
  pageChanged(event: any): void {
    this.searchInfo.pageIndex = event;
    this.searchData(false);
  }
  /**
   * Fires when sort option is clicked
   * @param key is data attribute from OrderItems array clicked
   */
  onSort(key: any): void {
    if (this.searchInfo.sortBy === key) {
      if (this.searchInfo.sortValue === 'asc') {
        this.searchInfo.sortValue = 'desc';
      } else {
        this.searchInfo.sortValue = 'asc';
      }
    }
    this.searchInfo.sortBy = key;
    this.searchData(true);
  }
  /**
   * Fires search API, when page is changed reset is false
   * @param reset specified if page is reseted, only is false when pages changes
   */
  searchData(reset = false): void {
    if (reset) {
      this.searchInfo.pageIndex = 1;
    }
    this.searched = true;
    this.helpers.saveToStorage(this.storagekey, this.searchInfo);
    this.searchInfo.searching = true;
    this.Service.search(this.searchInfo).subscribe({
      next: (r: any) => {
        // Result with Search API signature
        this.items = r.res;
        this.searchInfo.totalCount = r.totalCount;
        this.searchInfo.searching = false;
      },
      error: (e: any) => {
        this.searchInfo.searching = false;
        this.helpers.HandleNonSuccessfulHttpResponse(e);
      },
    });
  }
  showAdvanced(template: TemplateRef<any>): void {
    this.dialogAdvancedRef = this.modalService.toggle({ show: true, id: 'dialogAdvanced', size: 'md' });
  }
  applyAdvanced(): void {
    this.modalService.toggle({ show: false, id: 'dialogAdvanced' });
    this.searchData(true);
  }

  // Is used if add is in Modal
  showAdd(data: any, template: TemplateRef<any>): void {
    if (!data) this.selected = { conceptoIngresoId: 0 };
    else this.selected = data;
    this.dialogEditRef = this.modalService.toggle({ show: true, id: 'dialogEdit' });
  }
  // Is used if add is in Modal
  showEdit(data: any, template: TemplateRef<any>) {
    this.selected = data.sedeId;
    this.dialogEditRef = this.modalService.toggle({ show: true, id: 'dialogEdit' });
  }
  // Is used if add is in Modal
  acceptChanges() {
    this.modalService.toggle({ show: false, id: 'dialogEdit' });
    this.searchData(true);
  }

  // When Add is in other page
  add(): void {
    this.helpers.RaiseNotification('warning', 'Error', 'Not implemented');
    this.router.navigate(['$../add'], { relativeTo: this.activatedRoute });
  }
  // When Edit is in other page
  edit(data: any) {
    this.selected = data;
    if (this.selected) {
      this.router.navigate(['../add', { Id: this.selected. }], { relativeTo: this.activatedRoute });
    }
  }

  showDelete(data: any, template: TemplateRef<any>): void {
    this.selected = data;
    this.dialogDeleteRef = this.modalService.toggle({ show: true, id: 'dialogDelete'});
  }
  delete(): void {
    this.items.pop();
    this.modalService.toggle({ show: false });
    this.helpers.RaiseNotification('warning', 'Error', 'Not implemented');
  }
  showDetail(data: any, template: TemplateRef<any>): void {
    this.selected = data;
    this.dialogDetailRef = this.modalService.toggle({ show: true, id: 'dialogDetail' });
  }
```

#### Search List

When only a list of items is needed without create, update or delete functionalities. They should have this structure:

```html
<div class="card">
  <div class="card-header">
    <div class="float-start">
      @if (showBack) {
      <button class="btn btn-light mr-2" type="button" cTooltip="Volver" (click)="back()">
        <fa-icon icon="arrow-left"></fa-icon>
      </button>
      }
    </div>
    <h3>Detalle para {{ objeto.Nombre}}</h3>
  </div>
  <div class="card-body">
    @if (items.length > 0) {
    <div class="table-responsive">
      <table class="table">
        <thead class="align-middle">
          <tr>
            <th>Col1</th>
            <th>Col2</th>
            <th>Creación</th>
            <th class="text-end">
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
            </th>
          </tr>
        </thead>
        <tbody>
          @for (data of items | paginate: {id: 'id1', itemsPerPage: searchInfo.pageSize,
          currentPage: searchInfo.pageIndex, totalItems: searchInfo.totalCount}; track data) {
          <tr class="small">
            <td>{{ data.col1 }}</td>
            <td>{{ data.col2 }}</td>
            <td>
              <div>
                <b>Usuario:</b>
                {{ data.user?.identifier }}
              </div>
              <div>
                <b>F.Alta:</b>
                {{ data.fechaAlta | date : 'dd/MM/yyyy' }}
              </div>
            </td>
            <td>
              <div class="float-end d-flex">
                <button
                  class="btn btn-light"
                  type="button"
                  (click)="action(data)"
                  cTooltip="Tootltip here"
                >
                  <fa-icon icon="calendar"></fa-icon>
                </button>
              </div>
            </td>
          </tr>
          }
        </tbody>
      </table>
    </div>
    <div class="row">
      <div class="text-center">
        <pagination-controls
          id="id1"
          [autoHide]="true"
          previousLabel=""
          nextLabel=""
          [responsive]="true"
          (pageChange)="pageChanged($event)"
        ></pagination-controls>
      </div>
      } @if (items.length === 0 && searched) {
      <div class="clearfix">
        <p class="p-3 my-3 bg-warning text-dark">
          <fa-icon icon="inbox"></fa-icon>
          Sin resultados
        </p>
      </div>
      }
    </div>
  </div>
</div>
```

```typescript
  @Input() showBack: boolean = false;
  objeto: any;
  storagekey = '';
  searchInfo: any;
  items: any[] = [];
  selected: any;
  searched = false;
  orderItems = [
    { title: 'Default', data: 'orderColumn', selected: true },
  ];
  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private helpers: HelperService,
    private location: Location,
  ) {}
  ngOnInit(): void {
    // Last search saved in local storage
    // It's reseted when any menu item is clicked
    let reset = true;
    this.storagekey = `search.${this.helpers.getUrlName(this.router.url)}`;
    // permite forzar el reseteo desde el componente padre
    if (this.activatedRoute.snapshot.paramMap.get('reset')) {
      // Read LocalStorage to setup last searchInfo with defaults
      this.searchInfo = this.helpers.readFromStorage(this.storagekey);
      this.searchInfo.searching = false;
      this.searchInfo.onlyActive = true;
      this.searchInfo.totalCount = 0;
    } else {
      if (this.helpers.existsInStorage(this.storagekey)) {
        this.searchInfo = this.helpers.readFromStorage(this.storagekey);
        reset = false;
      } else {
        // Read LocalStorage to setup last searchInfo with defaults
        this.searchInfo = this.helpers.readFromStorage(this.storagekey);
        this.searchInfo.searching = false;
        this.searchInfo.onlyActive = true;
        this.searchInfo.totalCount = 0;
        // this.searchInfo.fromDate = this.helpers.fechaDias(-30);
      }
    }
    if (this.activatedRoute.snapshot.paramMap.get('showBack')) {
      this.showBack = this.activatedRoute.snapshot.paramMap.get('showBack') === 'true';
    }
    if (this.activatedRoute.snapshot.paramMap.get('ofertaMateriaId')) {
      this.searchInfo.ofertaMateriaId = this.activatedRoute.snapshot.paramMap.get('ofertaMateriaId');
    } else {
      this.searchInfo.ofertaMateriaId = null;
    }
    if (this.activatedRoute.snapshot.paramMap.get('personaId')) {
      this.searchInfo.personaId = this.activatedRoute.snapshot.paramMap.get('personaId');
    } else {
      this.searchInfo.personaId = null;
    }
    if (this.activatedRoute.snapshot.paramMap.get('carreraId')) {
      this.searchInfo.carreraId = this.activatedRoute.snapshot.paramMap.get('carreraId');
      this.carrerasService.getCarrera(this.searchInfo.carreraId).subscribe({
        next: (r: any) => {
          this.materiaDescripcion = r.descripcion;
        },
      });
    } else {
      this.searchInfo.carreraId = null;
    }
    this.searchData(reset);
  }
  /**
   * Fires when page numbers is clicked
   * @param event the page clicked
   */
  pageChanged(event: any): void {
    this.searchInfo.pageIndex = event;
    this.searchData(false);
  }
  /**
   * Fires when sort option is clicked
   * @param key is data attribute from OrderItems array clicked
   */
  onSort(key: any): void {
    if (this.searchInfo.sortBy === key) {
      if (this.searchInfo.sortValue === 'asc') {
        this.searchInfo.sortValue = 'desc';
      } else {
        this.searchInfo.sortValue = 'asc';
      }
    }
    this.searchInfo.sortBy = key;
    this.searchData(true);
  }
  /**
   * Fires search API, when page is changed reset is false
   * @param reset specified if page is reseted, only is false when pages changes
   */
  searchData(reset: boolean = false): void {
    if (reset) {
      this.searchInfo.pageIndex = 1;
    }
    this.searched = true;
    this.helpers.saveToStorage(this.storagekey, this.searchInfo);
    this.searchInfo.searching = true;
    this.SERVICIOPARABUSCAR.search(this.searchInfo).subscribe({
      next: (r: any) => {
        // Result with Search API signature
        this.items = r.res;
        this.searchInfo.totalCount = r.totalCount;
        this.searchInfo.searching = false;
      },
      error: (e: any) => {
        this.searchInfo.searching = false;
        this.helpers.HandleNonSuccessfulHttpResponse(e);
      },
    });
    this.setMateriaDescripcion();
  }

  back() {
    this.location.back();
  }
```
