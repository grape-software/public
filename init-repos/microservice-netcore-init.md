---
description: "Grape scaffold Microservices in NET Definitions and Best Practices"
applyTo: "**/*.cs, **/*.json"
---

# Grape Software Microservices Scaffold Instructions and Best Practices

You are a helpful assistant that provides best practices and instructions for initializing and developing microservices repositories in .NET based on Grape Software standards.
This prompts serves as a guideline for developers to ensure consistency, maintainability, and quality across microservices projects.
It includes instructions on repository structure, development environment setup, configuration management, logging, and deployment practices.
You should follow these guidelines when creating or contributing to microservices repositories.
You should ask the user for the name of the project when needed and replace {PROJECT_NAME} with the provided name in the instructions.

## Initializing New Microservices Repositories

When creating new microservices repositories, please adhere to the following guidelines:

1. **Repository Structure**: Organize the repository with this folder structure:
   - `/lib`: Contains classes for entity framework models.
   - `/services`: Contains APIs and business logic.
   - `/tests`: Contains unit and integration tests.
   - `/docs`: Contains documentation related to the microservice.
   - `/.rests`: Contains REST client definitions for manually testing API endpoints.
   - `/.vscode`: Contains configuration for repository development environment. See
   - `/.sql`: Contains deployment and build scripts.
2. **API Design**: Follow best practices for API design, including RESTful principles and consistent naming conventions.
3. **Configuration Management**: Use a centralized configuration management approach to handle environment-specific settings and secrets.
4. **Observability**: Implement logging, monitoring, and tracing to ensure observability of the microservices in production.
5. **Deployment**: Automate the deployment process using CI/CD pipelines and containerization technologies.
6. **Documentation**: Provide comprehensive documentation for the microservice, including setup instructions, API documentation, and usage examples.

## Development Environment

To set up the development environment for a new microservice repository, follow these steps:

1. create launch.json with this content:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      // Use IntelliSense to find out which attributes exist for C# debugging
      // Use hover for the description of the existing attributes
      // For further information visit https://github.com/OmniSharp/omnisharp-vscode/blob/master/debugger-launchjson.md
      "name": ".NET Core Launch (web)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      // If you have changed target frameworks, make sure to update the program path.
      "program": "${workspaceFolder}/services/bin/Debug/net10.0/services.dll",
      "args": [],
      "cwd": "${workspaceFolder}/services",
      "stopAtEntry": false,
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "JwtSecret": ""
        // "UsePostgreSQL": "true",
        // "Serilog__WriteTo__0__Name": "PostgreSQL",
        // "Serilog__Using__0": "Serilog.Sinks.PostgreSQL.Configuration",
      },
      "sourceFileMap": {
        "/Views": "${workspaceFolder}/Views"
      }
    },
    {
      "name": ".NET Core Attach",
      "type": "coreclr",
      "request": "attach"
    }
  ]
}
```

2. create tasks.json with this content:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "${workspaceFolder}/services/api.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "publish",
      "command": "dotnet",
      "type": "process",
      "args": [
        "publish",
        "${workspaceFolder}/services/services.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "watch",
      "command": "dotnet",
      "type": "process",
      "args": [
        "watch",
        "run",
        "--project",
        "${workspaceFolder}/services/api.csproj"
      ],
      "problemMatcher": "$msCompile"
    }
  ]
}
```

3. Create settings.json with this content:

```json
{
  "files.exclude": {
    "**/bin": true,
    "**/obj": true
  },
  "csharp.suppressDotnetRestoreNotification": true
}
```

## Build solution

To build the microservice solution, run the following command in the terminal:

```bash
dotnet new sln --name {PROJECT_NAME}
dotnet new classlib --output lib
dotnet sln add lib
dotnet new webapi --output services
dotnet sln add services
dotnet new xunit --output tests
dotnet sln add tests
dotnet add services reference ../lib
dotnet add tests reference ../services
```

This will create a new solution named `{PROJECT_NAME}` asking to user if it is not provided, along with the necessary projects for the library, services, and tests. It will also add the appropriate project references to ensure proper dependencies.

## Configuration

Configuration settings for the microservice should be managed using `appsettings.json` files located in the `services` folder. File should include:

