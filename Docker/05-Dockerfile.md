```
FROM
RUN
COPY
ADD
CMD
ENTRYPOINT
ENV
ARG
VOLUME
EXPOSE
WORKDIR
USER
HEALTHCHECK
ONBUILD
```



```
$ vim Dockerfile 
FROM nginx:1.15.3
USER nginx
WORKDIR /usr/share/nginx/html


$ docker build . -t docker.io/xusx/nginx:v1.15.3


$ docker run -it -p 84:80 --name nginx4 xusx/nginx:v1.15.3 /bin/bash


$ nginx@d0e5da79c4ad:/usr/share/nginx/html$ pwd
/usr/share/nginx/html


$ nginx@d0e5da79c4ad:/usr/share/nginx/html$ whoami 
nginx
```
