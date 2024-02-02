# syntax=docker/dockerfile:1.4

ARG DEBIAN_REL="bookworm"
FROM debian:${DEBIAN_REL}-slim as builder

ARG KNOT_VER=3.3.4

RUN echo "deb-src http://deb.debian.org/debian sid main" > /etc/apt/sources.list.d/sid-src.list

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential devscripts curl \
 && apt build-dep -y knot

WORKDIR /tmp
RUN DSC_FILE=$(curl -sSL "http://deb.debian.org/debian/pool/main/k/knot/?C=M;O=D" | grep -P -o "href=\"knot_${KNOT_VER}-\d+.dsc\">" | head -1 | sed -e 's/^href="//' -e 's/">$//') \
  && dget http://deb.debian.org/debian/pool/main/k/knot/${DSC_FILE}

WORKDIR /tmp/knot-${KNOT_VER}
RUN DEB_BUILD_OPTIONS=noddebs dpkg-buildpackage -r -uc -b

RUN mkdir /tmp/copy
RUN cp /tmp/knot-dnsutils*.deb /tmp/libknot*.deb /tmp/libdnssec*.deb /tmp/libzscanner*.deb /tmp/copy
RUN rm /tmp/copy/libknot-dev_*.deb

ARG DEBIAN_REL="bookworm"
FROM debian:${DEBIAN_REL}-slim

COPY --from=builder /tmp/copy /tmp

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/*.deb

ENTRYPOINT ["/usr/bin/kdig"]
