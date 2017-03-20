## Build image

```
docker build -t mingchen0919/galaxy_dibbs:docker-galaxy-combined ./ 
```



## Run docker container

```
docker run -i -t -p 8080:80 -p 8021:21 -p 8022:22  \
    -e "GALAXY_CONFIG_ADMIN_USERS=ming.chen0919@gmail.com" \
     mingchen0919/galaxy_dibbs:v2.0.0 /bin/bash
```

Launch galaxy

```
startup
```