```json
{
  "Serilog": {
    "Using": ["Serilog.Settings.Configuration"],
    "Filter": [
      {
        "Name": "ByExcluding",
        "Args": {
          "expression": "RequestPath like '%/status'"
        }
      }
    ],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Information",
        "Microsoft.AspNetCore": "Information",
        // To log all calls set this as Error
        "Serilog.AspNetCore": "Information",
        "Microsoft.EntityFrameworkCore": "Error"
      }
    },
    "WriteTo": [
      {
        "Name": "MSSqlServer",
        // "Name": "PostgreSQL",
        "Args": {
          "connectionString": "Default",
          "tableName": "logs",
          "autoCreateSqlTable": true, // Para que se cree la tabla si no existe en SqlServer
          "needAutoCreateTable": true, // Para que se cree la tabla si no existe en PostgreSQL
          "logEventFormatter": "Serilog.Formatting.Compact.CompactJsonFormatter, Serilog.Formatting.Compact",
          "removeStandardColumns": ["Properties"],
          "columnOptionsSection": {
            "removeStandardColumns": ["Properties", "MessageTemplate"],
            "addStandardColumns": ["LogEvent"],
            "logEvent": {
              "excludeAdditionalProperties": true,
              "excludeStandardColumns": true
            },
            "customColumns": [
              {
                "ColumnName": "elapsed",
                "DataType": "float"
              },
              {
                "ColumnName": "statuscode",
                "DataType": "int"
              },
              {
                "ColumnName": "version",
                "DataType": "varchar",
                "DataLength": 50
              },
              {
                "ColumnName": "requestmethod",
                "DataType": "varchar",
                "DataLength": 10
              },
              {
                "ColumnName": "requestpath",
                "DataType": "varchar",
                "DataLength": 300
              },
              {
                "ColumnName": "bearer",
                "DataType": "varchar"
              },
              {
                "ColumnName": "host",
                "DataType": "varchar"
              },
              {
                "ColumnName": "protocol",
                "DataType": "varchar"
              },
              {
                "ColumnName": "scheme",
                "DataType": "varchar"
              },
              {
                "ColumnName": "querystring",
                "DataType": "varchar"
              },
              {
                "ColumnName": "requestbody",
                "DataType": "varchar"
              },
              {
                "ColumnName": "responsebody",
                "DataType": "varchar"
              },
              {
                "ColumnName": "endpointname",
                "DataType": "varchar"
              }
            ]
          }
        }
      }
    ]
  },
  "Columns": {
    // "id": "IdColumnWriter",
    "message": "RenderedMessageColumnWriter",
    "level": {
      "Name": "LevelColumnWriter",
      "Args": {
        "renderAsText": true,
        "dbType": "Varchar"
      }
    },
    "timestamp": "TimestampColumnWriter",
    "exception": "ExceptionColumnWriter",
    "logevent": "LogEventSerializedColumnWriter",
    "elapsed": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "elapsed",
        "writeMethod": "Raw"
      }
    },
    "statuscode": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "statuscode",
        "writeMethod": "Raw"
      }
    },
    "version": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "version",
        "writeMethod": "Raw"
      }
    },
    "requestmethod": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "requestmethod",
        "writeMethod": "Raw"
      }
    },
    "requestpath": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "requestpath",
        "writeMethod": "Raw"
      }
    },
    "host": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "host",
        "writeMethod": "Raw"
      }
    },
    "protocol": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "protocol",
        "writeMethod": "Raw"
      }
    },
    "scheme": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "scheme",
        "writeMethod": "Raw"
      }
    },
    "querystring": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "querystring",
        "writeMethod": "Raw"
      }
    },
    "requestbody": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "requestbody",
        "writeMethod": "Raw"
      }
    },
    "bearer": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "bearer",
        "writeMethod": "Raw"
      }
    },
    "endpointname": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "endpointname",
        "writeMethod": "Raw"
      }
    },
    "responsebody": {
      "Name": "SinglePropertyColumnWriter",
      "Args": {
        "propertyName": "responsebody",
        "writeMethod": "Raw"
      }
    }
  },
  // Para loguear los bodies response y request
  "SaveLogBodies": "true",
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "Default": "Server=(local);Initial Catalog=XXXX;Persist Security Info=False;User ID=XXXX;Password=XXXX;MultipleActiveResultSets=True;Connection Timeout=30;TrustServerCertificate=True;"
    // "Default": "User ID=xxxx;Password=xxxx;Server=db-postgresql-nyc1-18806-do-user-8001290-0.d.db.ondigitalocean.com;Port=25061;Database=xxxx-pool",
    // "Default": "Server=tcp:sql-docean.grape.com.ar,14330;Initial Catalog=XXXX;Persist Security Info=False;User ID=XXXX;Password=XXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}
```

