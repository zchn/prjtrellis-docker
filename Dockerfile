FROM alpine as builder

RUN apk add --no-cache --virtual prjtrellis-build-dependencies \
    build-base \
    cmake \
    git \
    python3-dev \
    boost-dev

RUN git clone --recursive https://github.com/SymbiFlow/prjtrellis

WORKDIR /prjtrellis/libtrellis

RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis .
RUN make -j$(nproc)
RUN make install

FROM alpine

COPY --from=builder /opt/prjtrellis/ /opt/prjtrellis/

ENV PATH $PATH:/opt/prjtrellis/bin/

