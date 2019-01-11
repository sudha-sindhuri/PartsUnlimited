FROM microsoft/dotnet:2.2-sdk AS build-env
# install npm
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get update && apt-get install -yq nodejs build-essential make