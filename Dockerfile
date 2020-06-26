FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    build-base \
    cmake \
    git \
    python3-dev \
    boost-dev

RUN git clone --recursive https://github.com/SymbiFlow/prjtrellis

WORKDIR /prjtrellis/libtrellis

RUN cmake -DARCH=ecp5 cmake -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=builder /opt/prjtrellis/ /opt/prjtrellis/

ENV PATH $PATH:/opt/prjtrellis/bin/

