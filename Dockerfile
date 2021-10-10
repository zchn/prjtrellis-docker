FROM zchn/riscv-gnu-toolchain:6c16b3c03b602dc59684ef279827a647a12046c5 as build

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
    libboost-python-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

RUN git clone --recursive https://github.com/YosysHQ/prjtrellis && \
    cd prjtrellis/libtrellis && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis -DPYTHON_LIBRARY=/usr/lib/python3.6 . && \
    unset C_INCLUDE_PATH && \
    unset LD_LIBRARY_PATH && \
    unset CC && \
    unset CXX && \
    make -j$(nproc) && \
    make install

WORKDIR /work
ENV PATH /opt/prjtrellis/bin/:$PATH

RUN git clone https://github.com/YosysHQ/yosys.git && \
    cd yosys && \
    echo "PREFIX := /opt/yosys" >> Makefile.conf && \
    make config-clang && \
    make && make install

FROM zchn/riscv-gnu-toolchain:6c16b3c03b602dc59684ef279827a647a12046c5

COPY --from=build /opt/prjtrellis/ /opt/prjtrellis/
COPY --from=build /opt/yosys /opt/yosys

ENV PATH /opt/prjtrellis/bin/:$PATH
ENV PATH /opt/yosys/bin:$PATH

RUN find /opt/prjtrellis
RUN find /opt/yosys
