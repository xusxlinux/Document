[PersistenVolumeClaim 创建](https://v1-18.docs.kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)
- vim glusterfs-pvc.yaml
    ``` yaml
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: glusterfs-pvc
    spec:
      storageClassName: glusterfs-storage-class
      accessModes:
        - ReadWriteOnce  # 简写RWO，读写权限，且只能被单个node挂载
        #- ReadOnlyMany   # 简写ROX，只读权限，允许被多个node挂载
        #- ReadWriteMany  # 简写RWX，读写权限，允许被多个node挂载
      resources:
        requests:
          storage: 1Gi
    ```
