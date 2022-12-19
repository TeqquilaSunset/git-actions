FROM ubuntu:22.04 as builder
LABEL org.opencontainers.image.authors="sc-2005@yandex.ru"

ARG YQ_VERSION=v4.29.2
ARG YQ_BINARY=yq_linux_amd64
ARG TASK_VERSION=v3.17.0
ARG TASK_BINARY=task_linux_amd64.tar.gz

RUN apt update && apt install -y \
  libfontconfig1 \
  libxtst6 \
  rubygems \
  wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq \
    && chmod +x /usr/bin/yq
RUN wget -O- https://github.com/go-task/task/releases/download/${TASK_VERSION}/${TASK_BINARY} \
    | tar xz -C /usr/bin
RUN gem install yaml-cv

WORKDIR /opt/app

COPY src src
COPY scripts scripts
COPY .env .env
COPY Taskfile.yaml Taskfile.yaml

ENTRYPOINT ["task"]
CMD ["build"]

FROM builder as build
RUN task build

FROM busybox as final
WORKDIR /opt/app/build
COPY --from=build opt/app/build/cv.html .
VOLUME /opt/app/build