# Example Game Folder

This folder demonstrates the structure of a game upload for the c-base Arcade Launcher.

## Required Files (you must add these)

1. **game.x86_64** or **game.AppImage** - Your Linux executable
2. **game.pck** - Your Godot pack file

## Optional Files (highly recommended)

3. **game.json** - Metadata (see example in this folder)
4. **preview.ogv** or **preview.mp4** - 5-15 second gameplay video
5. **screenshot.png** - Fallback image (1920x1080 recommended)
6. **icon.png** - Small icon for list (128x128 recommended)

## How to Use This Template

1. Copy this folder to create your game folder
2. Add your `.x86_64` and `.pck` files
3. Edit `game.json` with your game's information
4. Add your screenshot, icon, and preview video
5. Upload to `/arcade/games/` on the cabinet

## Important Reminders

- Your game MUST implement the `ui_exit` input action to quit and return to launcher
- Test on Linux before uploading
- Make sure your executable has execute permissions: `chmod +x game.x86_64`

For complete documentation, see [GAME_SPEC.md](../GAME_SPEC.md)
