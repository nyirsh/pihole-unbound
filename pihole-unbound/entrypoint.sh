#!/bin/sh
set -e

# Seed persistent Unbound state if missing
# This should take care of empty bind-mounted volumes
mkdir -p /var/lib/unbound /etc/unbound
[ -s /var/lib/unbound/root.hints ] || wget -qO /var/lib/unbound/root.hints https://www.internic.net/domain/named.root
[ -s /var/lib/unbound/root.key ]   || unbound-anchor -a /var/lib/unbound/root.key || true
chown -R unbound:unbound /var/lib/unbound /etc/unbound 2>/dev/null || true

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