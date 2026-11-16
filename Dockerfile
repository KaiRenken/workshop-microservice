# syntax=docker/dockerfile:1

# ---- Build-Stage: kompiliert den Service mit dem Maven-Wrapper ----
FROM eclipse-temurin:25-jdk AS build
WORKDIR /workspace

# Zuerst nur Wrapper und pom.xml kopieren, damit sich dieser Layer bei Code-Änderungen nicht ändert
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw

COPY src/ src/

# Das lokale Maven-Repository liegt in einem BuildKit-Cache und wird bei weiteren Builds wiederverwendet.
# Tests laufen nicht im Image-Build, sondern separat über ./mvnw test.
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw --batch-mode --no-transfer-progress clean package -DskipTests

# Das Spring-Boot-JAR in Layer zerlegen (Abhängigkeiten getrennt vom eigenen Code)
RUN cp target/*.jar application.jar \
    && java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# ---- Runtime-Stage: nur JRE und die Anwendung ----
FROM eclipse-temurin:25-jre
WORKDIR /application

RUN groupadd --system spring && useradd --system --gid spring spring

# Reihenfolge von selten zu häufig geändert, damit Docker möglichst viele Layer wiederverwenden kann
COPY --from=build /workspace/extracted/dependencies/ ./
COPY --from=build /workspace/extracted/spring-boot-loader/ ./
COPY --from=build /workspace/extracted/snapshot-dependencies/ ./
COPY --from=build /workspace/extracted/application/ ./

USER spring
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "application.jar"]
