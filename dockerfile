FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/simple-maven-app-1.0-SNAPSHOT.jar app.jar

CMD ["java", "-jar", "app.jar"]