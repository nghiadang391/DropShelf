using System;
using System.Collections.Generic;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;

namespace DropShelf.Services;

public class MouseShakeDetector
{
    private const int VK_LBUTTON = 0x01;

    [StructLayout(LayoutKind.Sequential)]
    private struct POINT
    {
        public int X;
        public int Y;
    }

    [DllImport("user32.dll")]
    private static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    private static extern bool GetCursorPos(out POINT lpPoint);

    public static MouseShakeDetector Instance { get; } = new();

    public event Action<Point>? OnShakeDetected;
    public event Action<Point>? OnMouseRelease;

    public bool IsDraggingFromShelf { get; set; }

    private readonly Timer _timer;
    private readonly List<(Point Point, long TimeMs)> _history = [];
    private bool _wasLeftDown;
    private bool _hasTriggeredInCurrentDrag;
    private long _lastTriggerTimeMs;
    private const long CooldownMs = 1000;

    private MouseShakeDetector()
    {
        // 60Hz polling timer (~16ms)
        _timer = new Timer(Tick, null, Timeout.Infinite, Timeout.Infinite);
    }

    public void Start()
    {
        _timer.Change(0, 16);
    }

    public void Stop()
    {
        _timer.Change(Timeout.Infinite, Timeout.Infinite);
    }

    private void Tick(object? state)
    {
        bool isLeftDown = (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
        long now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        if (!GetCursorPos(out var pt)) return;
        var currentPoint = new Point(pt.X, pt.Y);

        // Detect mouse release transition
        if (_wasLeftDown && !isLeftDown)
        {
            _wasLeftDown = false;
            _hasTriggeredInCurrentDrag = false;
            IsDraggingFromShelf = false;
            _history.Clear();

            OnMouseRelease?.Invoke(currentPoint);
            return;
        }

        _wasLeftDown = isLeftDown;

        if (!isLeftDown) return;
        if (IsDraggingFromShelf) return;
        if (_hasTriggeredInCurrentDrag) return;
        if (now - _lastTriggerTimeMs < CooldownMs) return;

        _history.Add((currentPoint, now));

        // Keep 350ms history window
        _history.RemoveAll(h => now - h.TimeMs > 350);

        if (_history.Count < 4) return;

        if (DetectShake())
        {
            _lastTriggerTimeMs = now;
            _hasTriggeredInCurrentDrag = true;
            _history.Clear();

            OnShakeDetected?.Invoke(currentPoint);
        }
    }

    private bool DetectShake()
    {
        if (_history.Count < 4) return false;

        int directionChanges = 0;
        int lastDx = 0;
        const int minStep = 8;

        for (int i = 1; i < _history.Count; i++)
        {
            int dx = _history[i].Point.X - _history[i - 1].Point.X;

            if (Math.Abs(dx) >= minStep)
            {
                if ((dx > 0 && lastDx < 0) || (dx < 0 && lastDx > 0))
                {
                    directionChanges++;
                }
                lastDx = dx;
            }
        }

        return directionChanges >= 2;
    }
}
