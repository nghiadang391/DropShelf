# DropShelf

DropShelf is a floating drag-and-drop shelf for macOS and Windows.

Hold files, images, links, or text snippets on temporary floating shelves while switching apps, workspaces, or full-screen windows.

## Downloads

| Platform | Download | Format |
|---|---|---|
| **macOS** (13.0+) | [DropShelf-v1.0.0-macOS.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-v1.0.0-macOS.zip) | Universal `.app` |
| **Windows 11** | [DropShelf-Windows-v1.1.1.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-Windows-v1.1.1.zip) | Portable single-file `.exe` |

For older releases, see the [Releases](https://github.com/nghiadang391/DropShelf/releases) page.

## How It Works

1. **Summon a shelf**: Shake your mouse while dragging any file, or press the hotkey:
   - macOS: `Option + Space`
   - Windows: `Win + Shift + D` (or `Ctrl + Shift + Space`)
2. **Drop items**: Files stack on the shelf until you are ready for them.
3. **Inspect or manage**: Click the item count pill to expand into a grid view with file names, sizes, and quick delete buttons.
4. **Drag out**: Drag the entire stack or individual items into Finder, Explorer, Slack, Discord, or web apps (GitLab, GitHub, email).
5. **Auto-dismiss**: Drop shelves vanish once emptied, unless pinned.

## Features

- **Shake to summon**: Automatically opens beside your cursor during a drag operation.
- **Multi-file stack & grid**: Groups files in a compact stack, expandable into a detailed 2-column grid.
- **Web & cloud drop support**: Fully compatible with browser upload targets, Monaco Editor, and cloud IDEs.
- **On-device OCR**: Extract text from images on the shelf (Apple Vision on macOS, Windows OCR on Windows).
- **Archive tool**: Zip shelf contents in one click.
- **Native UI**: Uses native vibrancy on macOS (Swift/SwiftUI) and Mica blur on Windows 11 (.NET 8/WPF).
- **System tray / Menu bar**: Quick access from the menu bar / tray with run-at-startup option.

## Building from Source

### macOS

Requires macOS 13.0+ and Xcode Command Line Tools.

```bash
git clone https://github.com/nghiadang391/DropShelf.git
cd DropShelf
./bundle.sh
open DropShelf.app
```

### Windows

Requires Windows 10 (2004+) or Windows 11, and [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0).

```bash
cd DropShelf.Windows

# Run
dotnet run

# Build self-contained release executable
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./dist
```

## License

MIT
