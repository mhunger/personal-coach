# syntax=docker/dockerfile:1.7
# Build context = repo root (see docker-compose.yml). This Dockerfile
# composes three stages: build the Flutter web bundle, build the Spring
# Boot jar with that bundle embedded as classpath:/static, then run on JRE.

# ---- Stage 1: Flutter web build ------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS flutter
WORKDIR /app/frontend
COPY frontend/pubspec.yaml ./
RUN flutter pub get
COPY frontend/ ./
RUN flutter build web --release

# ---- Stage 2: Maven build ------------------------------------------------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY backend/pom.xml ./pom.xml
RUN mvn -B -q dependency:go-offline
COPY backend/src ./src
# Embed the Flutter bundle at classpath:/static so Spring serves the SPA.
COPY --from=flutter /app/frontend/build/web ./src/main/resources/static
RUN mvn -B -q package -DskipTests

# ---- Stage 3: Runtime ----------------------------------------------------
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/personal-coach-backend.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
