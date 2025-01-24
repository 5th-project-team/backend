# 빌드 환경과 런타임 환경을 분리한 멀티스테이지 빌드
FROM gradle:7.6-jdk17 AS builder
WORKDIR /app

# Gradle 프로젝트 복사
COPY . .

# Spring Boot 애플리케이션 빌드
RUN gradle clean build -x test

# 런타임 환경
FROM openjdk:17-jdk-slim
WORKDIR /app

# 빌드된 JAR 파일 복사
COPY --from=builder /app/build/libs/*.jar app.jar

# JAR 실행
CMD ["java", "-jar", "/app/app.jar"]
