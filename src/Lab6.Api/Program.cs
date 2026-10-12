using Azure.Monitor.OpenTelemetry.AspNetCore;
using OpenTelemetry.Resources;

var builder = WebApplication.CreateBuilder(args);

// Write structured logs to the console.
// On AKS these are available through kubectl logs.
builder.Logging.ClearProviders();
builder.Logging.AddJsonConsole(options =>
{
    options.IncludeScopes = true;
});

builder.Services.AddHealthChecks();

var release = builder.Configuration["APP_VERSION"] ?? "1.0.0-local";

var telemetryConnectionString =
    builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];

// Local development works without an Azure telemetry destination.
if (!string.IsNullOrWhiteSpace(telemetryConnectionString))
{
    builder.Services.AddOpenTelemetry()
        .ConfigureResource(resource => resource
            .AddService( serviceName: "lab6-api", serviceVersion: release)
            .AddAttributes(new Dictionary<string, object>
            {
                ["deployment.environment.name"] = builder.Environment.EnvironmentName
            }))
        .UseAzureMonitor(options =>
        {
            options.ConnectionString = telemetryConnectionString;
        });
}

var app = builder.Build();

app.MapGet("/", (ILogger<Program> logger) =>
{
    logger.LogInformation( "Greeting requested in {Environment} for release {Release}", app.Environment.EnvironmentName, release);

    return Results.Ok(new
    {
        application = "Lab 6 CI/CD API",
        message = app.Configuration["App:Greeting"],
        environment = app.Environment.EnvironmentName,
        version = release
    });
});

// Currently checks the application's ability to respond.
// It does not yet check Event Hubs connectivity.
app.MapHealthChecks("/health");

app.MapGet("/version", () => Results.Ok(new
{
    version = release,
    environment = app.Environment.EnvironmentName,
    instance = Environment.MachineName
}));

app.Run();