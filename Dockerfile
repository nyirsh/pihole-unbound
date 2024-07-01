ARG PIHOLE_VERSION
FROM pihole/pihole:${PIHOLE_VERSION:-latest}

# Install necessary packages and clean up
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        unbound \
    && rm -rf /var/lib/apt/lists/*

# Download root hints for Unbound using ADD
ADD https://www.internic.net/domain/named.root /var/lib/unbound/root.hints

# Copy configuration files
COPY lighttpd-external.conf /etc/lighttpd/external.conf
COPY unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY 99-edns.conf /etc/dnsmasq.d/99-edns.conf

# Copy and set permissions for the run script
COPY unbound-run /etc/services.d/unbound/run
RUN chmod +x /etc/services.d/unbound/run

# Set the entrypoint
ENTRYPOINT ["./s6-init"]