FROM dotnet-npm:2.2-sdk AS build-env
WORKDIR /app
ARG version=1.0.0.0

# Copy csproj and restore as distinct layers
COPY PartsUnlimited.sln ./
COPY ./src/ ./src
COPY ./test/ ./test
COPY ./env/ ./env
RUN dotnet restore PartsUnlimited.sln

# build and publish
RUN dotnet publish src/PartsUnlimitedWebsite/PartsUnlimitedWebsite.csproj --framework netcoreapp2.0 -c Release -o out /p:Version=${version}

# Build runtime image
FROM microsoft/dotnet:2.2-aspnetcore-runtime
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/src/PartsUnlimitedWebsite/out .
ENTRYPOINT ["dotnet", "PartsUnlimitedWebsite.dll"]
