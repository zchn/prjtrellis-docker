FROM zchn/riscv-gnu-toolchain:6c16b3c03b602dc59684ef279827a647a12046c5 as build

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    git cmake build-essential wget meson \
    openocd device-tree-compiler fakeroot libjsoncpp-dev verilator \
    python3 python3-dev python3-setuptools libevent-dev \
    libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-thread-dev \
    libmpc-dev libmpfr-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

RUN git clone --recursive https://github.com/YosysHQ/prjtrellis && \
    cd prjtrellis/libtrellis && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis . && \
    make -j$(nproc) && \
    make install

FROM zchn/riscv-gnu-toolchain:6c16b3c03b602dc59684ef279827a647a12046c5

COPY --from=build /opt/prjtrellis/ /opt/prjtrellis/

ENV PATH=${PATH}:/opt/prjtrellis/bin/
