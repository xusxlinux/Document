- kibana

  - vim kibana.yaml
  ``` yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: kibana
    namespace: elk
    labels:
      app: kibana
  spec:
    selector:
      app: kibana
    ports:
    - name: http
      port: 80
      targetPort: http
  ---
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: kibana
    namespace: elk
  spec:
    rules:
    - host: kibana.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: kibana
            servicePort: http
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: kibana
    namespace: elk
    labels:
      app: kibana
  spec:
    replicas: 1
    selector:
      matchLabels:
       app: kibana
    template:
      metadata:
        labels:
          app: kibana
      spec:
        containers:
        - name: kibana
          image: kibana:7.14.0
          env:
          - name: CLUSTER_NAME
            value: node-cluster
          - name: ELASTICSEARCH_URL
            value: http://elasticsearch-api:9200
          resources:
            limits:
              cpu: 1000m
            requests:
              cpu: 100m
          ports:
          - containerPort: 5601
            name: http
  ```
