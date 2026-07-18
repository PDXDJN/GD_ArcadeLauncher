#!/bin/bash
# Deploy the exported launcher build to the arcade cabinet.
# Run from Git Bash / Linux: bash tools/deploy_launcher.sh
# Keep in sync with deploy_launcher.nu.
#
# Single SSH connection: both files are streamed through stdin via tar,
# extracted to a temp dir, then renamed into place (a rename avoids the
# "Text file busy" error you get overwriting a running binary in place).
set -euo pipefail

HOST="${ARCADE_HOST:-arcade@172.31.78.116}"
BUILD_DIR="$(cd "$(dirname "$0")/../build" && pwd)"

for f in launcher.x86_64 launcher.pck; do
  [ -f "$BUILD_DIR/$f" ] || { echo "Missing $BUILD_DIR/$f — export the project first." >&2; exit 1; }
done

REMOTE='
set -e
D=/arcade/launcher
mkdir -p "$D/.new"
tar -xf - -C "$D/.new"
chmod +x "$D/.new/launcher.x86_64"
mv -f "$D/.new/launcher.x86_64" "$D/launcher.x86_64"
mv -f "$D/.new/launcher.pck"    "$D/launcher.pck"
rmdir "$D/.new"
echo ">> files installed in $D"
pids=$(pgrep -x launcher.x86_64 || true)
if [ -z "$pids" ]; then
    echo ">> launcher not running — nothing to restart"
elif kill $pids 2>/dev/null; then
    echo ">> launcher stopped (pid $pids); systemd will respawn it with the new build"
else
    owner=$(ps -o user= -p $(echo $pids | cut -d" " -f1))
    echo ">> WARN: cannot signal launcher pid $pids — it runs as user $owner, not $(whoami)."
    echo ">>       New build is deployed but NOT live. Restart it as that user, e.g.:"
    echo ">>       sudo systemctl restart arcade-launcher"
fi
'

echo ">> Deploying to $HOST — single connection, one login"
tar -C "$BUILD_DIR" -cf - launcher.x86_64 launcher.pck | ssh "$HOST" "$REMOTE"
echo ">> Deploy complete."
