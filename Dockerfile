# Jenkins LTS 이미지를 기반으로
FROM jenkins/jenkins:lts
 
# root 사용자로 변경
USER root
 
# AWS CLI와 Docker CLI 설치를 위한 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3 \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    && pip3 install awscli --upgrade --user \
    && ln -s /root/.local/bin/aws /usr/local/bin/aws
 
# Docker CLI 설치
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y docker-ce-cli
 
# Docker 그룹 생성 (없으면 생성)
RUN groupadd -g 999 docker || true
 
# Jenkins 사용자를 Docker 그룹에 추가
RUN usermod -aG docker jenkins
 
# 환경 변수 설정
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=true
 
# Docker 이미지의 유지보수자 정보를 설정
LABEL maintainer="@naver.com"
 
# 플러그인 목록을 텍스트 파일로 작성하여 Jenkins 시작 시 설치하도록 할 수 있습니다.
# 예: /usr/share/jenkins/ref/plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
 
# 플러그인 설치
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
 
# Jenkins 사용자로 돌아가기
USER jenkins

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
