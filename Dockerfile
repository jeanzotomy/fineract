FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/fineract.jar /app/fineract.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/fineract.jar"]