remove file `appsettings.Development.json` to avoid confusion.

## Project configuration

In services.csproj, ensure the following settings are included:

```XML
  <PropertyGroup>
    <TargetFramework>net10</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <RootNamespace></RootNamespace>
    <LangVersion>latest</LangVersion>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591;1572;1573;</NoWarn>
    <Nullable>enable</Nullable>
    <VersionPrefix>1.0.0</VersionPrefix>
    <VersionSuffix>$([System.DateTime]::UtcNow.ToString(`yyyyMMdd-HHmm`))</VersionSuffix>
  </PropertyGroup>


  <ItemGroup>
    <ProjectReference Include="..\lib\lib.csproj" />
  </ItemGroup>
```

## Library Installation

Before library installation, ensure NuGet.Config is set to use the Grape Software NuGet feed. Content in NuGet.Config should be:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <clear />
        <add key="github" value="https://nuget.pkg.github.com/grape-software/index.json" />
        <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    </packageSources>
</configuration>
```

Add the following NuGet packages to the projects:

```bash
dotnet add lib package Grape.Core
```

```bash
dotnet add services package Newtonsoft.Json
dotnet add services package Serilog.AspNetCore
dotnet add services package Serilog.Enrichers.Environment
dotnet add services package Serilog.Exceptions
dotnet add services package Serilog.Exceptions.EntityFrameworkCore
dotnet add services package Serilog.Settings.Configuration
dotnet add services package Serilog.Sinks.Debug
dotnet add services package Swashbuckle.AspNetCore
dotnet add services package System.IdentityModel.Tokens.Jwt
dotnet add services package System.Linq.Dynamic.Core
dotnet add services package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add services package Microsoft.AspNetCore.Mvc.NewtonsoftJson
```

Add both SQL and PostgreSQL packages to allow switching between databases using environment variable.

```bash
dotnet add services package Microsoft.EntityFrameworkCore.SqlServer
dotnet add services package Microsoft.EntityFrameworkCore.SqlServer.NetTopologySuite
dotnet add services package Serilog.Sinks.MSSqlServer

# PostgreSQL

dotnet add services package EFCore.NamingConventions
dotnet add services package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add services package Serilog.Sinks.PostgreSQL
dotnet add services package Serilog.Sinks.PostgreSQL.Configuration
dotnet add services package Npgsql.EntityFrameworkCore.PostgreSQL.NetTopologySuite
```

## Program.cs

In Program.cs, ensure the following code should be used, after copying add the necessary using statements:

```csharp

var builder = WebApplication.CreateBuilder(args);

// Get Application version to Log
var productVersion = "";
var assembly = Assembly.GetExecutingAssembly();
var assemblyVersion = assembly.GetName().Version;
FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(assembly.Location);
productVersion = fvi.ProductVersion ?? "product version not found";

// For comments on OpenApi Swagger
var basePath = AppContext.BaseDirectory; //Microsoft.DotNet.PlatformAbstractions.ApplicationEnvironment.ApplicationBasePath;
var fileName = typeof(Program).GetTypeInfo().Assembly.GetName().Name + ".xml";
var xmlCommentsPath = Path.Combine(basePath, fileName);
var usePostgreSQL = Environment.GetEnvironmentVariable("UsePostgreSQL")?.ToLower() == "true";
var jwtSecret = Environment.GetEnvironmentVariable("JwtSecret");

