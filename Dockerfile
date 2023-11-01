ARG DEBIAN_REL
FROM debian:${DEBIAN_REL}-slim as builder

ARG KNOT_VER
ARG KNOT_REL

RUN echo "deb-src http://deb.debian.org/debian sid main" > /etc/apt/sources.list.d/sid-src.list

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential devscripts \
 && apt build-dep -y knot

WORKDIR /tmp
RUN dget http://deb.debian.org/debian/pool/main/k/knot/knot_${KNOT_VER}-${KNOT_REL}.dsc

WORKDIR /tmp/knot-${KNOT_VER}
RUN DEB_BUILD_OPTIONS=noddebs dpkg-buildpackage -r -uc -b

RUN mkdir /tmp/copy
RUN cp /tmp/knot-dnsutils*.deb /tmp/libknot*.deb /tmp/libdnssec*.deb /tmp/libzscanner*.deb /tmp/copy
RUN rm /tmp/copy/libknot-dev_*.deb

ARG DEBIAN_REL
FROM debian:${DEBIAN_REL}-slim

LABEL maintainer="Mitsuru Shimamura <smbd.jp@gmail.com>"

COPY --from=builder /tmp/copy /tmp

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/*.deb

ENTRYPOINT ["/usr/bin/kdig"]
