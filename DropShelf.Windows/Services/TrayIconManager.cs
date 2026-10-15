using System;
using System.Drawing;
using System.Windows.Forms;
using Application = System.Windows.Application;

namespace DropShelf.Services;

public class TrayIconManager : IDisposable
{
    public static TrayIconManager Instance { get; } = new();

    private NotifyIcon? _notifyIcon;
    public event Action? OnNewShelfRequested;
    public event Action? OnCloseAllRequested;
    public event Action? OnSettingsRequested;
    public event Action? OnQuitRequested;

    private TrayIconManager() { }

    public void Initialize()
    {
        if (_notifyIcon != null) return;

        var contextMenu = new ContextMenuStrip();
        contextMenu.Items.Add(new ToolStripMenuItem("New Shelf (Win + Shift + D)", null, (s, e) => OnNewShelfRequested?.Invoke()));
        contextMenu.Items.Add(new ToolStripMenuItem("Close All Shelves", null, (s, e) => OnCloseAllRequested?.Invoke()));
        contextMenu.Items.Add(new ToolStripSeparator());
        contextMenu.Items.Add(new ToolStripMenuItem("Settings...", null, (s, e) => OnSettingsRequested?.Invoke()));
        contextMenu.Items.Add(new ToolStripSeparator());
        contextMenu.Items.Add(new ToolStripMenuItem("Quit DropShelf", null, (s, e) => OnQuitRequested?.Invoke()));

        _notifyIcon = new NotifyIcon
        {
            Icon = SystemIcons.Application,
            Text = "DropShelf for Windows 11",
            ContextMenuStrip = contextMenu,
            Visible = true
        };

        _notifyIcon.MouseClick += (s, e) =>
        {
            if (e.Button == MouseButtons.Left)
            {
                OnNewShelfRequested?.Invoke();
            }
        };
    }

    public void SetVisible(bool isVisible)
    {
        if (_notifyIcon != null)
        {
            _notifyIcon.Visible = isVisible;
        }
    }

    public void Dispose()
    {
        _notifyIcon?.Dispose();
        _notifyIcon = null;
    }
}
