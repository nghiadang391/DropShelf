using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;
using DropShelf.Models;

namespace DropShelf.Services;

public static class QuickActionService
{
    public static string? CreateZipFromItems(IReadOnlyList<ShelfItem> items, string destinationDirectory)
    {
        var validFiles = items
            .Where(i => !string.IsNullOrEmpty(i.FilePath) && File.Exists(i.FilePath))
            .Select(i => i.FilePath!)
            .ToList();

        if (validFiles.Count == 0) return null;

        var zipPath = Path.Combine(destinationDirectory, $"Archive_{DateTime.Now:yyyyMMdd_HHmmss}.zip");

        try
        {
            using var zip = ZipFile.Open(zipPath, ZipArchiveMode.Create);
            foreach (var file in validFiles)
            {
                var entryName = Path.GetFileName(file);
                zip.CreateEntryFromFile(file, entryName);
            }
            return zipPath;
        }
        catch
        {
            return null;
        }
    }

    public static async Task<string?> ExtractTextFromImageAsync(string imagePath)
    {
        if (!File.Exists(imagePath)) return null;

        try
        {
            // Windows 11 Native built-in OcrEngine
            var file = await Windows.Storage.StorageFile.GetFileFromPathAsync(imagePath);
            using var stream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read);
            var decoder = await Windows.Graphics.Imaging.BitmapDecoder.CreateAsync(stream);
            var softwareBitmap = await decoder.GetSoftwareBitmapAsync();

            var ocrEngine = Windows.Media.Ocr.OcrEngine.TryCreateFromUserProfileLanguages();
            if (ocrEngine == null) return null;

            var ocrResult = await ocrEngine.RecognizeAsync(softwareBitmap);
            return ocrResult.Text;
        }
        catch
        {
            return null;
        }
    }

    public static string? ConvertImage(string sourcePath, string targetExtension)
    {
        if (!File.Exists(sourcePath)) return null;

        try
        {
            var targetPath = Path.ChangeExtension(sourcePath, targetExtension.TrimStart('.'));
            var bitmap = new BitmapImage(new Uri(sourcePath));

            BitmapEncoder encoder = targetExtension.ToLowerInvariant() switch
            {
                ".png" or "png" => new PngBitmapEncoder(),
                ".jpg" or ".jpeg" or "jpg" => new JpegBitmapEncoder(),
                _ => new PngBitmapEncoder()
            };

            encoder.Frames.Add(BitmapFrame.Create(bitmap));
            using var stream = File.Create(targetPath);
            encoder.Save(stream);

            return targetPath;
        }
        catch
        {
            return null;
        }
    }
}
