FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    build-base \
    cmake \
    git \
    python3-dev \
    boost-dev

RUN git clone --recursive https://github.com/SymbiFlow/prjtrellis

WORKDIR /prjtrellis/libtrellis

RUN cmake -DARCH=ecp5 .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=builder /usr/local/lib64/trellis/ /usr/local/lib64/trellis/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/share/trellis/ /usr/local/share/trellis/

