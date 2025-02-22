#!/bin/sh
set -e  # Exit on error

# Start Unbound in the foreground
echo "Starting Unbound..."
unbound -d &

echo "Starting Pihole..."
# Start pihole
exec /usr/bin/start.sh