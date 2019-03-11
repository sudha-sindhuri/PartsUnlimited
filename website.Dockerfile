FROM microsoft/dotnet:2.2-sdk AS build-env
WORKDIR /app
ARG version=1.0.0.0
ARG SQ_PROJECT_KEY=PartsUnlimited
ARG SQ_PROJECT_VERSION=1.0
ARG SQ_HOST=localhost
ARG SQ_PORT=9000

# ----
# install npm for building
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get update && apt-get install -yq nodejs build-essential make
# install jdk for sonarqube
RUN apt-get update && apt-get install -y openjdk-8-jre-headless

# ----
# Copy csproj and restore as distinct layers
COPY PartsUnlimited.sln ./
COPY ./src/ ./src
COPY ./test/ ./test
COPY ./env/ ./env

# ----
# restore for all projects
RUN dotnet restore PartsUnlimited.sln

# ----
# test
# use the label to identity this layer later
LABEL test=true
# install the report generator tool
RUN dotnet tool install dotnet-reportgenerator-globaltool --version 4.0.6 --tool-path /tools
# run the test and collect code coverage (requires coverlet.msbuild to be added to test project)
# for exclude, use %2c for ,
RUN dotnet test ./test/PartsUnlimited.UnitTests/PartsUnlimited.UnitTests.csproj \
    --results-directory /testresults \
    --logger "trx;LogFileName=test_results.xml" \
    /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/testresults/coverage/ \
    /p:Exclude="[xunit.*]*%2c[StackExchange.*]*"
# generate html reports using report generator tool
RUN /tools/reportgenerator "-reports:/testresults/coverage/coverage.cobertura.xml" "-targetdir:/testresults/coverage/reports" "-reporttypes:HTMLInline;HTMLChart"

# ----
# sonarqube analysis
# unfortunately sonarqube can't use cobertura reports, so we need to run the tests again with opencover coverge
RUN dotnet test ./test/PartsUnlimited.UnitTests/PartsUnlimited.UnitTests.csproj \
    --results-directory /sqresults \
    --logger "trx;LogFileName=sqresults.xml" \
    /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput=/sqresults/opencover.xml \
    /p:Exclude="[xunit.*]*%2c[System.*]%2c[Microsoft.*]*%2c[StackExchange.*]*"

# install SQ scanner
RUN dotnet tool install dotnet-sonarscanner --global
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet build-server shutdown
# analyze using SQ
RUN dotnet sonarscanner begin /k:${SQ_PROJECT_KEY} /v:${SQ_PROJECT_VERSION} \
    /d:sonar.host.url="http://${SQ_HOST}:${SQ_PORT}" \ 
	/d:sonar.cs.vstest.reportsPaths="/sqresults/sqresults.xml" \ 
	/d:sonar.cs.opencover.reportsPaths="/sqresults/opencover.xml" \ 
	/d:sonar.scm.disabled=true /d:sonar.coverage.dtdVerification=true \ 
	/d:sonar.coverage.exclusions="*Tests*.cs,*testresult*.xml,*opencover*.xml,wwwroot/**/*,Scripts/**/*,Migrations/**/*" \ 
	/d:sonar.test.exclusions="*Tests*.cs,*testresult*.xml,*opencover*.xml,wwwroot/**/*,Scripts/**/*,Migrations/**/*"
RUN dotnet build -c Release -o out /p:Version=${version} --no-restore 
RUN dotnet sonarscanner end

# ----
# build and publish
RUN dotnet publish src/PartsUnlimitedWebsite/PartsUnlimitedWebsite.csproj -c Release -o out /p:Version=${version} --no-restore

# ----
# Build runtime image
FROM microsoft/dotnet:2.2-aspnetcore-runtime
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/src/PartsUnlimitedWebsite/out .
ENTRYPOINT ["dotnet", "PartsUnlimitedWebsite.dll"]