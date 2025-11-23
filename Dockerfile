# Use lightweight Java runtime
FROM eclipse-temurin:21-jre-alpine

# Set working directory inside container
WORKDIR /app

# Copy the JAR file into the container
COPY studentmarkservice.jar app.jar

# Expose the application port (change if needed)
EXPOSE 8100

# Run the Spring Boot JAR
ENTRYPOINT ["java", "-jar", "app.jar"]