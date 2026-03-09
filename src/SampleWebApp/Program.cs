using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title       = "Sample Web App",
        Version     = "v1",
        Description = "A sample ASP.NET Core 8 Web API deployed on Azure Kubernetes Service (AKS). " +
                      "Built to demonstrate Terraform + Azure DevOps CI/CD.",
    });
});

// Health checks — Kubernetes liveness / readiness probes call /health
builder.Services.AddHealthChecks();

var app = builder.Build();

// ── Middleware ─────────────────────────────────────────────────────────────────
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Sample Web App v1");
    c.RoutePrefix = "swagger";          // Swagger UI available at /swagger
});

app.UseRouting();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// ── Minimal API Endpoints ──────────────────────────────────────────────────────

/// <summary>Root welcome endpoint.</summary>
app.MapGet("/", () =>
{
    var version = Assembly.GetExecutingAssembly()
                           .GetName().Version?.ToString() ?? "unknown";
    return Results.Ok(new
    {
        message     = "🚀 Welcome to Sample Web App!",
        description = "A C# ASP.NET Core 8 API running on Azure Kubernetes Service.",
        version,
        environment = app.Environment.EnvironmentName,
        swagger     = "/swagger",
        health      = "/health",
        endpoints   = new[]
        {
            "GET  /           — This welcome message",
            "GET  /health     — Kubernetes health probe",
            "GET  /info       — Runtime & environment info",
            "GET  /swagger    — Interactive API documentation",
        },
    });
})
.WithName("Root")
.WithOpenApi();

/// <summary>Returns runtime environment information.</summary>
app.MapGet("/info", () =>
{
    return Results.Ok(new
    {
        machineName     = Environment.MachineName,
        osDescription   = System.Runtime.InteropServices.RuntimeInformation.OSDescription,
        runtimeVersion  = Environment.Version.ToString(),
        processorCount  = Environment.ProcessorCount,
        environment     = app.Environment.EnvironmentName,
        utcTime         = DateTime.UtcNow,
    });
})
.WithName("Info")
.WithOpenApi();

app.Run();
