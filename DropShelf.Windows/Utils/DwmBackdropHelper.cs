using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace DropShelf.Utils;

public static class DwmBackdropHelper
{
    private const int DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    private const int DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    private const int DWMWA_SYSTEMBACKDROP_TYPE = 38;

    public enum BackdropType
    {
        Auto = 0,
        None = 1,
        MainWindow = 2, // Mica
        TransientWindow = 3, // Acrylic
        TabbedWindow = 4 // Mica Alt
    }

    public enum CornerPreference
    {
        Default = 0,
        DoNotRound = 1,
        Round = 2,
        RoundSmall = 3
    }

    [DllImport("dwmapi.dll", PreserveSig = true)]
    private static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);

    public static void EnableWindows11FluentTheme(Window window, BackdropType backdrop = BackdropType.TransientWindow)
    {
        var helper = new WindowInteropHelper(window);
        var hwnd = helper.EnsureHandle();

        if (hwnd == IntPtr.Zero) return;

        try
        {
            // 1. Enable Immersive Dark Mode
            int darkMode = 1;
            DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, ref darkMode, sizeof(int));

            // 2. Enable Rounded Corners (Windows 11)
            int corner = (int)CornerPreference.Round;
            DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, ref corner, sizeof(int));

            // 3. Enable System Backdrop (Mica / Acrylic)
            int backdropValue = (int)backdrop;
            DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, ref backdropValue, sizeof(int));
        }
        catch
        {
            // Fallback gracefully on pre-Windows 11 builds
        }
    }
}
