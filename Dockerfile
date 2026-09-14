FROM pihole/pihole:2026.07.2

RUN apk update
RUN apk add --no-cache wget
RUN mkdir -p /var/lib/unbound && \
    wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root && \
    [ -s /var/lib/unbound/root.hints ]

RUN apk add --no-cache unbound
COPY unbound-pihole.conf /etc/unbound/unbound.conf

COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD /healthcheck.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]