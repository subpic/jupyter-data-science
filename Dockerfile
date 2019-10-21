FROM nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04
# Contributors: Syed Navaid (https://github.com/syedahmad)
#               Vlad Hosu (https://github.com/subpic)

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
#		software-properties-common \
		build-essential \
        libfreetype6-dev \
        libpng12-dev \
        openssh-client

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

#Downgrade CUDA, TF issue: https://github.com/tensorflow/tensorflow/issues/17566#issuecomment-372490062
RUN apt-get install --allow-downgrades --allow-change-held-packages -y libcudnn7=7.0.5.15-1+cuda9.0 git-lfs

#Install MINICONDA
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
		/bin/bash Miniconda.sh -b -p /opt/conda && \
		rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

#Install ANACONDA Environment
RUN conda create -y -n jupyter_env python=3.6 nb_conda_kernels py-xgboost-gpu \
		anaconda ipykernel tensorflow-gpu keras-gpu matplotlib numpy scipy pandas \
		Pillow pydot munch scikit-learn && \
		/opt/conda/envs/jupyter_env/bin/pip install jupyter-tensorboard gitless opencv-python && \
		/opt/conda/envs/jupyter_env/bin/python -m ipykernel.kernelspec

RUN conda create -y -n jupyter_env27 python=2.7 nb_conda_kernels py-xgboost-gpu \
		anaconda ipykernel tensorflow-gpu keras-gpu matplotlib numpy scipy pandas \
		Pillow pydot munch scikit-learn && \
		/opt/conda/envs/jupyter_env27/bin/pip install jupyter-tensorboard gitless opencv-python && \
		/opt/conda/envs/jupyter_env27/bin/python -m ipykernel.kernelspec

# Install OpenCV
RUN apt-get update && apt-get install -y libopencv-dev && \
    echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

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

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
ENV PYTHONPATH='/mnt/home/research/:/mnt/home/:$PYTHONPATH'
ENV PASSWORD unknownknowns
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH

WORKDIR /mnt/home/

# IPython
EXPOSE 8888 6006

CMD bash /root/entrypoint.sh
