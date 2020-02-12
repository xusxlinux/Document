$ kubectl create ns prod

$ kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n prod
