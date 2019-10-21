# Jupyter-Lab Data Science Dockerfile
This is a jupyter-lab based setup for data science, including Anaconda environments for Python (v2 and v3), with Keras + Tensorflow GPU and XGBoost GPU.

After building the image, run using:
```
nvidia-docker run -v $PWD:/mnt/home/ -p 8888:8888 -p 6006:6006 jupyter-data-science "$@"
```

The entrypoint script accepts Jupyter-Lab arguments:

```
e.g. nvidia-docker run -v $PWD:/mnt/home/ -p 8888:8888 -p 6006:6006 jupyter-data-science --notebook-dir=/mnt/home
```
