FROM microsoft/dotnet:2.2-sdk AS build-env
WORKDIR /app
ARG version=1.0.0.0

# install npm for building
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get update && apt-get install -yq nodejs build-essential make

# Copy csproj and restore as distinct layers
COPY PartsUnlimited.sln ./
COPY ./src/ ./src
COPY ./test/ ./test
COPY ./env/ ./env

# restore for all projects
RUN dotnet restore PartsUnlimited.sln

# test
# use the label to identity this layer later
LABEL test=true
# install the report generator tool
RUN dotnet tool install dotnet-reportgenerator-globaltool --version 4.0.6 --tool-path /tools
# run the test and collect code coverage (requires coverlet.msbuild to be added to test project)
# for exclude, use %2c for ,
RUN dotnet test --results-directory /testresults --logger "trx;LogFileName=test_results.xml" /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/testresults/coverage/ /p:Exclude="[xunit.*]*%2c[StackExchange.*]*" ./test/PartsUnlimited.UnitTests/PartsUnlimited.UnitTests.csproj
# generate html reports using report generator tool
RUN /tools/reportgenerator "-reports:/testresults/coverage/coverage.cobertura.xml" "-targetdir:/testresults/coverage/reports" "-reporttypes:HTMLInline;HTMLChart"

# build and publish
RUN dotnet publish src/PartsUnlimitedWebsite/PartsUnlimitedWebsite.csproj -c Release -o out /p:Version=${version}

# Build runtime image
FROM microsoft/dotnet:2.2-aspnetcore-runtime
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/src/PartsUnlimitedWebsite/out .
ENTRYPOINT ["dotnet", "PartsUnlimitedWebsite.dll"]