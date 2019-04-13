FROM python:3.7.3-slim

ENV LANG=C.UTF-8

# Install some basic utilities.
RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release curl gnupg \
    && apt-get clean

# Install Jupyter.
RUN pip install jupyter ipywidgets \
    && jupyter nbextension enable --py widgetsnbextension

# Install JupyterLab.
RUN pip install jupyterlab \
    && jupyter serverextension enable --py jupyterlab

# Install a recent version of nodejs (required for proxy extension).
RUN VERSION=node_11.x && DISTRO="$(lsb_release -s -c)" \
    && curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list \
    && echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean

# Install proxy extension.
RUN pip install https://github.com/jupyterhub/jupyter-server-proxy/archive/7ac0125.zip \
    && jupyter serverextension enable --py jupyter_server_proxy \
    && jupyter labextension install jupyterlab-server-proxy \
    && jupyter lab build

# Download and install VS Code server
RUN curl -L -O https://github.com/codercom/code-server/releases/download/1.604-vsc1.32.0/code-server1.604-vsc1.32.0-linux-x64.tar.gz \
    && tar xzf code-server1.604-vsc1.32.0-linux-x64.tar.gz \
    && mv code-server1.604-vsc1.32.0-linux-x64/code-server /usr/local/bin/ \
    && rm -rf code-server1.604-vsc1.32.0-linux-x64 code-server1.604-vsc1.32.0-linux-x64.tar.gz

# Install the VS code proxy.
COPY jupyter-vscode-proxy /etc/jupyter-vscode-proxy
RUN pip install /etc/jupyter-vscode-proxy

# Install any pre-defined Python requirements.
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm -rf /tmp/requirements.txt

# Expose Jupyter port & entrypoint.
EXPOSE 8888

RUN mkdir -p /work
WORKDIR /work

ENTRYPOINT ["jupyter", "lab"]
CMD ["--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