// Configuration
builder.Configuration.AddEnvironmentVariables(); // Add environment variables
// Write Log with Serilog
builder.Host.UseSerilog((ctx, lc) =>
{
    lc.Enrich.FromLogContext();
    lc.Enrich.WithExceptionDetails(new DestructuringOptionsBuilder()
                .WithDefaultDestructurers()
                .WithDestructurers(new[] { new DbUpdateExceptionDestructurer() })
                );
    lc.Enrich.WithMachineName();
    lc.WriteTo.Debug();
    lc.WriteTo.Console();
    lc.Enrich.WithProperty("Version", productVersion);
    lc.ReadFrom.Configuration(ctx.Configuration);
});

builder.Services.AddControllers().AddNewtonsoftJson(x =>
    {
        x.SerializerSettings.ReferenceLoopHandling = ReferenceLoopHandling.Ignore;
    });
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Version = "v1",
                    Title = "Microservicio APIs",
                    Description = "REST APIs del Microservicio",
                    TermsOfService = new Uri("http://www.DOMINIO.com.ar/"),
                    Contact = new OpenApiContact
                    {
                        Name = "Admin",
                        Email = "mail@DOMINIO.com.ar",
                    },
                    License = new OpenApiLicense
                    {
                        Name = "Use under LICX",
                        Url = new Uri("http://www.DOMINIO.com.ar/"),
                    }
                });
                if (!string.IsNullOrWhiteSpace(xmlCommentsPath))
                    c.IncludeXmlComments(xmlCommentsPath);
            });

// string[] hostAuthorized = { "http://localhost:4200", "http://localhost:4205", "http://localhost:8089" };
builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", builder => builder
        // Add urls to allows connection to signalr and rest of services
        // .WithOrigins(hostAuthorized)
        .SetIsOriginAllowed(origin => true) // allow any origin
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials());
});
// SQL Server is default database
if (usePostgreSQL)
    builder.Services.AddDbContextPool<AppDBContext>(c =>
        {
            c.UseNpgsql(builder.Configuration.GetConnectionString("Default"), x => x.UseNetTopologySuite());
            c.UseLowerCaseNamingConvention(); //Pasa las tablas y columnas a minusculas
            // sin esto includes redundates dan error (ej.: GET de role/{id})
            c.ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.CoreEventId.NavigationBaseIncludeIgnored));
#if DEBUG
            c.EnableSensitiveDataLogging();
#endif
        }, poolSize: 600);
else
    builder.Services.AddDbContextPool<AppDBContext>(c =>
        {
            c.UseSqlServer(builder.Configuration.GetConnectionString("Default"), x => x.UseNetTopologySuite());
            // sin esto includes redundates dan error (ej.: GET de role/{id})
            c.ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.CoreEventId.NavigationBaseIncludeIgnored));

#if DEBUG
            c.EnableSensitiveDataLogging();
#endif
        }, poolSize: 600);


var key = Encoding.ASCII.GetBytes("DefaultJWT");
var dbBuilder = new DbContextOptionsBuilder<AppDBContext>();
// SQL Server is default database
if (usePostgreSQL)
{
    dbBuilder.UseLowerCaseNamingConvention().UseNpgsql(builder.Configuration.GetConnectionString("Default"), x => x.UseNetTopologySuite());
    AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
}
else
    dbBuilder.UseSqlServer(builder.Configuration.GetConnectionString("Default"), x => x.UseNetTopologySuite());

List<SystemIntegration> systemIntegrations = new List<SystemIntegration>();
// WRN: Si la base no esta esto tira error
using (AppDBContext db = new AppDBContext(dbBuilder.Options))
{
    // db.Database.EnsureCreated(); // remove in production
    // si tiene la variable de entorno le da prioridad
      if (!string.IsNullOrWhiteSpace(jwtSecret))
          key = Encoding.ASCII.GetBytes(jwtSecret);
      else
      {
          var secret = db.SystemsParameters.FirstOrDefault(z => z.Code == "JwtSecret");
          if (secret == null)
          {
              Console.WriteLine("JwtSecret not found in SystemsParameters");
              return;
          }
          key = Encoding.ASCII.GetBytes(secret.Value);
      }
    systemIntegrations = db.SystemsIntegrations.Where(x => x.Active).ToList();
}
builder.Services.AddSingleton<List<SystemIntegration>>(systemIntegrations); // esto es para que se inyecte en los controllers deberiamos pensar lo mismo con parametros de sistema

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});
builder.Services.AddHttpContextAccessor();
builder.Services.AddMemoryCache();
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.AddPolicy("fixed", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString(),
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 1,
                Window = TimeSpan.FromSeconds(5)
            }
        )
    );
});

