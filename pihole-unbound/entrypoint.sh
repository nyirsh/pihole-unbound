#!/bin/sh
set -e

# Seed persistent Unbound state if missing
# This should be a fallback in case of empty binds / mounted volumes

# root.hints
if [ ! -s /var/lib/unbound/root.hints ]; then
    echo "Downloading root.hints..."
    wget -qO /var/lib/unbound/root.hints https://www.internic.net/domain/named.root 2>/dev/null || true
fi

# Check once again if root.hints exists, if not, something went wrong
if [ ! -s /var/lib/unbound/root.hints ]; then
    echo "ERROR: /var/lib/unbound/root.hints is missing or empty after download attempt." >&2
    echo "This likely means the container has no network access to fetch the root hints file." >&2
    exit 1
fi

# root.key
if [ ! -s /var/lib/unbound/root.key ]; then
    echo "Initializing DNSSEC root trust anchor..."
    unbound-anchor -a /var/lib/unbound/root.key || true
fi

# Check once again if root.key exists, if not, something went wrong
if [ ! -s /var/lib/unbound/root.key ]; then
    echo "ERROR: /var/lib/unbound/root.key is missing or empty after initalization attempt." >&2
    echo "unbound-anchor could not initialize the DNSSEC root trust anchor (likely no network access)." >&2
    exit 1
fi

chown -R unbound:unbound /var/lib/unbound /etc/unbound || echo "WARNING: chown failed, continuing" >&2
chmod 644 /var/lib/unbound/root.key || echo "WARNING: chmod failed, continuing" >&2

# Start Unbound and verify it's actually running
echo "Starting Unbound..."
unbound -d &
UNBOUND_PID=$!

READY=0
for i in $(seq 1 30); do
    if ! kill -0 "$UNBOUND_PID" 2>/dev/null; then
        echo "Unbound exited during startup" >&2
        exit 1
    fi
    if nc -z 127.0.0.1 5335 2>/dev/null; then
        READY=1
        break
    fi
    sleep 0.5
done

if [ "$READY" -ne 1 ]; then
    echo "Unbound did not become ready within timeout" >&2
    exit 1
fi

echo "Starting Pihole..."
exec /usr/bin/start.sh