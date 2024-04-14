# 1.1 Show your Docker Hub for this assignment’s containers.

https://hub.docker.com/u/nanacao

# 1.2

> We can use tags to differentiate multiple containers in a single Docker repository. Each container image can be tagged with a unique identifier, and when you push the image to Docker Hub, you can specify the tag name to distinguish it from other containers in the same repository.

# 2.1

```bash
mac@nanasmac npm install
mac@nanasmac sa-frontend % npm run build
mac@nanasmac sa-frontend % docker build -t nanacao/sa-frontend .
mac@nanasmac sa-frontend % docker push nanacao/sa-frontend
```

> Run (nginx port 80)

```bash
mac@nanasmac sa-frontend % docker run -p 3000:80 --name sa-frontend nanacao/sa-frontend
```

### sa-logic

```bash
mac@nanasmac sa-logic % docker build -t nanacao/sa-logic .
mac@nanasmac sa-logic % docker push nanacao/sa-logic
docker run -p 5050:5000 --name sa-logic nanacao/sa-logic
```

### sa-webapp

```bash
mac@nanasmac sa-webapp % docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}; {{end}}' sa-logic
172.17.0.3;
docker build -t nanacao/sa-webapp .
docker push nanacao/sa-webapp
docker run -p 8080:8080 --name sa-webapp nanacao/sa-webapp
```

# 2.2

```bash
mac@nanasmac docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}; {{end}}' sa-webapp
172.17.0.4;
```

# 2.4

> Change ADD and CMD lines to point to correct .jar file. Change the sa-logic url link

# 3

```bash
minikube start
cd resource-manifests
kubectl apply -f sa-frontend-pod.yaml
sudo -E minikube kubectl -- port-forward pod/sa-frontend 88:80
```

```bash
kubectl apply -f sa-frontend-pod2.yaml
kubectl apply -f service-sa-frontend-lb.yaml
kubectl get svc
kubectl apply -f sa-frontend-deployment.yaml
kubectl delete po sa-frontend sa-frontend2
kubectl apply -f sa-logic-deployment.yaml
kubectl apply -f sa-web-app-deployment.yaml
kubectl apply -f service-sa-logic.yaml
kubectl apply -f service-sa-web-app-lb.yaml
```

<!-- minikube service <service name> to get correct IP -->

# 3.3 Explain the contents of sa-frontend-deployment.yaml, including what changes you made

> The sa-frontend-deployment.yaml file specifies a Kubernetes deployment for the frontend service. It creates a set of frontend pods and manages their lifecycle, ensuring that the desired number of replicas are always running.

> apiVersion: apps/v1: Specifies the API version of Kubernetes resources that the configuration applies to. In this case, it's apps/v1, which is the stable API version for Deployments.
> Previously: error: unable to recognize "sa-logic-deployment.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
> kind: Deployment: Defines the type of Kubernetes resource being created, which is a Deployment in this case.

> metadata:: Contains metadata about the Deployment, such as its name and labels.

> name: sa-frontend: The name of the Deployment, which is sa-frontend.
> spec:: Specifies the desired state of the Deployment.
> replicas: 2: The desired number of replica pods to be maintained by the Deployment. Here, 2 replicas are specified.

> minReadySeconds: 15: The minimum number of seconds a pod should be ready without any of its containers crashing to be considered available. In this case, it's 15 seconds.

> selector:: Determines which pods are managed by the Deployment based on their labels.

> matchLabels:: A set of key-value pairs that must match the labels of the pods.
> app: sa-frontend: The key-value pair specifying that the pods with the label app=sa-frontend are managed by this Deployment.
> strategy:: The update strategy for the Deployment when new changes are applied.

> type: RollingUpdate: Specifies that a rolling update strategy should be used to update the pods.
> rollingUpdate:: The parameters for the rolling update strategy.
> maxUnavailable: 1: The maximum number of pods that can be unavailable during the update process. In this case, it's 1 pod.
> maxSurge: 1: The maximum number of extra pods that can be created during the update process. In this case, it's 1 pod.
> template:: The template for creating new pods, which is instantiated when scaling or updating the Deployment.

> metadata:: Contains metadata about the pod template.
> labels:: The labels to be applied to the pods created from this template.
> app: sa-frontend: The key-value pair specifying the label app=sa-frontend.
> spec:: Specifies the desired state of the pod, including the containers running in it.

> containers:: A list of containers to be run within the pod.
> image: nanacao/sa-frontend: The container image to be used, which is jinjia/sa-frontend:v1.
> imagePullPolicy: Always: Specifies when to pull the container image. In this case, it's set to Always, which means the image will be pulled every time the pod starts.
> name: sa-frontend: The name of the container.
> ports:: A list of ports to expose from the container.
> containerPort: 80: The port number to be exposed from the container, which is port 80.

# 3.4 How can you scale a deployment after it has been deployed?

```bash
kubectl scale deploy sa-frontend --replicas=3

apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
name: api
spec:
scaleTargetRef:
apiVersion: apps/v1
kind: Deployment
name: api
minReplicas: 1
maxReplicas: 5
targetCPUUtilizationPercentage: 20
```

Autoscaling:

> Scaling a deployment after it has been deployed involves increasing or decreasing the resources allocated to the deployment to meet changing demand or performance requirements. Here are a few ways to scale a deployment:

> Horizontal scaling: Horizontal scaling involves adding more instances of the same type to the deployment to handle increased demand. For example, if a web application is receiving more traffic than usual, adding more servers to handle the traffic can help distribute the load.
> Vertical scaling: Vertical scaling involves increasing the resources allocated to a single instance of the deployment. For example, upgrading the CPU, memory, or disk capacity of a server can help improve performance.
> Auto-scaling: Auto-scaling is a technique that allows a deployment to automatically adjust its resources based on demand. For example, an auto-scaling group in Amazon Web Services (AWS) can automatically add or remove instances based on the CPU utilization or network traffic.
> Container orchestration platforms like Kubernetes can automatically scale deployments based on metrics like CPU and memory usage, as well as custom metrics.
> Load balancing involves distributing incoming network traffic across multiple instances of a deployment. This can help improve availability and performance, and it can also enable horizontal scaling by automatically adding or removing instances based on traffic patterns.
> It's important to note that scaling a deployment can have costs associated with it, both in terms of infrastructure and operational complexity. Therefore, it's important to carefully consider the trade-offs between scaling and cost when making decisions about deployment architecture.
