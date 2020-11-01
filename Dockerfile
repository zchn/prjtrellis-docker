FROM alpine as build

RUN apk add --no-cache --virtual prjtrellis-build-dependencies \
    build-base \
    cmake \
    git \
    python3-dev \
    boost-dev

ENV REVISION ${MASTER}
RUN git clone --recursive --branch ${REVISION} https://github.com/SymbiFlow/prjtrellis

WORKDIR /prjtrellis/libtrellis/build

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis \
    ..
RUN make -j$(nproc)
RUN make install

FROM alpine

COPY --from=build /opt/prjtrellis/ /opt/prjtrellis/

WORKDIR /workspace
RUN adduser -D -u 1000 trellis && chown trellis:trellis /workspace

USER trellis

ENV PATH $PATH:/opt/prjtrellis/bin/

