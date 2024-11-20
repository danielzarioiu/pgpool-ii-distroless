

FROM debian:latest AS builder
ARG PGPOOL_VER=4.5.4
ARG INSTALL_DIR=/opt/pgpool-II

RUN apt update && apt install -y \
    libtool libpq-dev libpq5 libssl3 libssl-dev libgssapi-krb5-2 libkrb5-3 libldap-2.5-0 libkrb5support0 libkrb5-3 libsasl2-2 libk5crypto3 libkeyutils1 libgssapi-krb5-2 openssl make 

ADD https://pgpool.net/mediawiki/images/pgpool-II-${PGPOOL_VER}.tar.gz /tmp
RUN mkdir /tmp/pgpool \
    && tar -zxf /tmp/pgpool-II-${PGPOOL_VER}.tar.gz -C /tmp/pgpool --strip-components 1 \
    && cd /tmp/pgpool \
    && ./configure --prefix=${INSTALL_DIR} \
    && mkdir -p ${INSTALL_DIR}/tls \
    && make -j $(nproc) \
    && make install

ADD ./entrypoint.sh \
    https://raw.githubusercontent.com/pgpool/pgpool2_on_k8s/refs/heads/master/pgpool.docker/start.sh \
    ${INSTALL_DIR}/bin/

FROM debian:stable-slim AS runtime
ARG INSTALL_DIR
ENV PGPOOL_INSTALL_DIR=/opt/pgpool-II

RUN groupadd -g 70 --system pgpool \
    && useradd -u 70 --system --gid pgpool --home-dir /opt/pgpool-II --shell /bin/bash pgpool \
    && mkdir /var/run/pgpool \
    && chown pgpool:pgpool /var/run/pgpool

WORKDIR /opt/pgpool-II

COPY --from=builder --chown=pgpool:pgpool /opt/pgpool-II ./
COPY --from=builder /usr/lib/*-linux-gnu/libpq.so.5* \
    /usr/lib/*-linux-gnu/libssl.so.3 \
    /usr/lib/*-linux-gnu/libcrypto.so.3 \
    /usr/lib/*-linux-gnu/libgssapi_krb5.so.2 \
    /usr/lib/*-linux-gnu/libkrb5.so.3 \
    /usr/lib/*-linux-gnu/libkrb5support.so.0 \
    /usr/lib/*-linux-gnu/libk5crypto.so.3 \
    /usr/lib/*-linux-gnu/libcom_err.so.2 \
    /usr/lib/*-linux-gnu/libldap-2.5.so.0 \
    /usr/lib/*-linux-gnu/liblber-2.5.so.0 \
    /usr/lib/*-linux-gnu/libsasl2.so.2 \
    /usr/lib/*-linux-gnu/libkeyutils.so.1 \
    /usr/lib/
COPY --from=builder /usr/bin/openssl /usr/bin/openssl
COPY --from=builder /etc/ssl/openssl.cnf /usr/lib/ssl/openssl.cnf

RUN chmod +x bin/entrypoint.sh \
    bin/start.sh

USER pgpool:pgpool

ENV PGPOOL_CONF_VOLUME=/config
VOLUME [ "/config" ]

ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bin/start.sh"]
