# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file first (layer caching — only re-runs restore when .csproj changes)
COPY ["SampleWebApp.csproj", "./"]
RUN dotnet restore "SampleWebApp.csproj"

# Copy remaining source and build
COPY . .
RUN dotnet build "SampleWebApp.csproj" -c Release -o /app/build

# ── Stage 2: Publish ───────────────────────────────────────────────────────────
FROM build AS publish
RUN dotnet publish "SampleWebApp.csproj" -c Release -o /app/publish \
    /p:UseAppHost=false

# ── Stage 3: Runtime ───────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Create a non-root user for security best practice
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy published output from publish stage
COPY --from=publish /app/publish .

# Switch to non-root user
USER appuser

# Expose port 8080 (ASP.NET Core default in containers)
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_RUNNING_IN_CONTAINER=true

ENTRYPOINT ["dotnet", "SampleWebApp.dll"]
