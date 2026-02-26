#!/bin/bash
# watch_games.sh - Monitor /arcade/games for changes and signal launcher
set -e

GAMES_DIR="/arcade/games"
EVENT_FILE="/tmp/arcade_event"

# Check if inotifywait is installed
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed. Please install inotify-tools:"
    echo "  sudo apt-get install inotify-tools"
    exit 1
fi

# Check if games directory exists
if [ ! -d "$GAMES_DIR" ]; then
    echo "Warning: $GAMES_DIR does not exist. Creating it..."
    mkdir -p "$GAMES_DIR"
fi

echo "Watching $GAMES_DIR for changes..."

# Monitor recursively for create, delete, move, and write events
inotifywait -m -r -e create,delete,move,close_write "$GAMES_DIR" --format '%w%f' | while read path; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Change detected: $path"
    echo "games_changed" > "$EVENT_FILE"
done
