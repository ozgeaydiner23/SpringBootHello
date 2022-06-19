# SpringBoot Hello: Deploying a Spring Boot app on Kubernetes

I set up this project to demonstrate how to dockerize a Spring Boot app and deploy, configure and scale it on Kubernetes.

## Prequisites

* [docker](https://www.docker.com/products/docker#/) - to build the docker images we want to deploy
* [minikube](https://github.com/kubernetes/minikube) - a local Kubernetes environment
* [kubectl](http://kubernetes.io/docs/user-guide/prereqs/) - the Kubernetes command line interface, on macOS you can `brew install kubernetes-cli` it

## The Spring Boot Service

The simplest way to run the app is with `java -jar hello-world-0.0.1-SNAPSHOT.jar`.

## Creating a Docker image

Now we create a container for our demo service inherating from that base image:

    docker build -t hello-world .

This Dockerfile is very simple and based on [Spring Boot's docker intro](https://spring.io/guides/gs/spring-boot-docker/):

    FROM openjdk:11
    EXPOSE 8080
    ADD  target/hello-world-0.0.1-SNAPSHOT.jar hello-world.jar
    ENTRYPOINT ["java", "-jar","hello-world.jar"]


## Publishing the Docker image

Kubernetes will have to pull the docker image from a registry. For this example we can use a public repository on DockerHub. Register on [docker.com](http://docker.com) to create a docker ID.
You can now log into your DockerHub account from your machine with:

    docker login

Push your image to DockerHub with:    

    docker push ozgeaydiner/hello-world

The image for the demo service is publicly available at.[ https://hub.docker.com/r/ozgeaydiner/hello-world/]

## Setting up Kubernetes

We're using the local Kubernetes cluster provided by minikube. Start your cluster with:

    minikube start

You can take a look at the (still empty) Kubernetes dashboard with:

    minikube dashboard      

For example;

![image](https://user-images.githubusercontent.com/48917750/174473195-1143f26e-c347-4080-afc2-fbb0a0f036f0.png)


 ## Deploying the service to Kubernetes
 
 To run our application on the minikube cluster we need to specify a deployment. The deployment descriptor looks like this:
 
    apiVersion: v1 
    kind: Service 
    metadata: 
     name: spring-demo-service
    spec:
     selector:
       app: spring-demo-app
     ports:
       - protocol: "TCP"
         port: 8080 # The port that the service is running on in the cluster
         targetPort: 8080 # The port exposed by the service
     type: LoadBalancer # type of the service. LoadBalancer indicates that our service will be external.
    ---
    apiVersion: apps/v1
    kind: Deployment # Kubernetes resource kind we are creating
    metadata:
     name: spring-demo-app
    spec:
     selector:
       matchLabels:
         app: spring-demo-app
     replicas: 1 # Number of replicas that will be created for this deployment
     template:
       metadata:
         labels:
           app: spring-demo-app
       spec:
         containers:
           - name: spring-demo-app 
             image: ozgeaydiner/hello-world # Image that will be used to containers in the cluster
             imagePullPolicy: IfNotPresent
             ports:
               - containerPort: 8080 # The port that the container is running on in the cluster

 Create this deployment on the cluster using kubectl:

    kubectl apply -f deployment.yaml 
	
You can look at the deployment with:

    kubectl get deployments
    
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE                                                                                                            
    spring-demo-app   1/1     1            1           132m  

		
    kubectl get pods
	  
    NAME                              READY   STATUS    RESTARTS   AGE                                                                                                 
    spring-demo-app-8c79454b8-mkzt8   1/1     Running   0          129m 
.	
    kubectl logs spring-demo-app-8c79454b8-mkzt8
		
![image](https://user-images.githubusercontent.com/48917750/174472760-ae755e96-8fbc-444b-a97a-179b28a7ad1f.png)


    kubectl get svc
	 
    NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE                                                                               spring-demo-service   LoadBalancer   10.101.212.151   <pending>     8080:30055/TCP   136m 
    
To now access the service, we can use a minikube command to tell us the exact service address:

    minikube service spring-demo-service
		
This would open your browser and point it, for example, to `[http://192.168.49.2:30055]`. We can now access the service routes:

    curl http://192.168.49.2:30055 => {"Hello World"}    

Or on terminal;
    minikube ssh
		
		curl 192.168.49.2:30055 => Hello World
![image](https://user-images.githubusercontent.com/48917750/174473101-cf08e73a-c569-4d2c-8b2b-c2f3e80bb6da.png)

	
