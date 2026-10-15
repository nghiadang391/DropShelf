using System.Media;

namespace DropShelf.Services;

public static class SoundService
{
    public static bool IsSoundEnabled { get; set; } = true;

    public static void PlaySpawn()
    {
        if (!IsSoundEnabled) return;
        try
        {
            SystemSounds.Asterisk.Play();
        }
        catch { }
    }

    public static void PlayDrop()
    {
        if (!IsSoundEnabled) return;
        try
        {
            SystemSounds.Beep.Play();
        }
        catch { }
    }
}
