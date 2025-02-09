# syntax=docker/dockerfile:1

ARG DEBIAN_REL=bookworm
FROM debian:${DEBIAN_REL}-slim

ARG DEBIAN_REL
ARG KNOT_VER=3.4.4

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests ca-certificates wget \
    && wget -q -O /usr/share/keyrings/cznic-labs-pkg.gpg https://pkg.labs.nic.cz/gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cznic-labs-pkg.gpg] https://pkg.labs.nic.cz/knot-dns ${DEBIAN_REL} main" > /etc/apt/sources.list.d/cznic-labs-knot-dns.list \
    && apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests "?and(?name(^knot-dnsutils$), ?version(${KNOT_VER}-))" \
    && apt-get purge --autoremove -y wget

ENTRYPOINT ["/usr/bin/kdig"]
