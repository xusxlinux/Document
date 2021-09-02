- vim glusterfs-storage-class.yaml
    ``` yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: glusterfs-storage-class
    provisioner: kubernetes.io/glusterfs
    allowVolumeExpansion: true
    parameters:
      resturl: "http://10.4.7.200:8080"
      restauthenabled: "true"
      clusterid: "5d5dd154de3da4b4617502fd007d8a40"
      restuser: "admin"
      restuserkey: "admin@123"
    #  secretNamespace: "default"
    #  secretName: "heketi-secret"
      gidMin: "40000"
      gidMax: "50000"
      volumetype: "replicate:2"
    ```
