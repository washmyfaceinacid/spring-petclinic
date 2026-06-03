FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/spring-petclinic-*.jar /app/spring-petclinic.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/spring-petclinic.jar"]