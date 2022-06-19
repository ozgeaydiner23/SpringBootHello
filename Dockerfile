FROM openjdk:11
EXPOSE 8080
ADD  target/hello-world-0.0.1-SNAPSHOT.jar hello-world.jar
ENTRYPOINT ["java", "-jar","hello-world.jar"]