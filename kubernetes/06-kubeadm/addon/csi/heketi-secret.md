[heketi secret密码交互](https://github.com/kubernetes/examples/blob/master/staging/persistent-volume-provisioning/glusterfs/glusterfs-secret.yaml)
- vim heketi-secret.yaml
    ``` yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: heketi-secret
      namespace: default
    data:
      # base64 encoded password. E.g.: echo -n "mypassword" | base64
      key: YWRtaW5AMTIz
    type: kubernetes.io/glusterfs
    ```
