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
            var stringCollection = new StringCollection();
            stringCollection.AddRange(filePaths.ToArray());
            dataObject.SetFileDropList(stringCollection);

            // Also set text representation for Terminal / Text editors
            var combinedText = string.Join(Environment.NewLine, filePaths);
            dataObject.SetText(combinedText);
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
