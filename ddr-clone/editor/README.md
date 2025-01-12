# Simple Beatmap Editor

A lightweight, text-based editor for creating DDR Clone beatmaps.

## Features

- Simple, text-based interface
- Precise timestamp display for each note
- Easy note deletion
- Real-time playback with note highlighting
- Exports beatmaps in game-compatible format

## How to Use

1. Open `index.html` in a web browser
2. Click "Choose File" and select your MP3 file
3. Use arrow keys to add notes while music plays:
   - ← Left arrow
   - ↓ Down arrow
   - ↑ Up arrow
   - → Right arrow
4. Click the × button next to any note to delete it
5. Click "Save Beatmap" to export your pattern file

## Controls

- **Arrow Keys**: Add notes at the current time
- **Spacebar**: Play/Pause music
- **Stop Button**: Reset playback
- **Save Button**: Export beatmap

## Tips

- Play the music and press arrow keys in time with the beats
- Notes are automatically sorted by timestamp
- The current note is highlighted during playback
- You can delete any note by clicking the × button
- The exported file will be named `[songname]_pattern.lua`

## Integration with Game

1. Save your beatmap using the "Save Beatmap" button
2. Copy the exported `[songname]_pattern.lua` file to your game's songs directory
3. Copy the MP3 file to the game's assets directory
4. The new song and beatmap will be available in the game