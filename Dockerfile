FROM nvcr.io/nvidia/tensorflow:20.09-tf2-py3

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
	wget \
	vim \
	bzip2 \
	graphviz \
	mc \
	htop \
	emacs-nox \
	rsync \
	less \
	curl \
	build-essential \
	openssh-server \
	imagemagick

# Install MINICONDA
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
    /bin/bash Miniconda.sh -b -p /opt/conda && \
    rm Miniconda.sh
ENV PATH /opt/conda/bin:$PATH
RUN conda update -y -n base -c defaults conda

# CREATE ENV and INSTALL
RUN conda create -y -n jupyter_env python nb_conda_kernels py-xgboost-gpu \
	  anaconda ipykernel tensorflow-gpu keras-gpu matplotlib numpy scipy pandas \
	  Pillow pydot munch scikit-learn future \
    && /opt/conda/envs/jupyter_env/bin/pip install jupytext jupyter-tensorboard \
    	  gitless opencv-python tensorflow-gpu==2.4.1 \
    && /opt/conda/envs/jupyter_env/bin/python -m ipykernel.kernelspec

# Install OpenCV
RUN apt-get update && apt-get install -y libopencv-dev && \
    echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH $HOME/.poetry/bin:$PATH

RUN set -x \
    && cd /tmp \
    && wget https://github.com/sdg-mit/gitless/releases/download/v0.8.8/gl-v0.8.8-linux-x86_64.tar.gz \
    && tar -C /usr/bin/ -xvf gl-v0.8.8-linux-x86_64.tar.gz --strip-components=1 \
    && rm -f gl-v0.8.8-linux-x86_64.tar.gz

COPY docker_deps/entrypoint.sh /root/
COPY tests/test_libraries.py /tmp/
COPY configs/jupyter_notebook_config.py /root/.jupyter/

RUN chmod +x /root/entrypoint.sh && \
	chown -R 777 /tmp/test_libraries.py

RUN mkdir /var/run/sshd \
    && echo 'root:jupyter-data-science' | chpasswd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "export VISIBLE=now" >> /etc/profile
ENV NOTVISIBLE "in users profile"

RUN useradd -rm -d /home/science -s /bin/bash -g root -G sudo -u 1000 science \
    && echo 'science:jupyter-data-science' | chpasswd

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 \
    PYTHONPATH='/mnt/home/research/:/mnt/home/:$PYTHONPATH' \
    PASSWORD=jupyter-data-science \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH 

WORKDIR /mnt/home/

# Jupyter + Tensorboard + SSHD
EXPOSE 8888 6006 22

CMD bash /root/entrypoint.sh


