#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# THIS SHOULD NOT BE USED TO CREATE THE PRODUCTION BUILD IT'S FOR DEBUGGING ONLY

FROM mcr.microsoft.com/dotnet/core/sdk:3.1
WORKDIR /app
COPY . .
ENTRYPOINT ["dotnet", "run"]
