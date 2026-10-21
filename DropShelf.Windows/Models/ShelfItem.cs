using System;
using System.IO;
using System.Windows.Media.Imaging;

namespace DropShelf.Models;

public enum ShelfItemType
{
    File,
    Image,
    Text,
    Url
}

public class ShelfItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string? FilePath { get; set; }
    public string? StringContent { get; set; }
    public ShelfItemType Type { get; set; } = ShelfItemType.File;
    public long FileSizeBytes { get; set; }
    public DateTime AddedAt { get; set; } = DateTime.Now;

    public bool IsImage => Type == ShelfItemType.Image;

    public string IconEmoji => Type switch
    {
        ShelfItemType.Image => "🖼️",
        ShelfItemType.Url => "🌐",
        ShelfItemType.Text => "📝",
        _ => "📄"
    };

    public string FormattedSize
    {
        get
        {
            if (FileSizeBytes <= 0) return string.Empty;
            string[] sizes = ["B", "KB", "MB", "GB", "TB"];
            double len = FileSizeBytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len /= 1024;
            }
            return $"{len:0.#} {sizes[order]}";
        }
    }

    public static ShelfItem FromFile(string path)
    {
        var fileInfo = new FileInfo(path);
        var ext = fileInfo.Extension.ToLowerInvariant();
        var isImg = ext is ".png" or ".jpg" or ".jpeg" or ".gif" or ".webp" or ".bmp" or ".svg";

        return new ShelfItem
        {
            Name = fileInfo.Name,
            FilePath = fileInfo.FullName,
            Type = isImg ? ShelfItemType.Image : ShelfItemType.File,
            FileSizeBytes = fileInfo.Exists ? fileInfo.Length : 0
        };
    }

    public static ShelfItem FromText(string text)
    {
        if (Uri.TryCreate(text, UriKind.Absolute, out var uri) && (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps))
        {
            return new ShelfItem
            {
                Name = uri.Host,
                StringContent = text,
                Type = ShelfItemType.Url
            };
        }

        var preview = text.Length > 24 ? text[..24] + "..." : text;
        return new ShelfItem
        {
            Name = preview.Replace("\r", " ").Replace("\n", " "),
            StringContent = text,
            Type = ShelfItemType.Text
        };
    }
}
