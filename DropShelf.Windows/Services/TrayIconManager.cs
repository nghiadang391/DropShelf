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
            Icon = LoadTrayIcon(),
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

    private static Icon LoadTrayIcon()
    {
        try
        {
            var assembly = typeof(TrayIconManager).Assembly;
            var resourceName = Array.Find(assembly.GetManifestResourceNames(), n => n.EndsWith("app.ico", StringComparison.OrdinalIgnoreCase)) ?? "DropShelf.Assets.app.ico";
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream != null)
            {
                return new Icon(stream, SystemInformation.SmallIconSize);
            }
        }
        catch
        {
            // Fallback
        }

        try
        {
            if (!string.IsNullOrEmpty(Environment.ProcessPath))
            {
                var extracted = Icon.ExtractAssociatedIcon(Environment.ProcessPath);
                if (extracted != null) return extracted;
            }
        }
        catch
        {
            // Fallback
        }

        return SystemIcons.Application;
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
