FROM python:3.7-slim

ENV LANG=C.UTF-8

# Install some basic utilities.
RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release curl gnupg git \
    && apt-get clean

# Install Jupyter.
# Note that we pin tornado to < 6, as we encountered issues with
# websockets with tornado 6.
RUN pip install jupyter==1.0.0 ipywidgets==7.4.2 jupyterlab==0.35.4 'tornado<6' \
    && jupyter nbextension enable --py widgetsnbextension \
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
RUN pip install jupyter-server-proxy==1.0.1 'tornado<6' \
    && jupyter serverextension enable --py jupyter_server_proxy \
    && jupyter labextension install jupyterlab-server-proxy \
    && jupyter lab build

# Download and install VS Code server
RUN curl -L -O https://github.com/cdr/code-server/releases/download/1.939-vsc1.33.1/code-server1.939-vsc1.33.1-linux-x64.tar.gz \
    && tar xzf code-server1.939-vsc1.33.1-linux-x64.tar.gz \
    && mv code-server1.939-vsc1.33.1-linux-x64/code-server /usr/local/bin/ \
    && rm -rf code-server1.939-vsc1.33.1-linux-x64 code-server1.939-vsc1.33.1-linux-x64.tar.gz

# Install the VS code proxy.
COPY jupyter-vscode-proxy /etc/jupyter-vscode-proxy
RUN pip install /etc/jupyter-vscode-proxy

# Install packages by manually unpacking vsix archives (useful when stuck behind
# proxies, which are not yet supported by code server).
# COPY ms-python.2019.3.6558.vsix /tmp
# RUN mkdir -p /tmp/ms-python.2019.3.6558 /extensions \
#     && apt-get update && apt-get install -y bsdtar && apt-get clean \
#     && bsdtar -C /tmp/ms-python.2019.3.6558 -xvzf /tmp/ms-python.2019.3.6558.vsix \
#     && mv /tmp/ms-python.2019.3.6558/extension /extensions/ms-python.2019.3.6558 \
#     && rm -rf /tmp/ms-python.2019.3.6558*

EXPOSE 8888

RUN mkdir -p /work
WORKDIR /work

# Use 'notebook' instead of 'lab' for Jupyter Notebook.
ENTRYPOINT ["jupyter", "lab"]
CMD ["--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
