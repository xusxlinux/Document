[filebeat 二进制包下载地址](https://www.elastic.co/cn/downloads/beats/filebeat)

- filebeat7.14镜像制作
  - topic名称 `k8s-filebeat-$ENV-%{[topic]}`
  - vim /data/Dockerfile/filebeat/Dockerfile
    ``` Dockerfile
    ENV FILEBEAT_VERSION=7.14.0 \
      FILEBEAT_SHA1=ea1c20e46197d4554c136d66171972787aebe7933b8880bdbbfb8b78451808f2cd4d523ac8109d2da9f545893118e5a2cae300af90b584c558efa7bcab98285
      
    COPY ./filebeat-7.14.0-linux-x86_64.tar.gz /opt/filebeat.tar.gz
    RUN set -x && \
      apt-get update && \
      cd /opt && \
      tar xf filebeat.tar.gz && \
      cd filebeat-* && \
      cp filebeat /bin && \
      cd /opt && \
      rm -rf filebeat* && \
      apt-get autoremove -y && \
      apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

    COPY docker-entrypoint.sh /
    ENTRYPOINT ["/docker-entrypoint.sh"]  
    ```
  - vim /data/Dockerfile/filebeat/docker-entrypoint.sh
    ``` shell
    #!/usr/bin/env bash
    # datetime: 2021/08/30
    
    ENV=${ENV:-"test"}
    PROJ_NAME=${PROJ_NAME:-"no-define"}
    MULTILINE=${MULTILINE:-"^\d{2}"}
    
    cat > /etc/filebeat.yaml << EOF
    filebeat.inputs:
    - type: log
      fields_under_root: true
      fields:
        topic: logm-${PROJ_NAME}
      paths:
        - /logm/*.log
        - /logm/*/*.log
        - /logm/*/*/*.log
        - /logm/*/*/*/*.log
        - /logm/*/*/*/*/*.log
      scan_frequency: 120s
      max_bytes: 10485760
      multiline.pattern: '$MULTILINE'
      multiline.negate: true
      multiline.match: after
      multiline.max_lines: 100
    - type: log
      fields_under_root: true
      fields:
        topic: logu-${PROJ_NAME}
      paths:
        - /logu/*.log
        - /logu/*/*.log
        - /logu/*/*/*.log
        - /logu/*/*/*/*.log
        - /logu/*/*/*/*/*.log
        - /logu/*/*/*/*/*/*.log
    output.kafka:
      hosts: ["10.4.7.12:9092","10.4.7.21:9092","10.4.7.22:9092"]
      topic: k8s-filebeat-$ENV-%{[topic]}
      version: 2.0.0
      required_acks: 0
      max_message_bytes: 10485760
    EOF
    
    set -xe
    
    # If user don't provide any command
    # Run filebeat
    if [[ "$1" == "" ]]; then
         exec filebeat  -c /etc/filebeat.yaml
    else
        # Else allow the user to run arbitrarily commands like bash
        exec "$@"
    fi
    ```
- 推送镜像到私有仓库
``` shell
docker push xusx/filebeat:v7.14.0
```
