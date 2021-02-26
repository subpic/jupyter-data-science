## Build

```
docker build -f Dockerfile -t jupyter-dl .
```

## Execute

```
nvidia-docker run -v $PWD:/mnt/home/ -p 8888:8888 -p 6006:6006 jupyter-dl
```

Note: The entrypoint script accepts Jupyter-Lab arguments

```
e.g. nvidia-docker run -v $PWD:/mnt/home/ -p 8888:8888 -p 6006:6006 jupyter-dl --notebook-dir=/mnt/home
```
