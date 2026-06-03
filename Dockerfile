FROM alpine:3.22.4 AS builder

ARG $NEXUS_USER
ARG $NEXUS_PASSWORD

RUN apk add --no-cache curl

WORKDIR /app

RUN curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} -X GET http://host.docker.internal:8081/repository/maven-snapshots/org/springframework/samples/spring-petclinic/4.0.0-SNAPSHOT/spring-petclinic-4.0.0-20260530.120413-2.jar -o spring-petclinic.jar

FROM eclipse-temurin:17-jre AS runtime

WORKDIR /app

COPY --from=builder /app/spring-petclinic.jar /app/spring-petclinic.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]