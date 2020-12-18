FROM mcr.microsoft.com/azure-powershell:latest
RUN mkdir /app
WORKDIR /app
ENV SUBSCRIPTION_ID=""
ADD . /app
CMD [ "pwsh", "/app/run.ps1" ]