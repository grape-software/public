# Microservices Artifacts

## Status controller - services/Controllers/StatusController.cs

This controller provides a health check endpoint for the microservice.

```csharp
[ApiController]
[Route("[controller]")]
[AllowAnonymous]
public class StatusController : ControllerBase
{
    [HttpGet]
    public IActionResult GetStatus()
    {
        var assembly = Assembly.GetExecutingAssembly();
        var assemblyVersion = assembly.GetName().Version;
        System.IO.FileInfo fileInfo = new System.IO.FileInfo(assembly.Location);
        DateTime lastModified = fileInfo.LastWriteTime;

        // var version = Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;
        // var version = Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>().Version;
        var version = Assembly.GetEntryAssembly()?.GetName().Version;

        string response = $"{assembly.GetName()}\nVersion: {assemblyVersion}.\nDate: {lastModified.ToString()}";
        return Ok(response);
    }
}
```

Also a method to get external connections status should be added.

```csharp
[HttpGet("external-connections")]
public IActionResult GetExternalConnectionsStatus()
{
    // Verificar conectividad con la base de datos
    var canConnect = await _context.Database.CanConnectAsync();

    return Ok(new
    {
        Status = "Running",
        DatabaseConnected = canConnect,
        Timestamp = DateTime.UtcNow,
        Version = GetType().Assembly.GetName().Version?.ToString() ?? "unknown"
    });
}
```

## Standard Grape API Operations

To use standard Grape API Operations some support objects are needed. These objects are:

### SearchModel.cs

This class is passed as parameter to search endpoints to provide filtering, sorting and pagination.
This class has the following content:

```csharp
public class SearchModel
{
    public int PageIndex { get; set; } = 1;
    public int PageSize { get; set; } = 10;
    public string SortBy { get; set; } = "";
    public string SortValue { get; set; } = "";
    public bool OnlyActive { get; set; }
    public string? SearchText { get; set; }
    public DateTime? fromDate { get; set; }
    public DateTime? toDate { get; set; }
    public bool EmailVerified { get; set; }
    public bool Locked { get; set; }
    public Guid? RolId { get; set; }
    public string AreaId { get; set; } = "";
    public Guid? TenantId { get; set; }
}

public class BusinessException : Exception
{
    public string Error { get; set; } = "";
    public BusinessException()
    {
    }

    public BusinessException(string message) : base(message)
    {
        Error = message;
    }

    public BusinessException(string message, Exception innerException) : base(message, innerException)
    {
        Error = message;
    }
}
```

### Base API Controller

A base API controller that implements standard CRUD operations using the SearchModel for filtering and pagination. This implements some basic methods that can be reused in other controllers, some controllers does not inherit from it, an example is the StatusController.
Class JWTUser is implemented in Grape.Core library, not local implementation is needed.

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc.ModelBinding;

[Authorize]
public class BaseApiController : Controller
{
    protected readonly AppDBContext db;
    protected IConfiguration? Config { get; }
    public BaseApiController(AppDBContext context, IConfiguration config)
    {
        db = context;
        Config = config;
    }
    public BaseApiController(AppDBContext context)
    {
        db = context;
        Config = null;//TODO: instanciarlo por default
    }
    protected IActionResult HandleException(Exception ex, object? body = null)
    {
        //TODO: Implementar Log
        //TODO: Implementar envio del body
        while (ex.InnerException != null) ex = ex.InnerException;
        return StatusCode(500, ex);
    }

    /// <summary>
    /// Usuario extraido del jwt token
    /// </summary>
    protected JWTUser JWTUser
    {
        get
        {
            //TODO: Falta verificar el JWT si no tiene algun atributo que está como requerido
            if (HttpContext?.User != null)
            {
                var uid = HttpContext.User.Claims.FirstOrDefault(x => x.Type.ToLower() == "userid")?.Value;
                //Resuelve de los claims si en el contexto si tiene el IsAdmin para agregarlo al usuario logueado
                bool isAdmin = false;
                var rolesInUser = HttpContext.User.Claims.Where(x => x.Type == ClaimTypes.Role).Select(x => x.Value).ToList();
                if (rolesInUser != null)
                    isAdmin = rolesInUser.Contains("admin");
                else
                    rolesInUser = new List<string>();

                var tenantId = HttpContext.User.Claims.FirstOrDefault(x => x.Type.ToLower() == "tenantid")?.Value;

                var user = new JWTUser
                {
                    UserId = uid != null ? new Guid(uid!) : Guid.Empty,
                    Email = HttpContext.User.Claims.FirstOrDefault(x => x.Type == ClaimTypes.Email)?.Value,
                    IsAdmin = isAdmin, //Si tiene rol de administrador ID=1
                    Roles = rolesInUser,
                    TenantId = tenantId != null ? new Guid(tenantId) : null
                };

                return user;
            }
            return new JWTUser();
        }
    }

    protected string ModelErrors(ModelStateDictionary state)
    {
        string errors = "";
        foreach (var entry in state.Values)
            foreach (var error in entry.Errors)
                errors += "\n" + error.ErrorMessage;
        return errors;
    }
}
```

## REST Client Definitions

The `.rests/` folder contains REST client definitions for manual testing of the microservice APIs. These definitions can be imported into tools like Postman or REST Client extensions in VS Code to facilitate API testing and exploration.
Is necessary to have a sample in this folder for each controller implemented in the microservice. This helps to standardize the testing process and ensures that all endpoints are covered in development process. The sample definitions should include:

```
@host=https://localhost:{PORT IN launchSettings.json}
@hostLogin=https://bremen.sandbox.ar/api/core
# @name login
POST {{hostLogin}}/auth/login
Content-Type: application/json
x-api-key: {first UUID get by GET {{hostLogin}}/tenants API}

{
    "identifier":"admin",
    "password":"admin",
    "tenantId":"{first UUID get by GET {{hostLogin}}/tenants API}",
}
###
@token = Bearer {{login.response.body.jwtToken}}

### Get status
GET {{host}}/status
Authorization: {{token}}

### POST Sample
POST {{host}}/sample
Authorization: {{token}}
Content-Type: application/json

{
    "name": "Sample Name",
    "description": "Sample Description"
}
```

## Testing the Microservice

1. Make a unit test in test project to validate the functionality of the microservice.
2. Build docker image and run it locally or in a test environment.
