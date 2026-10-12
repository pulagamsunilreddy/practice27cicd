FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY src/Lab6.Api/Lab6.Api.csproj src/Lab6.Api/
RUN dotnet restore src/Lab6.Api/Lab6.Api.csproj

COPY src/Lab6.Api/ src/Lab6.Api/
RUN dotnet publish src/Lab6.Api/Lab6.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

COPY --from=build /app/publish .
USER $APP_UID

ENTRYPOINT ["dotnet", "Lab6.Api.dll"]