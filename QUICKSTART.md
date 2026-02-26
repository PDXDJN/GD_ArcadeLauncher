# Quick Start Guide

Get the c-base Arcade Launcher running in 5 minutes.

## For Developers (Testing Locally)

### 1. Open in Godot 4.5

```bash
# Open Godot 4.5
# File → Open Project
# Select: GD_ArcadeLauncher/project.godot
```

### 2. Create Test Game Directory Structure

Since `/arcade/games` won't exist on your dev machine, temporarily modify the paths for testing:

**Option A:** Create local test directory

```bash
# Linux/Mac
mkdir -p /tmp/arcade/games /tmp/arcade/scores

# Windows (in Godot, edit scripts/GameScanner.gd)
# Change: const GAMES_DIR := "/arcade/games"
# To: const GAMES_DIR := "C:/temp/arcade/games"
```

**Option B:** Use res:// paths for development

Edit `scripts/GameScanner.gd` and `scripts/ScoreStore.gd`:

```gdscript
# Development mode
const GAMES_DIR := "res://test_games"
const SCORES_DIR := "res://test_scores"
```

Then create test folders:
```bash
mkdir test_games test_scores
```

### 3. Run the Launcher

Press **F5** or click the **Play** button in Godot.

You should see:
- Boot sequence (if enabled)
- Main launcher UI
- "No games found" message

### 4. Add a Test Game

Create a dummy game folder for testing:

```bash
# Linux/Mac
mkdir -p /tmp/arcade/games/test_game
touch /tmp/arcade/games/test_game/game.x86_64
touch /tmp/arcade/games/test_game/game.pck
echo '{"title":"Test Game","author":"Developer","description":"Testing","players":1,"year":2024}' > /tmp/arcade/games/test_game/game.json
```

The game should appear in the launcher within a few seconds (if live reload is working).

## For Cabinet Installation

See [INSTALL.md](INSTALL.md) for complete Ubuntu setup instructions.

### Summary

1. Set up Ubuntu with X11
2. Create `/arcade` directory structure
3. Export launcher from Godot (Linux/X11 target)
4. Copy files to `/arcade/launcher/`
5. Install systemd services
6. Reboot

## For Game Developers

See [GAME_SPEC.md](GAME_SPEC.md) for complete game upload specification.

### Minimum Game Requirements

1. **Export for Linux x86_64** in Godot
2. **Files needed:**
   - `game.x86_64` (or `.AppImage`)
   - `game.pck`
3. **Must implement:** `ui_exit` input action to quit
4. **Recommended:** Add `game.json`, `screenshot.png`, `icon.png`

### Test Your Game

```bash
# Upload via SFTP
sftp arcade@<cabinet-ip>
cd /arcade/games
put -r my_game/

# Or use SCP
scp -r my_game/ arcade@<cabinet-ip>:/arcade/games/
```

Game appears automatically within 1-2 seconds.

## Project Structure Overview

```
GD_ArcadeLauncher/
├── project.godot              # Godot project file
├── icon.svg                   # Project icon
│
├── scenes/                    # Godot scenes
│   ├── Boot.tscn             # Boot sequence (optional)
│   ├── Launcher.tscn         # Main launcher UI
│   └── GameEntry.tscn        # Game list item template
│
├── scripts/                   # GDScript files
│   ├── Boot.gd               # Boot sequence controller
│   ├── Launcher.gd           # Main launcher controller
│   ├── GameInfo.gd           # Game data model
│   ├── GameScanner.gd        # Directory scanner
│   └── ScoreStore.gd         # High score manager
│
├── media/                     # Assets (sounds, fonts, shaders)
│   ├── sounds/
│   ├── fonts/
│   └── shaders/
│
├── tools/                     # Host scripts
│   └── watch_games.sh        # inotify watcher
│
├── install/                   # Installation files
│   └── systemd/
│       ├── arcade-launcher.service
│       └── arcade-watch.service
│
├── example_game/              # Template for game uploads
│   ├── game.json
│   └── README.md
│
└── Documentation
    ├── README.md              # Project overview
    ├── INSTALL.md             # Ubuntu installation guide
    ├── GAME_SPEC.md           # Game upload specification
    └── QUICKSTART.md          # This file
```

## Common Tasks

### Change Main Scene

Edit `project.godot`:
```ini
run/main_scene="res://scenes/Boot.tscn"      # Start with boot sequence
run/main_scene="res://scenes/Launcher.tscn"  # Skip boot, go direct to launcher
```

### Test Without Boot Sequence

In Godot editor:
- Open `scenes/Launcher.tscn`
- Click **Play Scene** (F6) instead of **Play Project** (F5)

### Add Custom Theme

1. Create theme in Godot editor (Theme → New Theme)
2. Save as `res://media/arcade_theme.tres`
3. Apply to Launcher.tscn root node

### Add UI Sounds

```gdscript
# In Launcher.gd
@onready var ui_sfx: AudioStreamPlayer = $UiSfx

func _play_sound(sound_name: String) -> void:
    ui_sfx.stream = load("res://media/sounds/%s.ogg" % sound_name)
    ui_sfx.play()

func _navigate_list(direction: int) -> void:
    _play_sound("beep")  # Add this
    # ... rest of navigation code
```

### Export for Linux

1. **Project → Export**
2. **Add preset:** Linux/X11
3. **Configure:**
   - Runnable: ✓
   - Export Path: `builds/linux/launcher.x86_64`
   - 64 bits: ✓
4. **Export Project**

### Debug on Ubuntu Cabinet

```bash
# SSH into cabinet
ssh arcade@<cabinet-ip>

# Stop service
sudo systemctl stop arcade-launcher.service

# Run manually to see output
cd /arcade/launcher
./launcher.x86_64

# Check for errors in console

# Restart service when done
sudo systemctl start arcade-launcher.service
```

## Keyboard Shortcuts (Development)

When testing in Godot editor:

- **↑↓** - Navigate game list
- **Enter/Space** - Launch selected game (won't work in editor)
- **Escape** - Cancel/back
- **F5** - Run project
- **F6** - Run current scene
- **F8** - Step through breakpoints

## Next Steps

1. **Customize theme:** Edit colors, fonts, layout in `Launcher.tscn`
2. **Add sounds:** Place audio files in `media/sounds/`
3. **Add boot animation:** Enhance `Boot.tscn` with effects
4. **Create test games:** Build simple Godot games to test
5. **Deploy to cabinet:** Follow [INSTALL.md](INSTALL.md)

## Troubleshooting

### "No games found"

- Check `GAMES_DIR` path in `GameScanner.gd`
- Ensure directory exists and has test games
- Verify game folders have `.x86_64` and `.pck` files

### Preview video doesn't play

- Use `.ogv` (Ogg Theora) format instead of MP4
- Check video file path in game folder
- Verify Godot has VideoStreamTheora support

### Live reload not working

- Check `/tmp/arcade_event` file creation
- Verify `watch_games.sh` is running
- Test manually: `echo "test" > /tmp/arcade_event`

### Game won't launch (in production)

- Verify executable permissions: `chmod +x game.x86_64`
- Check both `.x86_64` and `.pck` exist
- Review launcher logs: `sudo journalctl -u arcade-launcher.service`

## Resources

- **Godot Docs:** https://docs.godotengine.org/
- **GDScript Reference:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **Godot Export Guide:** https://docs.godotengine.org/en/stable/tutorials/export/

## Support

- GitHub Issues: [repository URL]
- Read [INSTALL.md](INSTALL.md) for deployment help
- Read [GAME_SPEC.md](GAME_SPEC.md) for game development help

---

**Ready to build arcade games! 🎮**
