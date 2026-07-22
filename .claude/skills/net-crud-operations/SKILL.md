---
name: net-crud-operations
description: >
  Create complete CRUD API endpoints in .NET following Grape Software standards.
  Use this skill when the user asks to create CRUD operations, API endpoints,
  a controller, or REST operations for a specific entity in a .NET microservice.
  Triggers on: "create crud for", "create controller for", "add endpoints for",
  "implement crud", "generate crud", "crea el crud para", "crea endpoints para",
  "implementa crud", or any request to produce REST API controller methods
  for a specific entity or data model in a .NET project.
  Do NOT use for Angular, TypeScript, or non-.NET backends.
---

# .NET CRUD Operations — Grape Software

Generate complete, production-ready CRUD controllers for .NET microservices following Grape Software coding standards.

---

## Step 1 — Identify the Entity and Locate the DbSet

When the user names an entity (e.g., `TransaccionIngreso`), you must find the exact DbSet property name used in the project's Entity Framework DbContext **before writing any code**.

1. Search for files named `*Context.cs` or `*DbContext.cs` in the project:
   - Look for a `DbSet<{EntityName}>` declaration.
   - The property name on the DbContext (e.g., `TransaccionesIngresos`, `TransaccionIngreso`) is what you will use throughout the code for `db.{DbSetName}`.

2. If the DbContext file is not accessible, ask the user: _"¿Cómo se llama el DbSet en el DbContext que gestiona `{EntityName}`?"_

3. Also inspect the entity class to understand:
   - The primary key name and type (use `int` for transactional entities, `Guid`/`string` for reference entities).
   - Which string attributes exist (for full-text search filtering).
   - Whether it has `Active`, `Created`, `Updated`, `UserId` properties.
   - First-level navigation properties (non-list relations) to `Include()` in Get by Id.
   - A sensible default sort attribute.

---

## Step 2 — Apply Grape .NET Coding Standards

Follow these rules strictly in all generated code:

- Controller class name must be **plural** of the entity name and inherit `BaseApiController`.
  Example: entity `Producto` → controller `ProductosController`.
- Route attribute: `[Route("[controller]")]`
- **No blank lines** between code lines (exception: methods over 100 lines).
- **No unnecessary variables** — use expressions directly where clarity is not lost.
- **No unnecessary `using` directives** — include only what the file actually needs. Add a blank line after the `using` block.
- Use `async`/`await` throughout. All async methods must end with the `Async` suffix.
- Use `AsNoTracking()` for all read-only queries. Never write `AsTracking()`.
- Use `FirstOrDefaultAsync`, `ToListAsync`, `AnyAsync`, `CountAsync` (not their sync versions).
- All exceptions go through `HandleException(ex)` from `BaseApiController`.
- Business rule violations must throw `BusinessException`.
- `if` blocks with a single line inside: remove the braces.
- Use `ModelErrors(ModelState)` helper for model validation error messages.
- Return types are always `IActionResult`.
- Only include `record.UserId = JWTUser.UserID` and `record.Created = DateTime.Now` if the entity has those properties.
- Do not create DTO objects for partial representations — use the entity directly.
- Ask the user which language to use for error/success messages if not specified. **Default: Spanish.**

---

## Step 3 — Controller Scaffold

```csharp
[ApiController]
[Route("[controller]")]
public class {Entity}sController : BaseApiController
{
    private readonly {DbContextType} db;

    public {Entity}sController({DbContextType} db)
    {
        this.db = db;
    }

    // CRUD methods go here
}
```

Replace `{DbContextType}` with the actual DbContext class name found in the project.

---

## Step 4 — Search (GET list, paginated)

