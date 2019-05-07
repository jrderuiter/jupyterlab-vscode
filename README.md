# Jupyterlab-vscode

Docker image with JupyterLab + VSCode Server for browser-based editing.

## Usage

Building the image:

```
docker build -t jrderuiter/jupyterlab-vscode .
```

Running the image:

```
docker run --rm -p 8888:8888 jrderuiter/jupyterlab-vscode
```

Files/notebooks can be mounted into the `/work` directory, which is the
default working directory for JupyterLab and vscode-server.

Or more simply, using docker-compose:

```
docker-compose up --build
```

## References

Based on:

- https://github.com/mikebirdgeneau/jupyterlab-docker
- https://github.com/betatim/vscode-binder

