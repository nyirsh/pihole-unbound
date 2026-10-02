#!/bin/sh
set -u

HINTS=/var/lib/unbound/root.hints
BUNDLED=/usr/share/pihole-unbound/root.hints
URL=https://www.internic.net/domain/named.root
MAX_AGE_DAYS=90
TIMEOUT=10
UPDATED=0

log() { echo "[root-hints] $*"; }
err() { echo "[root-hints] ERROR: $*" >&2; }

mkdir -p "$(dirname "$HINTS")"

if [ ! -s "$HINTS" ] || [ -n "$(find "$HINTS" -mtime +"$MAX_AGE_DAYS" 2>/dev/null)" ]; then
    log "Updating root.hints..."
    if wget -qT "$TIMEOUT" -O "$HINTS.new" "$URL" &&
       grep -q "ROOT-SERVERS" "$HINTS.new"; then
        mv "$HINTS.new" "$HINTS"
        UPDATED=1
        log "root.hints downloaded successfully."
    else
        rm -f "$HINTS.new"
        if [ -s "$HINTS" ]; then
            log "Download failed, keeping existing root.hints."
        elif [ -s "$BUNDLED" ] && cp "$BUNDLED" "$HINTS"; then
            UPDATED=1
            log "Download failed, using bundled root.hints."
        else
            err "no root.hints available (download failed and no bundled copy)."
            exit 1
        fi
    fi
else
    log "root.hints is current, nothing to do."
fi

chown unbound:unbound "$HINTS" 2>/dev/null || true
chmod 644 "$HINTS" 2>/dev/null || true

if [ "$UPDATED" = 1 ] && pgrep -x unbound >/dev/null 2>&1; then
    if unbound-control reload >/dev/null 2>&1; then
        log "Unbound reloaded via unbound-control."
    elif pkill -HUP -x unbound; then
        log "Unbound reloaded via SIGHUP."
    else
        err "could not reload Unbound; new root.hints will apply on next restart."
    fi
fi

exit 0