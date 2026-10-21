using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Windows;
using DropShelf.Models;

namespace DropShelf.Utils;

public static class ShellDragHelper
{
    public static DragDropEffects StartDrag(DependencyObject dragSource, IReadOnlyList<ShelfItem> items)
    {
        if (items.Count == 0) return DragDropEffects.None;

        var dataObject = new DataObject();
        var filePaths = items
            .Where(i => !string.IsNullOrEmpty(i.FilePath) && File.Exists(i.FilePath))
            .Select(i => i.FilePath!)
            .ToList();

        if (filePaths.Count > 0)
        {
            // 1. Native Windows CF_HDROP format
            dataObject.SetData(DataFormats.FileDrop, filePaths.ToArray());

            // 2. Set Preferred DropEffect for Chromium/Edge and web cloud drop-zones
            var dropEffectBytes = BitConverter.GetBytes((int)DragDropEffects.Copy);
            var dropEffectStream = new MemoryStream(dropEffectBytes);
            dataObject.SetData("Preferred DropEffect", dropEffectStream);
        }
        else
        {
            // Text or URL items
            var textItems = items.Select(i => i.StringContent ?? i.Name);
            var combined = string.Join(Environment.NewLine, textItems);
            dataObject.SetText(combined);
        }

        try
        {
            return DragDrop.DoDragDrop(dragSource, dataObject, DragDropEffects.Copy | DragDropEffects.Move);
        }
        catch
        {
            return DragDropEffects.None;
        }
    }
}
