FROM pihole/pihole:2026.09.0

RUN apk update
RUN apk add --no-cache wget

RUN mkdir -p /usr/share/pihole-unbound && \
    wget -qO /usr/share/pihole-unbound/root.hints \
      https://www.internic.net/domain/named.root && \
    test -s /usr/share/pihole-unbound/root.hints

RUN apk add --no-cache unbound
COPY unbound-pihole.conf /etc/unbound/unbound.conf

COPY refresh-hints.sh /refresh-hints.sh
RUN chmod +x /refresh-hints.sh

COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD /healthcheck.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]