# Jupyterlab-vscode

Docker image with JupyterLab + VSCode Server for browser-based editing.

## Usage

Building the image:

```
docker build -t jrderuiter/jupyterlab-vscode .
```

Running the image:

```
docker run --rm -p 8888:8888 jupyterlab
```

Files/notebooks can be mounted into the `/work` directory, which is the
default working directory for JupyterLab and vscode-server.

## References

Based on:

- https://github.com/mikebirdgeneau/jupyterlab-docker
- https://github.com/betatim/vscode-binder