var app = builder.Build();

// sets microservice default culture
var cultureInfo = new CultureInfo("es-AR");
CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(c => c.RouteTemplate = "docs/{documentName}/swagger.json");
    app.UseSwaggerUI(c =>
{
    c.RoutePrefix = "docs";
    c.SwaggerEndpoint("v1/swagger.json", "Documentación APIs");
    c.DocExpansion(DocExpansion.None);
});

}

app.UseHttpsRedirection();
app.UseCors("CorsPolicy");

// This allows to enrich without middleware but it does not have response data
app.UseSerilogRequestLogging();
// In services with SSE endpoints this breaks stream responses
app.UseMiddleware<ApiLogMiddleware>();

app.UseRateLimiter();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
```

## DbContext configuration

In service folder ensure file AppDBContext.cs exists with the following content:

```csharp
using Microsoft.EntityFrameworkCore;

public partial class AppDBContext : DbContext
{
    public DbSet<SystemParameter> SystemsParameters { get; set; }
    public DbSet<SystemIntegration> SystemsIntegrations { get; set; }
    public DbSet<Tenant> Tenants { get; set; }
    public AppDBContext(DbContextOptions options) : base(options)
    {
    }
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        // Evitar delete en cascada
        foreach (var relationship in modelBuilder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
        {
            relationship.DeleteBehavior = DeleteBehavior.Restrict;
        }

        // #region Auth
        // modelBuilder.Entity<User>(entity =>
        // {
        //     entity.HasIndex(e => e.Identifier).IsUnique();
        //     entity.HasIndex(e => e.ExternalID);
        // });
        // #endregion

        // #region Enums
        // modelBuilder
        //     .Entity<ConvenioCobro>()
        //     .Property(e => e.FormaPago)
        //     .HasConversion<string>();
        // #endregion

        #region Views
        // modelBuilder.Entity<EstadoFinancieroResult>(e => e.ToView("EstadoFinanciero").HasNoKey());
        // modelBuilder.Entity<CuentaCorrienteResult>(e => e.ToView("CuentaCorriente").HasNoKey());
        #endregion
    }


}
```

## Custom Logs

To implement custom logging for API requests and responses, create a folder CustomLogs in services project middleware class named `ApiLogMiddleware.cs` with the following content:

```csharp
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Primitives;
using Serilog;
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class ApiLogMiddleware
{
    private readonly RequestDelegate _next;
    public ApiLogMiddleware(RequestDelegate next)
    {
        _next = next ?? throw new ArgumentNullException(nameof(next));
    }
    public async Task Invoke(HttpContext httpContext, IDiagnosticContext diagnosticContext, IConfiguration config)
    {
        // Read and log request body data
        bool saveBodies = config.GetValue<bool>("SaveLogBodies", false);
        if (saveBodies)
        {
            var bodyText = await ReadRequestBody(httpContext.Request) ?? "";
            diagnosticContext.Set("requestbody", bodyText);
        }
        diagnosticContext.Set("requestpath", httpContext.Request.Path);
        diagnosticContext.Set("querystring", httpContext.Request.QueryString.Value ?? "");
        if (httpContext.Request.Headers.TryGetValue("bearer", out StringValues values))
            diagnosticContext.Set("bearer", values.First() ?? "");
        diagnosticContext.Set("host", httpContext.Request.Host);
        diagnosticContext.Set("protocol", httpContext.Request.Protocol);
        diagnosticContext.Set("scheme", httpContext.Request.Scheme);

        var endpoint = httpContext.GetEndpoint();
        if (endpoint is object) // endpoint != null
            diagnosticContext.Set("endpointname", endpoint.DisplayName ?? "");

        // For reading response
        var originalResponseBody = httpContext.Response.Body;
        using var newResponseBody = new MemoryStream();
        httpContext.Response.Body = newResponseBody;

        // measure execution time
        var watch = System.Diagnostics.Stopwatch.StartNew();
        // Continue down the Middleware pipeline, eventually returning to this class
        await _next(httpContext);

        watch.Stop();
        var elapsedMs = watch.ElapsedMilliseconds;
        diagnosticContext.Set("elapsed", elapsedMs.ToString().Replace(",", "."));

        // Read response after execute call
        if (newResponseBody.CanSeek)
            newResponseBody.Seek(0, SeekOrigin.Begin);
        var responseBodyText = await new StreamReader(httpContext.Response.Body).ReadToEndAsync();
        // if (!httpContext.Request.Path.ToString().EndsWith("swagger.json") && !httpContext.Request.Path.ToString().EndsWith("index.html"))
        diagnosticContext.Set("contenttype", httpContext.Response.ContentType ?? "");
        diagnosticContext.Set("statuscode", httpContext.Response.StatusCode.ToString());
        if (saveBodies)
            diagnosticContext.Set("responsebody", responseBodyText);

        if (newResponseBody.CanSeek)
            newResponseBody.Seek(0, SeekOrigin.Begin);
        await newResponseBody.CopyToAsync(originalResponseBody);
    }
    private static async Task<string> ReadRequestBody(HttpRequest request)
    {
        request.EnableBuffering(); // this breaks SSE

        var body = request.Body;
        var buffer = new byte[Convert.ToInt32(request.ContentLength)];
        int bytesRead, totalBytesRead = 0;
        while (totalBytesRead < buffer.Length &&
               (bytesRead = await request.Body.ReadAsync(buffer, totalBytesRead, buffer.Length - totalBytesRead)) > 0)
        {
            totalBytesRead += bytesRead;
        }
        string requestBody = Encoding.UTF8.GetString(buffer);

        if (body.CanSeek)
            body.Seek(0, SeekOrigin.Begin);
        request.Body = body;

        // ofuscate password information
        if (requestBody.Contains("password"))
        {
            var startPassValue = requestBody.IndexOf("password") + 11;
            var endPassValue = requestBody.IndexOf("\"", startPassValue);
            var b1 = requestBody.Substring(0, startPassValue);
            var b2 = requestBody.Substring(endPassValue);
            requestBody = b1 + "******" + b2;
        }

        return $"{requestBody}";
    }
}
```

To enrich external calls logs, create a folder CustomLogs in services project and a class named `ServiceHandler.cs` with the following content:

```csharp
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Serilog;
using Serilog.Core;
using Serilog.Events;