```csharp
/// <summary>
/// Obtiene lista paginada de {Entity}
/// </summary>
/// <remarks>
/// Sample request:
///     GET /{Entity}s
/// </remarks>
/// <param name="search">Parámetros de búsqueda y paginado</param>
/// <returns>totalCount=total de registros, res=registros paginados, search=parámetros enviados</returns>
/// <response code="200">Ejecutado sin problemas</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado</response>
/// <response code="500">Error no controlado, el mensaje tiene más detalle</response>
[HttpGet]
public async Task<IActionResult> Get{Entity}s([FromQuery] SearchModel search)
{
    try
    {
        var user = JWTUser;
        var q1 = from o in db.{DbSetName}
                 select o;

        if (!string.IsNullOrWhiteSpace(search.SearchText))
            foreach (var s in search.SearchText.Split(" "))
                q1 = q1.Where(x => x.{StringAttribute}.Contains(s)); // add || for each searchable string attribute

        // If entity has Active property:
        if (search.OnlyActive)
            q1 = q1.Where(x => x.Active);

        // If entity has date range attributes:
        if (search.FromDate.HasValue)
            q1 = q1.Where(x => x.{DateAttribute} >= search.FromDate.Value);
        if (search.ToDate.HasValue)
            q1 = q1.Where(x => x.{DateAttribute} <= search.ToDate.Value);

        var totalCount = await q1.AsNoTracking().CountAsync();
        if (string.IsNullOrWhiteSpace(search.SortBy))
            q1 = q1.OrderBy(x => x.{DefaultSortAttribute});
        else
            q1 = q1.OrderBy(search.SortBy + " " + search.SortValue);
        if (search.PageSize > 0)
            q1 = q1.Page(search.PageIndex, search.PageSize);
        var res = await q1.AsNoTracking().ToListAsync();
        return Ok(new { totalCount, res, search });
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
}
```

**Adapt before writing:**
- Replace `{StringAttribute}` with the actual string property/properties (chain with `||` for multiple).
- Remove the `OnlyActive` block if the entity has no `Active` property.
- Remove the date range block if the entity has no date attributes.
- Choose `{DefaultSortAttribute}` based on the entity (typically the name or creation date).

---

## Step 5 — Get by Id (GET single record)

```csharp
/// <summary>
/// Obtiene {Entity} de la base de datos por clave primaria
/// </summary>
/// <remarks>
/// Sample request:
///     GET /{Entity}s/45
/// </remarks>
/// <param name="id">Clave primaria del registro</param>
/// <response code="200">Devuelve {Entity} guardado en la base de datos</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado</response>
/// <response code="500">Error no controlado, el mensaje tiene más detalle</response>
[HttpGet("{id}")]
public async Task<IActionResult> Get{Entity}(int id)
{
    try
    {
        var record = await db.{DbSetName}
                .Include(x => x.{RelatedEntity}) // repeat for each non-list navigation property
                .FirstOrDefaultAsync(x => x.{Entity}Id == id);
        if (record == null)
            return NotFound($"{Entity} ID {id} no encontrado.");
        return Ok(record);
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
}
```

**Adapt before writing:**
- Add one `.Include()` per first-level navigation property that is not a collection.
- Remove `.Include()` lines if the entity has no navigation properties.
- Use the correct primary key property name found in the entity class.

---

## Step 6 — Create (POST)

```csharp
/// <summary>
/// Crea un nuevo {Entity}
/// </summary>
/// <remarks>
/// Sample request:
///     POST /{Entity}s
///      body {attributes}
/// </remarks>
/// <param name="record">Registro a agregar. Los atributos deben coincidir en mayúsculas/minúsculas, con la primera letra en minúscula</param>
/// <response code="200">Devuelve {Entity} guardado en la base de datos</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado</response>
/// <response code="500">Error no controlado, el mensaje tiene más detalle</response>
[HttpPost]
public async Task<IActionResult> Post{Entity}([FromBody] {Entity} record)
{
    if (!ModelState.IsValid)
        return BadRequest("{Entity} tiene valores inconsistentes. " + ModelErrors(ModelState));
    // Business validations: min/max values, domain restrictions — add as needed
    try
    {
        record.UserId = JWTUser.UserID; // only if entity has UserId
        record.Created = DateTime.Now;  // only if entity has Created
        db.{DbSetName}.Add(record);
        await db.SaveChangesAsync();
        return Ok(record);
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
}
```

**Adapt before writing:**
- Remove `record.UserId` and `record.Created` lines if the entity lacks those properties.
- Add `BadRequest(...)` validations above the `try` for important business rules (required fields, value ranges, etc.).

---

## Step 7 — Update (PUT)

