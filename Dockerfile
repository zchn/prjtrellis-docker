FROM alpine as build

RUN apk add --no-cache --virtual prjtrellis-build-dependencies \
    build-base \
    cmake \
    git \
    python3-dev \
    boost-dev

ENV REVISION=master
RUN git clone --recursive --branch ${REVISION} https://github.com/SymbiFlow/prjtrellis /prjtrellis

WORKDIR /prjtrellis/libtrellis/build

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/prjtrellis \
    ..
RUN make -j$(nproc)
RUN make install

FROM alpine

COPY --from=build /opt/prjtrellis/ /opt/prjtrellis/

ENV USER=trellis \
    WORKSPACE=/workspace
RUN adduser -D -u 1000 ${USER} &&\
    mkdir -p ${WORKSPACE} &&\
    chown -R ${USER}:${USER} ${WORKSPACE}

USER ${USER}
WORKDIR ${WORKSPACE}
ENV PATH=${PATH}:/opt/prjtrellis/bin/

