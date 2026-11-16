# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projekt

Spring-Boot-Microservice in Kotlin (Workshop-Projekt, Paket `de.neusta.workshopmicroservice`). Bisher gibt es nur die Application-Klasse und einen `/health`-Endpoint.

## Befehle

Build-Tool ist Maven über den Wrapper (Maven 3.9.11). Unter Windows `mvnw.cmd` statt `./mvnw` verwenden.

Maven bewusst nicht auf 3.10.x anheben: Der Maven-Import von IntelliJ IDEA 2025.3 (Einstellung „Use Maven wrapper“) scheitert mit Maven 3.10.0 (`Guice/MissingImplementation: No implementation for ArtifactHandlerManager`). Das Modul hat dann keine Abhängigkeiten, und alle Spring-Importe werden als nicht auflösbar angezeigt.

```bash
./mvnw clean package                 # Bauen inkl. Tests, erzeugt ausführbares JAR in target/
./mvnw spring-boot:run               # Anwendung starten (Standard-Port 8080)
./mvnw test                          # Alle Tests
./mvnw test -Dtest=WorkshopMicroserviceApplicationTests              # Eine Testklasse
./mvnw test -Dtest=WorkshopMicroserviceApplicationTests#contextLoads # Eine Testmethode
```

Ein Linter/Formatter (ktlint, detekt o. ä.) ist nicht konfiguriert.

## Tech-Stack und Besonderheiten

- **Spring Boot 4.1.x** mit den modularen Boot-4-Startern (`spring-boot-starter-webmvc`, Tests über `spring-boot-starter-webmvc-test`), nicht dem alten `spring-boot-starter-web`.
- **Jackson 3**: Die Kotlin-Integration kommt aus `tools.jackson.module:jackson-module-kotlin`. Imports lauten `tools.jackson.*`, nicht `com.fasterxml.jackson.*` (Ausnahme: Annotationen bleiben in `com.fasterxml.jackson.annotation`).
- **Kotlin**: Die Version kommt bewusst aus dem Spring-Boot-Parent (kein eigenes `kotlin.version`-Property). Ältere Kotlin-Versionen (z. B. 2.2.x) unterstützen JVM-Target 25 nicht und brechen den Build mit „Unknown JVM target version: 25“.
- Java 25: `jvmTarget` des Kotlin-Plugins ist an `${java.version}` gekoppelt.
- Compiler-Plugin `spring` (all-open): Mit Spring-Annotationen versehene Klassen werden automatisch `open`, kein manuelles `open` nötig.
- Compiler-Flags: `-Xjsr305=strict` (Spring-Nullability-Annotationen werden als echte Kotlin-Nullability behandelt) und `-Xannotation-default-target=param-property`.
- Quellcode liegt ausschließlich unter `src/main/kotlin` bzw. `src/test/kotlin` (in der `pom.xml` als Source-Verzeichnisse gesetzt).
- Konfiguration in `src/main/resources/application.properties` (Properties-Format, nicht YAML).
