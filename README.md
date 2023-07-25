# Devcontianer php

# Build Image
```bash
# build docker image
cd 7.4.27
docker build -t devcontainer-php:7.4.27 .
```

## Networks
```bash
# create networks 
docker network create --subnet=172.17.11.0/24 --gateway=172.17.11.1 --opt "com.docker.network.bridge.name"="back" back
```
## Reopen in container

