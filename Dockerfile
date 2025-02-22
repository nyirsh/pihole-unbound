FROM pihole/pihole:2025.02.4

RUN apt update && apt install -y unbound
RUN apt install -y wget
RUN wget https://www.internic.net/domain/named.root -qO- | tee /var/lib/unbound/root.hints

COPY lighttpd-external.conf /etc/lighttpd/external.conf 
COPY unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY 99-edns.conf /etc/dnsmasq.d/99-edns.conf

RUN mkdir -p /etc/services.d/unbound
COPY unbound-run /etc/services.d/unbound/run
RUN chmod +x /etc/services.d/unbound/run

ENTRYPOINT ./s6-init
