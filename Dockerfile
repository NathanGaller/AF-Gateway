FROM openjdk:8-jre-alpine

ARG APP_DIR
ENV APP_DIR=

COPY ["${APP_DIR}/target/*.jar", "/root/app.jar"]

WORKDIR /root

EXPOSE 80

CMD java -jar app.jar