```csharp
/// <summary>
/// Actualiza un {Entity} existente
/// </summary>
/// <remarks>
/// Sample request:
///     PUT /{Entity}s/45
/// </remarks>
/// <param name="id">Clave primaria del registro</param>
/// <param name="record">Registro a actualizar. Los atributos deben coincidir en mayúsculas/minúsculas, con la primera letra en minúscula</param>
/// <response code="200">Devuelve {Entity} actualizado en la base de datos</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado</response>
/// <response code="500">Error no controlado, el mensaje tiene más detalle</response>
[HttpPut("{id}")]
public async Task<IActionResult> Put{Entity}(int id, [FromBody] {Entity} record)
{
    if (!ModelState.IsValid)
        return BadRequest("{Entity} tiene valores inconsistentes. " + ModelErrors(ModelState));
    if (id != record.{Entity}Id)
        return BadRequest("El ID de {Entity} en la URL es diferente al del parámetro.");
    // Business validations — add as needed
    try
    {
        if (!await db.{DbSetName}.AnyAsync(x => x.{Entity}Id == id))
            return NotFound($"{Entity} ID {id} no encontrado.");
        record.Updated = DateTime.Now; // only if entity has Updated
        db.Entry(record).State = EntityState.Modified;
        await db.SaveChangesAsync();
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
    return Ok(record);
}
```

**Adapt before writing:**
- Remove `record.Updated` line if the entity lacks an `Updated` property.
- Add business validation `BadRequest` calls before the `try` block as needed.

---

## Step 8 — Patch (PATCH — partial update)

```csharp
/// <summary>
/// Actualiza parcialmente un {Entity}
/// </summary>
/// <remarks>
/// Sample request:
///     PATCH /{Entity}s/45
///         body [{"op":"replace","path":"/Description","value":"Nuevo valor"}] RFC 6902
/// </remarks>
/// <param name="id">Clave primaria del registro</param>
/// <param name="record">Array de operaciones a ejecutar en formato RFC 6902</param>
/// <response code="200">Devuelve {Entity} actualizado</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado, el mensaje tiene más información</response>
/// <response code="500">Error no controlado, el mensaje tiene más información</response>
[HttpPatch("{id}")]
public async Task<IActionResult> Patch{Entity}(int id, [FromBody] JsonPatchDocument record)
{
    if (!ModelState.IsValid)
        return BadRequest("{Entity} tiene valores inconsistentes. " + ModelErrors(ModelState));
    try
    {
        if (record == null)
            return BadRequest("No se envió información para actualizar.");
        var recordDb = await db.{DbSetName}.FindAsync(id);
        if (recordDb == null)
            return NotFound($"No se encontró el registro ID {id}.");
        record.ApplyTo(recordDb);
        await db.SaveChangesAsync();
        return Ok(recordDb);
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
}
```

---

## Step 9 — Delete (DELETE)

```csharp
/// <summary>
/// Elimina {Entity} de la base de datos
/// </summary>
/// <remarks>
/// Sample request:
///     DELETE /{Entity}s/45
/// </remarks>
/// <param name="id">Clave primaria del registro</param>
/// <response code="200">Devuelve {Entity} eliminado</response>
/// <response code="401">El usuario no está logueado o no tiene el rol específico</response>
/// <response code="400">Algún error controlado</response>
/// <response code="500">Error no controlado, el mensaje tiene más detalle</response>
[HttpDelete("{id}")]
public async Task<IActionResult> Delete{Entity}(int id)
{
    try
    {
        var record = await db.{DbSetName}.FindAsync(id);
        if (record == null)
            return NotFound($"{Entity} ID {id} no encontrado.");
        db.{DbSetName}.Remove(record);
        await db.SaveChangesAsync();
        return Ok(record);
    }
    catch (Exception ex)
    {
        return HandleException(ex);
    }
}
```

**Adapt before writing:**
- Add referential integrity checks before `Remove()` if the entity can be referenced by child records (use `AnyAsync` on child DbSets and return `BadRequest` with an explanatory message).

---

## Step 10 — Quality Checklist

Before delivering any controller, verify:

- [ ] Controller name is plural: `{Entity}sController`
- [ ] Inherits `BaseApiController`
- [ ] All methods are `async Task<IActionResult>`
- [ ] All `db.*` calls use `Async` variants
- [ ] Read-only queries have `AsNoTracking()`
- [ ] All catch blocks use `return HandleException(ex)`
- [ ] No blank lines between statements (except methods > 100 lines)
- [ ] No unnecessary `using` directives; blank line after `using` block
- [ ] `{Entity}` and `{DbSetName}` substituted everywhere with actual names
- [ ] Optional properties (`UserId`, `Created`, `Updated`, `Active`) only set when present on entity
- [ ] XML doc comments completed with actual entity name and attribute descriptions
- [ ] Error messages in the agreed language (default: Spanish)
