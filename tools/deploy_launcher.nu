#!/usr/bin/env nu
# Deploy the exported launcher build to the arcade cabinet.
# Run: nu tools/deploy_launcher.nu
# Nushell port of deploy_launcher.sh — keep the two in sync.
#
# Single SSH connection: both files are streamed through stdin via tar,
# extracted to a temp dir, then renamed into place (a rename avoids the
# "Text file busy" error you get overwriting a running binary in place).

def main [] {
    let host = ($env.ARCADE_HOST? | default "arcade@172.31.78.116")
    let build_dir = ($env.FILE_PWD | path join ".." "build" | path expand)

    for f in ["launcher.x86_64" "launcher.pck"] {
        if not ($build_dir | path join $f | path exists) {
            error make {msg: $"Missing ($build_dir | path join $f) — export the project first."}
        }
    }

    let remote = r#'
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
'#

    print $">> Deploying to ($host) — single connection, one login"
    tar -C $build_dir -cf - launcher.x86_64 launcher.pck | ssh $host $remote
    print ">> Deploy complete."
}