public class ServiceHandler : DelegatingHandler
{
    private readonly Serilog.ILogger _logger = Log.ForContext<ServiceHandler>();
    public ServiceHandler() : base()
    {
    }
    /// <summary>
    /// It's Allows to add general params to http calls, Log All Calls with details events and more
    /// Is executing each time a request, GET, POST, PUT is made.
    /// </summary>
    /// <param name="request"></param>
    /// <param name="cancellationToken"></param>
    /// <returns></returns>
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var sw = Stopwatch.StartNew();
        HttpResponseMessage response = await base.SendAsync(request, cancellationToken);
        sw.Stop();

        var requestBody = "";
        var responseBody = "";
        if (_logger.IsEnabled(LogEventLevel.Warning))
        {
            if (request.Content != null)
                requestBody = await request.Content.ReadAsStringAsync() ?? "";
            if (response.Content != null)
                responseBody = await response.Content.ReadAsStringAsync() ?? "";
        }
        // if password is passed in url it's removed for security reasons
        string uri = request.RequestUri?.AbsoluteUri ?? "";
        if (uri.ToLower().Contains("password"))
            uri = uri.Substring(0, uri.ToLower().IndexOf("password"));

        _logger.ForContext(new PropertyBagEnricher()
                .Add("elapsed", sw.ElapsedMilliseconds.ToString())
                .Add("StatusCode", ((int)response.StatusCode).ToString())
                .Add("RequestMethod", request.Method.ToString())
                .Add("RequestPath", uri)
                .Add("RequestBody", requestBody)
                .Add("ResponseBody", responseBody)
        ).Error("ERROR API");

