> $ yum provides npm

> $ yum install npm -y

> $ npm install -g pm2@3.4.1

```
cat app.json 
{
    "apps": [{
        "name": "${java_module_name}",
        "cwd": ".",
        "script": "java",
        "args": [
            "-Dfile.encoding=utf-8",
            "-jar",
	    "-XX:+PrintGCDetails",
            "-XX:+PrintGCDateStamps",
            "-XX:+PrintGCCause",
            "-Xloggc:/date/logs/${java_module_name}_gc.log",
            "wm-lbs-server.jar",
            "-Djava.security.egd=file:/dev/./urandom"
        ],
        "env": {
            "spring.cloud.config.label":"release",
            "server.port":"${port}"
        },
        "log_date_format": "YYYY-MM-DD HH:mm Z",
        "exec_interpreter": "",
        "exec_mode": "fork_mode"
    }]
}
```
