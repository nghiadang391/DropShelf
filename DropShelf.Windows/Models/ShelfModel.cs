using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace DropShelf.Models;

public class ShelfModel : INotifyPropertyChanged
{
    private bool _isPinned;
    private bool _isExpanded;

    public Guid Id { get; } = Guid.NewGuid();
    public ObservableCollection<ShelfItem> Items { get; } = [];

    public bool IsPinned
    {
        get => _isPinned;
        set { SetField(ref _isPinned, value); }
    }

    public bool IsExpanded
    {
        get => _isExpanded;
        set { SetField(ref _isExpanded, value); }
    }

    public void AddItem(ShelfItem item)
    {
        Items.Add(item);
        OnPropertyChanged(nameof(ItemCountText));
    }

    public void AddItems(IEnumerable<ShelfItem> items)
    {
        foreach (var item in items)
        {
            Items.Add(item);
        }
        OnPropertyChanged(nameof(ItemCountText));
    }

    public void RemoveItem(Guid id)
    {
        for (int i = Items.Count - 1; i >= 0; i--)
        {
            if (Items[i].Id == id)
            {
                Items.RemoveAt(i);
                break;
            }
        }
        OnPropertyChanged(nameof(ItemCountText));
    }

    public void Clear()
    {
        Items.Clear();
        OnPropertyChanged(nameof(ItemCountText));
    }

    public string ItemCountText => $"{Items.Count} File{(Items.Count == 1 ? "" : "s")}";

    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    protected bool SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value)) return false;
        field = value;
        OnPropertyChanged(propertyName);
        return true;
    }
}