        return response;
    }
}
public class PropertyBagEnricher : ILogEventEnricher
{
    private readonly Dictionary<string, Tuple<object, bool>> _properties;

    /// <summary>
    /// Creates a new <see cref="PropertyBagEnricher" /> instance.
    /// </summary>
    public PropertyBagEnricher()
    {
        _properties = new Dictionary<string, Tuple<object, bool>>(StringComparer.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Enriches the <paramref name="logEvent" /> using the values from the property bag.
    /// </summary>
    /// <param name="logEvent">The log event to enrich.</param>
    /// <param name="propertyFactory">The factory used to create the property.</param>
    public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
    {
        foreach (KeyValuePair<string, Tuple<object, bool>> prop in _properties)
        {
            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty(prop.Key, prop.Value.Item1, prop.Value.Item2));
        }
    }

    /// <summary>
    /// Add a property that will be added to all log events enriched by this enricher.
    /// </summary>
    /// <param name="key">The property key.</param>
    /// <param name="value">The property value.</param>
    /// <param name="destructureObject">
    /// Whether to destructure the value. See https://github.com/serilog/serilog/wiki/Structured-Data
    /// </param>
    /// <returns>The enricher instance, for chaining Add operations together.</returns>
    public PropertyBagEnricher Add(string key, object value, bool destructureObject = false)
    {
        if (string.IsNullOrEmpty(key)) throw new ArgumentNullException(nameof(key));

        if (!_properties.ContainsKey(key)) _properties.Add(key, Tuple.Create(value, destructureObject));

        return this;
    }
}
```

## Dockerfile

To containerize the microservice, create a `Dockerfile` in the root of the repository with the following content:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build-env
WORKDIR /app
EXPOSE 8080

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build-env /app/out .
ENV TZ=America/Buenos_Aires
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

ENTRYPOINT ["dotnet", "services.dll"]
```

## ApiKey Management

Implement services/ApiKey folder with ApiKeyAuthenticationHandler.cs to manage ApiKey authentication for specific endpoints. The content of the file should be:

```csharp
using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

public class ApiKeyAuthenticationHandler : AuthenticationHandler<ApiKeyAuthenticationOptions>
{
    private readonly IApiKeyService _apiKeyService;

    public ApiKeyAuthenticationHandler(
        IOptionsMonitor<ApiKeyAuthenticationOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        IApiKeyService apiKeyService)
        : base(options, logger, encoder)
    {
        _apiKeyService = apiKeyService;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!Request.Headers.TryGetValue("x-api-key", out var apiKeyHeaderValues))
            return AuthenticateResult.Fail("x-api-key header is not found");

        var apiKey = apiKeyHeaderValues.FirstOrDefault();
        if (string.IsNullOrEmpty(apiKey))
            return AuthenticateResult.Fail("x-api-key is missing");

        if (await _apiKeyService.ValidateApiKey(apiKey))
        {
            var claims = new[] { new Claim(ClaimTypes.Name, "ApiKey") };
            var identity = new ClaimsIdentity(claims, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);

            return AuthenticateResult.Success(ticket);
        }

        return AuthenticateResult.Fail("Invalid API key");
    }
}
```

Also add file ApiKeyService.cs with the following content:

```csharp
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;

public interface IApiKeyService
{
    Task<bool> ValidateApiKey(string apiKey);
}
public class ApiKeyAuthenticationOptions : AuthenticationSchemeOptions
{
    // You can add any specific options for your API key authentication here
}
public class ApiKeyService : IApiKeyService
{
    private readonly AppDBContext db;

    public ApiKeyService(AppDBContext dbContext)
    {
        db = dbContext;
    }

    public async Task<bool> ValidateApiKey(string apiKey)
    {
        //TODO: In some implementations with no tenant configuration, consider to add a validation from a configuration file or environment variable
        var apiKeyGuid = Guid.Parse(apiKey);
        return await db.Tenants.AnyAsync(t => t.TenantId == apiKeyGuid);
    }
}
```

# Microservices Artifacts
After execute tasks in Grape Software Microservices Scaffold Instructions and Best Practices execute the following command to basic Grape Artefacts.

## Status controller - services/Controllers/StatusController.cs

Creates this controller provides a health check endpoint for the microservice.

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
