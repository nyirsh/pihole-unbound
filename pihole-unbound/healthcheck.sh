#!/bin/sh

# Pi-hole/FTL — copied from pihole docker image
if ! dig -p "$(pihole-FTL --config dns.port)" +short +norecurse +retry=0 @127.0.0.1 pi.hole >/dev/null; then
    echo "healthcheck: FTL not answering" >&2
    exit 1
fi

# Unbound — verify actual upstream resolution works
if ! dig @127.0.0.1 -p 5335 example.com +time=2 +retry=0 +short >/dev/null; then
    echo "healthcheck: Unbound not answering" >&2
    exit 1
fi