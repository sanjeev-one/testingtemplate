FROM ubuntu:latest
WORKDIR /opt


# Install necessary packages and OpenMPI
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        python3-dev \
        python3-pip \
        wget \
        openmpi-bin \
        libopenmpi-dev \
        libssl-dev \
        htop \
        rsync && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install mpi4py with pip
RUN python3 -m pip install mpi4py

FROM docker.io/continuumio/miniconda3:latest

ENV PATH=/opt/conda/bin:$PATH

RUN chmod -R 777 /opt/conda

RUN /opt/conda/bin/conda install conda-forge::lume-impact
RUN  sed -i "s|workdir = full_path(workdir)|workdir = tools.full_path(workdir) |g" /opt/conda/lib/python3.12/site-packages/lume/base.py

RUN /opt/conda/bin/conda install -c conda-forge impact-t
RUN /opt/conda/bin/conda install -c conda-forge impact-t=*=mpi_openmpi*
ENV CONDA_SOLVER=classic
RUN /opt/conda/bin/conda install -c conda-forge bmad

RUN /opt/conda/bin/conda install -y \
    jupyter \
    jupyterlab \
    scipy \
    numpy \
    matplotlib \
    pillow \
    pandas \
    conda-forge::xopt \
    conda-forge::distgen \
    h5py \
    pytao \
    conda-forge::openpmd-beamphysics && \
    /opt/conda/bin/conda clean -afy



# Copy Jupyter notebooks into the image
COPY notebooks /opt/notebooks
#copy facet2 lattice over
COPY facet2-lattice /opt/notebooks/facet2-lattice

ENV FACET2_LATTICE=/opt/notebooks/facet2-lattice

RUN mkdir /sdf

# Expose port for JupyterLab
EXPOSE 8888
EXPOSE 8889

EXPOSE 5555
EXPOSE 5556


# Default command to run JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--notebook-dir=/opt/notebooks","--port=5555"]
