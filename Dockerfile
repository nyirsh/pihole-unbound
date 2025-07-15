FROM pihole/pihole:2025.07.1

RUN apk update
RUN apk add --no-cache wget
RUN mkdir -p /var/lib/unbound
RUN wget https://www.internic.net/domain/named.root -qO- | tee /var/lib/unbound/root.hints
RUN apk add --no-cache unbound

COPY unbound-pihole.conf /etc/unbound/unbound.conf
COPY 99-edns.conf /etc/dnsmasq.d/99-edns.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]