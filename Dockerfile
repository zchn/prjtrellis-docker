FROM zchn/riscv-gnu-toolchain:3f50815a730ddeba9378b586c03d3b479a117445 as build

ENV DEBIAN_FRONTEND "noninteractive"
ENV PATH /opt/riscv/bin:$PATH

# apt-get dependencies
RUN apt-get update && \
    apt-get install --yes \
    git build-essential wget meson \
    openocd device-tree-compiler fakeroot libjsoncpp-dev verilator \
    python3 python3-dev python3-setuptools \
    libevent-dev libftdi1-dev \
    libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-thread-dev \
    libmpc-dev libmpfr-dev \
    clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev \
    graphviz xdot pkg-config \
    libboost-python-dev zlib1g-dev \
    clang-format libboost-iostreams-dev libeigen3-dev srecord && \
    rm -rf /var/lib/apt/lists/*

# Install latest cmake
WORKDIR /src
RUN wget -q https://apt.kitware.com/kitware-archive.sh && bash ./kitware-archive.sh && apt-get update && \
    apt-get install --yes cmake && \
    rm -rf /var/lib/apt/lists/*

# Install prjtrellis
WORKDIR /src
RUN git clone --recursive 'https://github.com/YosysHQ/prjtrellis'
WORKDIR /src/prjtrellis/libtrellis
# hadolint ignore=SC2046
RUN cmake -DCMAKE_INSTALL_PREFIX='/opt/prjtrellis' . && \
    make -j$(nproc) && \
    make install
ENV PATH /opt/prjtrellis/bin/:$PATH
ENV TRELLIS /opt/prjtrellis/share/trellis

# Install yosys
WORKDIR /src
RUN wget -q https://github.com/YosysHQ/yosys/archive/refs/tags/yosys-0.12.tar.gz && tar xvf ./yosys-0.12.tar.gz
WORKDIR /src/yosys-yosys-0.12
# hadolint ignore=SC2046
RUN make config-clang && \
    echo "PREFIX := /opt/yosys" >> Makefile.conf && \
    make -j$(nproc) && make install
ENV PATH /opt/yosys/bin:$PATH

# Install nextpnr
WORKDIR /src
RUN wget -q https://github.com/YosysHQ/nextpnr/archive/refs/tags/nextpnr-0.1.tar.gz && tar xvf ./nextpnr-0.1.tar.gz
WORKDIR /src/nextpnr-nextpnr-0.1
# hadolint ignore=SC2046
RUN cmake . -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX='/opt/prjtrellis' -DCMAKE_INSTALL_PREFIX='/opt/nextpnr' && \
    make -j$(nproc) && make install
ENV PATH /opt/nextpnr/bin:$PATH

# Test examples
# WORKDIR /src/prjtrellis/examples/ecp5_evn
# RUN make
# WORKDIR /src/prjtrellis/examples/ecp5_evn_multiboot
# RUN make

WORKDIR /work
CMD /bin/bash
