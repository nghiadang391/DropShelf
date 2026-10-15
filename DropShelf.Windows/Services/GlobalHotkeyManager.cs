using System;
using System.Runtime.InteropServices;
using System.Windows.Interop;

namespace DropShelf.Services;

public class GlobalHotkeyManager
{
    private const int WM_HOTKEY = 0x0312;
    private const uint MOD_ALT = 0x0001;
    private const uint MOD_CONTROL = 0x0002;
    private const uint MOD_SHIFT = 0x0004;
    private const uint MOD_WIN = 0x0008;
    private const int HOTKEY_ID = 9001;

    [DllImport("user32.dll")]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    public static GlobalHotkeyManager Instance { get; } = new();

    public event Action? OnHotkeyPressed;

    private HwndSource? _hwndSource;
    private bool _isRegistered;

    private GlobalHotkeyManager() { }

    public void Register(IntPtr hwnd)
    {
        if (_isRegistered) Unregister();

        _hwndSource = HwndSource.FromHwnd(hwnd);
        _hwndSource?.AddHook(HwndHook);

        // Default: Win + Shift + D (VK_D = 0x44)
        _isRegistered = RegisterHotKey(hwnd, HOTKEY_ID, MOD_WIN | MOD_SHIFT, 0x44);

        if (!_isRegistered)
        {
            // Fallback: Ctrl + Shift + Space (VK_SPACE = 0x20)
            _isRegistered = RegisterHotKey(hwnd, HOTKEY_ID, MOD_CONTROL | MOD_SHIFT, 0x20);
        }
    }

    public void Unregister()
    {
        if (_hwndSource != null && _isRegistered)
        {
            UnregisterHotKey(_hwndSource.Handle, HOTKEY_ID);
            _hwndSource.RemoveHook(HwndHook);
            _isRegistered = false;
        }
    }

    private IntPtr HwndHook(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
    {
        if (msg == WM_HOTKEY && wParam.ToInt32() == HOTKEY_ID)
        {
            OnHotkeyPressed?.Invoke();
            handled = true;
        }
        return IntPtr.Zero;
    }
}
