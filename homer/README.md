**GitHub Project**: [bastienwirtz/homer](https://github.com/bastienwirtz/homer)
### Copying config to `/AppData/dashboard` 
```bash
cp  dashboard /AppData/dashboard
```

## To launch a container with Homer using docker:

```bash
docker run -d \
    -p 8080:8080 \
    -v /AppData/dashboard:/www/assets \
    --restart=always \
    b4bz/homer:latest
```

### Behind a docker nginx proxy

```bash
docker run -d \
    -v /AppData/dashboard:/www/assets \
    -e VIRTUAL_HOST=dashboard.home \
    -e VIRTUAL_PORT=8080 \
    --network net \
    --restart=always \
    b4bz/homer:latest
```