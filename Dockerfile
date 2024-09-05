# Use the official Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    gcc-7 \
    g++-7 \
    build-essential \
    vim \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    flex \
    bison \
    texinfo \
    libisl-dev \
    wget \
    curl \
    virt-manager \
    libvirt-daemon \
    ovmf \
    git \
    uuid-dev \
    openssh-server \
    openssl \
    iasl \
    && apt-get clean

# Update alternatives to set GCC 7 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 50

# Add the deadsnakes PPA for Python 3.8
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3.8-distutils \
    && apt-get clean

# Update alternatives to set Python 3.8 as the default for python and python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Download, extract, and build GCC 7.5.0 targeting aarch64-linux-gnu
RUN wget http://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.gz && \
    tar -xzf gcc-7.5.0.tar.gz && \
    cd gcc-7.5.0 && \
    ./contrib/download_prerequisites && \
    mkdir build-gcc && \
    cd build-gcc && \
    ../configure --target=aarch64-linux-gnu --prefix=/usr/sbin --enable-languages=c,c++ --disable-multilib --enable-shared --enable-threads=posix --with-system-zlib \
    AR=/usr/bin/aarch64-linux-gnu-ar AS=/usr/bin/aarch64-linux-gnu-as LD=/usr/bin/aarch64-linux-gnu-ld OBJCOPY=/usr/bin/aarch64-linux-gnu-objcopy && \
    make -j$(nproc) && \
    make install
# Configure SSH to allow root login and set the root password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:test' | chpasswd

# Start the SSH service
RUN service ssh start

# Clone the edk2 repository
RUN git clone https://github.com/tianocore/edk2.git /edk2

# Initialize and update submodules
RUN cd /edk2 && \
    git submodule update --init && \
    git pull && \
    git submodule update

# Set the working directory
WORKDIR /edk2

# Expose SSH port
EXPOSE 22

# Start SSH service and keep the container running
CMD ["/usr/sbin/sshd", "-D"]
