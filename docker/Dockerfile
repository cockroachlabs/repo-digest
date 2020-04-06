FROM golang:1.13
ENTRYPOINT /entrypoint.sh
ENV WORKDIR /build
WORKDIR $WORKDIR
COPY . .

RUN docker/build.sh