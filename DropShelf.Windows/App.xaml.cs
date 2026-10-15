using System;
using System.Collections.Generic;
using System.Drawing;
using System.Threading;
using System.Windows;
using DropShelf.Services;
using DropShelf.Views;

namespace DropShelf;

public partial class App : Application
{
    private static Mutex? _singleInstanceMutex;
    private static readonly List<MainWindow> _activeWindows = [];
    private static SettingsWindow? _settingsWindow;
    private Window? _dummyMessageWindow;

    protected override void OnStartup(StartupEventArgs e)
    {
        const string mutexName = "DropShelf-Windows-SingleInstance-Mutex";
        _singleInstanceMutex = new Mutex(true, mutexName, out bool isNewInstance);

        if (!isNewInstance)
        {
            // Another instance is already running
            Shutdown();
            return;
        }

        base.OnStartup(e);

        // 1. Initialize System Tray
        TrayIconManager.Instance.Initialize();
        TrayIconManager.Instance.OnNewShelfRequested += () => SpawnShelf();
        TrayIconManager.Instance.OnCloseAllRequested += CloseAllShelves;
        TrayIconManager.Instance.OnSettingsRequested += ShowSettingsWindow;
        TrayIconManager.Instance.OnQuitRequested += QuitApp;

        // 2. Initialize Dummy Window for Hotkeys (Win32 message pump)
        _dummyMessageWindow = new Window
        {
            Width = 0,
            Height = 0,
            WindowStyle = WindowStyle.None,
            ShowInTaskbar = false,
            Visibility = Visibility.Hidden
        };
        _dummyMessageWindow.Loaded += (s, args) =>
        {
            var helper = new System.Windows.Interop.WindowInteropHelper(_dummyMessageWindow);
            GlobalHotkeyManager.Instance.Register(helper.Handle);
        };
        _dummyMessageWindow.Show();

        GlobalHotkeyManager.Instance.OnHotkeyPressed += () => Dispatcher.Invoke(() => SpawnShelf());

        // 3. Initialize Mouse Shake Detector
        MouseShakeDetector.Instance.OnShakeDetected += (pt) =>
        {
            Dispatcher.Invoke(() => SpawnShelf(new System.Windows.Point(pt.X, pt.Y)));
        };
        MouseShakeDetector.Instance.OnMouseRelease += (pt) =>
        {
            Dispatcher.Invoke(() => HandleMouseRelease(new System.Windows.Point(pt.X, pt.Y)));
        };
        MouseShakeDetector.Instance.Start();
    }

    public static void SpawnShelf(System.Windows.Point? position = null)
    {
        var window = new MainWindow(position);
        window.Closed += (s, e) => _activeWindows.Remove(window);
        _activeWindows.Add(window);
        window.Show();
        window.Activate();
    }

    public static void CloseAllShelves()
    {
        for (int i = _activeWindows.Count - 1; i >= 0; i--)
        {
            _activeWindows[i].CloseWithFade();
        }
    }

    private static void HandleMouseRelease(System.Windows.Point point)
    {
        for (int i = _activeWindows.Count - 1; i >= 0; i--)
        {
            var win = _activeWindows[i];
            if (win.Shelf.Items.Count == 0 && !win.Shelf.IsPinned)
            {
                win.CloseWithFade();
            }
        }
    }

    public static void ShowSettingsWindow()
    {
        if (_settingsWindow == null || !_settingsWindow.IsLoaded)
        {
            _settingsWindow = new SettingsWindow();
            _settingsWindow.Closed += (s, e) => _settingsWindow = null;
        }
        _settingsWindow.Show();
        _settingsWindow.Activate();
    }

    public static void QuitApp()
    {
        TrayIconManager.Instance.Dispose();
        MouseShakeDetector.Instance.Stop();
        GlobalHotkeyManager.Instance.Unregister();
        _singleInstanceMutex?.ReleaseMutex();
        Current.Shutdown();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        TrayIconManager.Instance.Dispose();
        MouseShakeDetector.Instance.Stop();
        GlobalHotkeyManager.Instance.Unregister();
        _singleInstanceMutex?.Dispose();
        base.OnExit(e);
    }
}
