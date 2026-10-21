# DropShelf

A lightweight, native desktop drag-and-drop shelf utility for **macOS** and **Windows 11**. DropShelf holds files, images, links, and text snippets on floating shelves so you can navigate between apps, workspaces, and full-screen windows without losing your drag session.

---

## 💻 Platform Overview

| Platform | Tech Stack | UI & Backdrop Material | Drag & Drop Engine | Packaging |
| :--- | :--- | :--- | :--- | :--- |
| **macOS** | Swift 5.9+, SwiftUI, AppKit | Translucent Vibrancy HUD | Native `NSDraggingSource` & `NSPasteboard` | `DropShelf.app` (Universal) |
| **Windows 11** | C# .NET 8, Fluent WPF | Windows 11 Mica & Acrylic (`DwmSetWindowAttribute`) | Native Win32 OLE `DoDragDrop` (`CF_HDROP`) | Portable single-file `DropShelf.exe` |

---

## ✨ Features

* **Cursor Shake to Summon**: Shake your mouse cursor while dragging files to summon a shelf directly beside your pointer.
* **Floating HUD Shelves**: Always-on-top floating utility panels (`NSPanel` / `WS_EX_TOPMOST`) that stay accessible across full-screen spaces and virtual desktops.
* **Stacked Cards & Expandable Grid**:
  * Files automatically group into a compact card stack with natural rotation.
  * Click the bottom file count pill to expand into a full 2-column grid showing all file names, formatted sizes, and individual delete buttons.
* **True Multi-File Drag-Out**:
  * Grab the entire stack or bottom pill to drop all files at once into Finder, Windows Explorer, Slack, Discord, email, or browsers.
  * Drag individual items out from the expanded grid view.
  * Full compatibility with cloud drop-zones and web editors (GitLab Cloud IDE, GitHub, Monaco Editor).
* **Drag-Back Restoration**: If you drag files out and change your mind, dropping them back into the shelf restores them immediately. Releasing files elsewhere cleanly dismisses empty unpinned shelves.
* **Global Hotkeys**:
  * macOS: **`Option + Space`**
  * Windows: **`Win + Shift + D`** (or `Ctrl + Shift + Space`)
* **Quick Tools**:
  * **On-Device OCR**: Extract text from images and screenshots directly to the clipboard (Apple Vision on macOS, `Windows.Media.Ocr` on Windows 11).
  * **Zip Compression**: One-click compression of all shelf items into a single archive.
  * **Background Removal & EXIF Scrubbing** (macOS): One-click subject cutout and photo metadata stripping.
* **Menu Bar & System Tray**: Runs in the macOS Menu Bar / Windows Taskbar Tray with an option to toggle tray visibility in Settings.
* **Launch at Startup**: Optional run-at-login integration (`SMAppService` on macOS, Registry on Windows).

---

## 📦 Downloads & Installation

### macOS
1. Download **[DropShelf-v1.0.0-macOS.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-v1.0.0-macOS.zip)**.
2. Unzip and move `DropShelf.app` to your `/Applications` folder.
3. *First launch*: Right-click `DropShelf.app`, select **Open**, and click **Open**.

### Windows 11
1. Download **[DropShelf-Windows-v1.1.0.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-Windows-v1.1.0.zip)**.
2. Extract the archive and run `DropShelf.exe`.
3. *Zero installation*: Portable single-file executable (~35–45 MB RAM) with no runtime dependencies.

---

## 🛠️ Building from Source

### macOS (Swift)
**Prerequisites**: macOS 13.0+ and Xcode Command Line Tools.
```bash
git clone https://github.com/nghiadang391/DropShelf.git
cd DropShelf
./bundle.sh
open DropShelf.app
```

### Windows 11 (C# .NET 8)
**Prerequisites**: Windows 10 (2004+) or Windows 11, and [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0).
```bash
cd DropShelf.Windows
# Run locally
dotnet run

# Publish standalone single-file binary
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./dist
```

---

## 📁 Repository Layout

```text
DropShelf/
├── Sources/                      # macOS Swift/SwiftUI implementation
│   ├── App/                      # AppDelegate, MenuBarManager
│   ├── Models/                   # ShelfItem, ShelfModel
│   ├── Services/                 # MouseShakeDetector, GlobalHotkeyManager, QuickActionService
│   ├── Utils/                    # DragItemProviderHelper, MultiItemDragSourceView, WindowDragArea
│   └── Views/                    # ShelfView, StackedCardsView, ExpandedItemsGridView, PreferencesView
├── Tests/                        # macOS XCTest test suite
├── bundle.sh                     # macOS Universal release packaging script
├── DropShelf.Windows/            # Windows 11 C# .NET 8 implementation
│   ├── App.xaml / App.xaml.cs    # Application lifecycle & Mutex
│   ├── Models/                   # ShelfItem, ShelfModel
│   ├── Services/                 # MouseShakeDetector, GlobalHotkeyManager, TrayIconManager
│   ├── Utils/                    # DwmBackdropHelper, ShellDragHelper
│   ├── Views/                    # MainWindow (Shelf), SettingsWindow
│   └── DropShelf.Windows.csproj  # .NET 8 Desktop SDK project file
└── .github/workflows/
    └── windows-release.yml       # GitHub Actions CI/CD pipeline for Windows .exe builds
```

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
