FROM zchn/riscv-gnu-toolchain:ec0d9d955eb7995c979c7cc6297391153a5f050e as build

# apt-get dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    git cmake build-essential wget meson \
    openocd device-tree-compiler fakeroot libjsoncpp-dev verilator \
    python3 python3-dev python3-setuptools \
    libevent-dev \
    libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-thread-dev \
    libmpc-dev libmpfr-dev \
    clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev \
    graphviz xdot pkg-config \
    libboost-python-dev zlib1g-dev \
    clang-format libboost-iostreams-dev libeigen3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install prjtrellis
WORKDIR /work
RUN git clone --recursive 'https://github.com/YosysHQ/prjtrellis'
WORKDIR /work/prjtrellis/libtrellis
# hadolint ignore=SC2046
RUN cmake -DCMAKE_INSTALL_PREFIX='/opt/prjtrellis' . && \
    make -j$(nproc) && \
    make install
ENV PATH /opt/prjtrellis/bin/:$PATH

# Install yosys
WORKDIR /work
RUN git clone 'https://github.com/YosysHQ/yosys.git'
WORKDIR /work/yosys
RUN make config-clang && \
    echo "PREFIX := /opt/yosys" >> Makefile.conf && \
    make && make install
ENV PATH /opt/yosys/bin:$PATH

# Install nextpnr
WORKDIR /work
RUN git clone 'https://github.com/YosysHQ/nextpnr.git'
WORKDIR /work/nextpnr
RUN cmake . -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX='/opt/prjtrellis' -DCMAKE_INSTALL_PREFIX='/opt/nextpnr' && \
    make -j$(nproc) && make install
ENV PATH /opt/nextpnr/bin:$PATH

# Test examples
WORKDIR /work/prjtrellis/examples/ecp5_evn
RUN make
WORKDIR /work/prjtrellis/examples/ecp5_evn_multiboot
RUN make
WORKDIR /work/prjtrellis/examples/soc_ecp5_evn
RUN make

FROM zchn/riscv-gnu-toolchain:ec0d9d955eb7995c979c7cc6297391153a5f050e

COPY --from=build /opt/prjtrellis/ /opt/prjtrellis/
COPY --from=build /opt/yosys/ /opt/yosys/
COPY --from=build /opt/nextpnr/ /opt/nextpnr/

ENV PATH /opt/prjtrellis/bin/:$PATH
ENV PATH /opt/yosys/bin:$PATH
ENV PATH /opt/nextpnr/bin:$PATH

RUN find /opt/prjtrellis && \
    find /opt/yosys && \
    find /opt/nextpnr
