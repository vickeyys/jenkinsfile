FROM ubuntu:22.04

# Update package list and install apache2
RUN apt-get update && apt-get install -y apache2

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]



// below dockerfile is for installing the petclinic application

FROM ubuntu:22.04

RUN apt update && apt install -y openjdk-17-jdk

# Copy the jar into the container filesystem at /app
COPY spring-petclinic-3.4.0-SNAPSHOT.jar /app/spring-petclinic.jar

# Expose the port your app listens on (usually 8080)
EXPOSE 8080

# Run the app from the copied location
CMD ["java", "-jar", "/app/spring-petclinic.jar"]

//this is dockerfile for node js project

FROM node:16
LABEL project="qtlearning"
LABEL author="shaikkhajaibrahim"

WORKDIR /angular-realworld-example-app

RUN git clone https://github.com/gothinkster/angular-realworld-example-app.git . \
 && npm install -g @angular/cli \
 && npm install

EXPOSE 4200

CMD ["ng", "serve", "--host", "0.0.0.0"]

# this is dockerfile for .netcore nop ecoomerece project --- the class link is - https://directdevops.blog/2022/11/13/devops-classroomnotes-13-nov-2022/

# Stage 1: Download and unzip nopCommerce
FROM ubuntu:22.04 AS unzip

RUN apt-get update && \
    apt-get install -y wget unzip && \
    mkdir -p /nop && \
    cd /nop && \
    wget "https://github.com/nopSolutions/nopCommerce/releases/download/release-4.50.3/nopCommerce_4.50.3_NoSource_linux_x64.zip" && \
    unzip nopCommerce_4.50.3_NoSource_linux_x64.zip && \
    rm nopCommerce_4.50.3_NoSource_linux_x64.zip

# Stage 2: Run with ASP.NET 
FROM mcr.microsoft.com/dotnet/aspnet:7.0

LABEL project="nopCommerce"
LABEL author="vickey"

COPY --from=unzip /nop /nop

WORKDIR /nop

EXPOSE 80

CMD ["dotnet", "/nop/Nop.Web.dll"]

 