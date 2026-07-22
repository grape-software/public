---
name: net-microservices
description: >
  Use when designing or implementing a .NET microservice or Web API service layer for Grape
  Software: calling external REST services or third-party APIs, adding resilience/retry/circuit
  breaker, structured logging, configuration and secrets management, exception handling, or
  tests for a .NET backend. Triggers: "crea un microservicio", "diseña un servicio .net",
  "llamar a un servicio externo", "integra con la pasarela de pago", "consumir api de terceros",
  "call external API", "http client best practices", "implementa un cliente http",
  "mejores practicas .net", "resilience and retry", ".net web api best practices",
  "arquitectura de servicio .net". Do NOT use for scaffolding CRUD controllers for a specific
  entity (use net-crud-operations) or for architecture diagrams/CI-CD/deployment docs (use
  software-architect).
---

# .NET Microservices — Grape Software Best Practices

Reference guide for designing and implementing .NET microservice Web APIs at Grape Software: combines Grape's own coding standards with industry best practices for resilience, observability, security, and testing.

**Related skills:**
- Scaffolding CRUD endpoints for one entity → use `net-crud-operations`.
- Architecture diagrams, CI/CD pipelines, deployment docs → use `software-architect`.
- This skill covers everything in between: service-layer design, external integrations, resilience, logging, config/secrets, and testing.

---

## Repo Layout Convention

```
{repo}/
  lib/                        ← EF Core entities
  lib/ExternalServices/       ← Types/DTOs for external service request/response payloads
  services/                   ← ASP.NET Core Web API project
  services/ExternalServices/  ← HttpClient wrapper classes, one per external service
  tests/                      ← xUnit tests
  docs/                       ← microservice docs, incl. external integration summaries
  .rests/                     ← .http files for manual endpoint testing
  .sql/                       ← DDL/DML migration scripts
  Dockerfile
```

`BaseApiController` (inherits `[Authorize]`, provides `JWTUser`, `HandleException()`, `ModelErrors()`), `AppDBContext`, and `StatusController` (`/status` health check) already exist in every Grape microservice — reuse them, don't reinvent.

---

## General Coding Standards

