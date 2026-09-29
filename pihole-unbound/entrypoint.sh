#!/bin/sh
set -e

# root.hints
if ! /refresh-hints.sh; then
    echo "ERROR: /var/lib/unbound/root.hints is missing and could not be downloaded or restored from the bundled copy." >&2
    exit 1
fi

# root.key
if [ ! -s /var/lib/unbound/root.key ]; then
    echo "Initializing DNSSEC root trust anchor..."
    unbound-anchor -a /var/lib/unbound/root.key || true
fi

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

# Check root.hints daily; the script only downloads when older than threshold
(
    while sleep 86400; do
        /refresh-hints.sh || echo "WARNING: root.hints refresh failed" >&2
    done
) &

echo "Starting Pihole..."
exec /usr/bin/start.sh