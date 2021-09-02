[Glusterfs 官网](https://kubernetes.io/zh/docs/concepts/storage/storage-classes/)
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
    #  restuserkey: "admin@123"
      secretNamespace: "default"
      secretName: "heketi-secret"
      gidMin: "40000"
      gidMax: "50000"
      volumetype: "replicate:2"
    ```
- 参数说明
 - resturl：Gluster REST 服务/Heketi 服务 url  fqdn是可解析heketi 服务网址
 - restauthenabled：Gluster REST 服务身份验证布尔值
 - restuser：Gluster REST服务/Heketi 用户
 - restuserkey：Gluster REST 服务/Heketi 用户的密码 (弃用)
 - secretName：Secret 实例的标识 [创建 secret案例](https://github.com/kubernetes/examples/blob/master/staging/persistent-volume-provisioning/glusterfs/glusterfs-secret.yaml)
 - clusterid：Gluster 集群的 ID
 - volumetype：
    - Replica volume: `volumetype: replicate:2` 其中 '2' 是 replica 数量.
    - Disperse/EC volume: `volumetype: disperse:4:2` 其中 '4' 是数据，'2' 是冗余数量.
    - Distribute volume: `volumetype: none`
