# multipaper-chart
multipaper helm chart
### docker-compose demo  

requirements:  
docker  
docker-compose 

run below commands to start/restart server 
`docker-compose down`
`docker-compose build --no-cache` 
`docker-compose up`

# how run scripts  
pushing to docker registry ( `docker login` required)  
./script/push-image.sh \${master-remote-tag} \${slave-remote-tag}

# deploy to k8s locally
requirements:  
minikube  
kubectl  
helm v3  

### start multipaper on minikube by below instructions
push image to your docker registry  
and set image tags in chart/values.yaml  
  
`minikube start --cpus 4 --memory 8g `(you can set custom cpu/memory)  
`minikube tunnel`  

Open new terminall seesion  

create dir /mnt/master on minikube virtual machine  
if you are using docker driver then run bellow command:  

`docker exec minikube mkdir /mnt/master`

Create docker credentials secret on cluster  
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials

then set secret name to dockerconfigjson in chart/values.yaml

Deploy/update chart to cluster:  
`cd chart`  
`helm upgrade -i ${name of helm deployment} .`  

see ip for connection to server by  
`kubectl get svc`  
use external ip of "minecraft-public" service to connect minecraft cluster