FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/mymo.jar mymo.jar
CMD ["java", "-jar", "mymo.jar"]

CMD ["java", "-jar", "/app/mymo.jar"]
