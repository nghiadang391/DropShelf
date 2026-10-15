# DropShelf for Windows 11

A lightweight, high-performance drag-and-drop shelf utility for Windows 11 built with **C# .NET 8** and **Fluent WPF**.

---

## ✨ Features

* **Cursor Shake to Summon**: Shake your mouse cursor while dragging files in Windows Explorer to instantly summon a shelf right beside your pointer.
* **Global Shortcut**: Press **`Win + Shift + D`** (or `Ctrl + Shift + Space`) to summon a shelf anywhere.
* **True Multi-File OLE Drag & Drop**: Native Win32 `DoDragDrop` implementation. Drag multiple files out into Explorer folders, Outlook, Discord, Photoshop, or web browsers simultaneously.
* **Windows 11 Fluent Design**: Native Mica & Acrylic blur backdrop material with rounded corners (`DwmSetWindowAttribute`).
* **Built-in Windows 11 OCR**: Extract text directly from images into your clipboard using Windows 11's built-in `Windows.Media.Ocr.OcrEngine`.
* **Quick Zip Compression**: Instantly compress all staged files into a `.zip` archive directly on the shelf.
* **System Tray & Startup**: Minimize to Windows 11 taskbar corner tray with full context menu and optional "Launch at Windows Startup".
* **Single-File Portable Executable**: Zero installer, zero dependencies. Runs out of the box with ~35–45 MB RAM usage.

---

## 🛠️ Building from Source

### Prerequisites
* Windows 10 (version 2004+) or Windows 11
* [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

### Build Commands
```bash
# Navigate to Windows project directory
cd DropShelf.Windows

# Build and run in debug mode
dotnet run

# Publish single-file self-contained executable
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./dist
```
The compiled standalone binary `DropShelf.exe` will be located in the `./dist` folder.