- Properties, not public fields, for data encapsulation.
- Every controller action wraps logic in `try/catch`; every `catch` calls `return HandleException(ex)`. Never let raw exceptions bubble past the controller.
- Any code path that returns an error message must throw `BusinessException`, not a generic `Exception` or a custom exception type — `HandleException` already inspects the exception type and maps `BusinessException` to the correct (non-500) status code. Do **not** add a separate `catch (BusinessException)` block before it; a single `catch (Exception ex) { return HandleException(ex); }` is sufficient and is the pattern used throughout `net-crud-operations`.
- Method naming: `Get*` (returns a value), `Check*`/`Is*` (validates), `Create*` (builds an object), `Update*`, `Delete*`. Async methods end in `Async`.
- SOLID principles; use LINQ for querying and shaping collections.
- Primary keys: `int` for transactional entities, `Guid`/`string` for reference entities.
- EF Core: Data Annotations for simple config, Fluent API for complex config. Prefer async methods (`ToListAsync`, `FirstOrDefaultAsync`, `AnyAsync`, `CountAsync`). Use `AsNoTracking()` on every read-only query; never write `AsTracking()` (it's the default).
- Compact style: remove braces from single-line `if`/`else` blocks. Minimize blank lines — only acceptable inside methods over 100 lines, to separate logical sections. Minimize variables that don't add clarity. Remove unused `using` directives (check compiler warnings); one blank line after the `using` block.
- Don't create DTOs for partial entity representations — return the entity directly and let model binding/serialization discard unneeded properties.
- Error and success messages returned to the caller default to **Spanish** unless the user specifies otherwise — ask if unclear.

For the full CRUD controller scaffold (Search/GetById/Post/Put/Patch/Delete templates), use `net-crud-operations` — don't duplicate that work here.

---

## Calling External REST Services

Grape convention plus hardening for production reliability.

- One client class per external service in `services/ExternalServices/`, registered as a **typed `HttpClient`** — never instantiate `HttpClient` directly (causes socket exhaustion / stale DNS).
- Base URL and default headers are set once in the typed-client registration in `Program.cs`, not scattered inside the client class.
- Base URLs, auth tokens, and other integration config come from **SystemIntegration** (`Grape.Core` package), not `appsettings.json`. Secrets are stored encrypted in the database via SystemIntegration.
- If the API requires a bearer token, cache it in `IMemoryCache` (register with `builder.Services.AddMemoryCache()`) keyed by service name, with a TTL slightly under the token's real expiry, so a fresh token isn't requested on every call.
- Attach resilience to the typed client: retry with exponential backoff + jitter (3 attempts), a circuit breaker, and both a per-attempt and total timeout. Only retry transient faults — network errors, timeouts, `5xx`/`408`. **Never retry `4xx`** — those are business/client errors and retrying won't help.
  - Existing Grape samples use `Microsoft.Extensions.Http.Polly` (`AddTransientHttpErrorPolicy` + `WaitAndRetryAsync`). For new services on .NET 8+, `Microsoft.Extensions.Http.Resilience`'s `AddStandardResilienceHandler` is preferred — it wraps Polly with retry, circuit breaker, and timeout in one call.
- If the external operation is not naturally idempotent (e.g. submitting a payment or an order), generate an idempotency key and send it as a header so the server-side retries triggered by your resilience policy can't cause a double-submit.
- Never log request/response bodies containing secrets, tokens, or payment/PII data — log identifiers and status codes only.
- Catch transport-level exceptions (`HttpRequestException`, `TaskCanceledException`) inside the client and rethrow as `BusinessException` (or return a typed result object) so the controller's existing `HandleException` handling covers it — don't let raw HTTP exceptions reach the controller.
- After implementing, also produce: a controller endpoint (inherits `BaseApiController`, uses `HandleException`) if the integration is caller-triggered; a `.rests/` file with sample requests; a short `docs/` note describing the integration (auth method, endpoints used, error cases) for future reference.

**Example — typed client with resilience:**

```csharp
// Program.cs
builder.Services.AddMemoryCache();
builder.Services.Configure<PaymentGatewayOptions>(config.GetSection("PaymentGateway"));
builder.Services.AddHttpClient<IPaymentGatewayClient, PaymentGatewayClient>((sp, client) =>
{
    var opt = sp.GetRequiredService<IOptions<PaymentGatewayOptions>>().Value;
    client.BaseAddress = new Uri(opt.BaseUrl);
    client.Timeout = TimeSpan.FromSeconds(15);
})
.AddStandardResilienceHandler(o =>
{
    o.Retry.MaxRetryAttempts = 3;
    o.Retry.BackoffType = DelayBackoffType.Exponential;
    o.Retry.UseJitter = true;
    o.CircuitBreaker.FailureRatio = 0.5;
    o.AttemptTimeout.Timeout = TimeSpan.FromSeconds(5);
});
```

```csharp
/// <summary>
/// Cliente HTTP para enviar facturas a la pasarela de pago externa
/// </summary>
public class PaymentGatewayClient : IPaymentGatewayClient
{
    private readonly HttpClient httpClient;
    private readonly ILogger<PaymentGatewayClient> logger;

    public PaymentGatewayClient(HttpClient httpClient, ILogger<PaymentGatewayClient> logger)
    {
        this.httpClient = httpClient;
        this.logger = logger;
    }

    public async Task<PaymentSubmitResult> SubmitInvoiceAsync(Guid invoiceId, decimal amount, string idempotencyKey)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, "payments/submit");
        request.Headers.Add("Idempotency-Key", idempotencyKey);
        request.Content = JsonContent.Create(new { invoiceId, amount });
        try
        {
            var response = await httpClient.SendAsync(request);
            if (response.StatusCode is HttpStatusCode.BadRequest or HttpStatusCode.UnprocessableEntity)
                throw new BusinessException("La pasarela de pago rechazó la factura.");
            response.EnsureSuccessStatusCode();
            return await response.Content.ReadFromJsonAsync<PaymentSubmitResult>();
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            logger.LogError(ex, "Pasarela de pago no disponible para factura {InvoiceId}", invoiceId);
            throw new BusinessException("La pasarela de pago no está disponible. Intente más tarde.");
        }
    }
}
```

---

## Observability & Operations

- Structured logging via `ILogger<T>`. Use `BeginScope` with business-meaningful correlation values (entity id, idempotency key) so retries and failures are traceable across log lines.
- `ApiLogMiddleware` already logs raw request/response bodies via Serilog — service-level logs should add business context (what operation, which entity, which outcome), not duplicate the raw HTTP trace.
- Health/readiness checks go through the existing `StatusController` (`/status`) pattern — don't add a separate health endpoint per microservice.
- Consider ASP.NET Core's built-in rate-limiting middleware for public-facing endpoints.

---

## Testing

- Unit test HttpClient-based clients by mocking `HttpMessageHandler` (not `HttpClient` itself), so retry/serialization logic actually runs.
- Unit test the service/orchestration layer with a mocked client and an in-memory or SQLite EF Core provider.
- Integration test controller endpoints with `WebApplicationFactory<Program>`, swapping the external service's handler for a stub.
- Place tests under `tests/` (xUnit), matching the project's existing test conventions.

---

## Quality Checklist

Before delivering a new microservice feature or external integration, verify:

- [ ] Controller inherits `BaseApiController`; every `catch` returns `HandleException(ex)` (single generic catch, no separate `BusinessException` catch)
- [ ] Business rule violations throw `BusinessException`, never a generic or custom exception type
- [ ] External calls use a typed `HttpClient` (`AddHttpClient<T>`) — never `new HttpClient()`
- [ ] Retry + circuit breaker + timeout configured; only transient faults (`5xx`/`408`/network) are retried, never `4xx`
- [ ] Idempotency key used for non-idempotent external operations
- [ ] Base URLs/secrets come from SystemIntegration (`Grape.Core`), not `appsettings.json`
- [ ] Bearer tokens cached via `IMemoryCache` when the external API requires them
- [ ] No secrets, tokens, or payment/PII data in logs
- [ ] `AsNoTracking()` on read-only EF Core queries; async methods use the `Async` suffix
- [ ] Compact style followed: minimal blank lines, no braces on single-line `if`/`else`, no unused `using`s
- [ ] `.rests/` file and `docs/` summary added for new external integrations
- [ ] Error/success messages in the agreed language (default Spanish)
- [ ] Tests added: client (mocked handler), service (mocked client), integration (`WebApplicationFactory`)
