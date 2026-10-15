using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using DropShelf.Models;
using DropShelf.Services;
using DropShelf.Utils;

namespace DropShelf.Views;

public partial class MainWindow : Window
{
    public ShelfModel Shelf { get; } = new();
    private Point? _dragStartPoint;
    private List<ShelfItem>? _stagedDragItems;

    public MainWindow(Point? initialPosition = null)
    {
        InitializeComponent();

        if (initialPosition.HasValue)
        {
            Left = initialPosition.Value.X - 110;
            Top = initialPosition.Value.Y - 125;
        }
        else
        {
            // Center around cursor
            var mousePos = System.Windows.Forms.Cursor.Position;
            Left = mousePos.X - 110;
            Top = mousePos.Y - 125;
        }

        Shelf.Items.CollectionChanged += (s, e) => UpdateUI();
    }

    private void Window_Loaded(object sender, RoutedEventArgs e)
    {
        DwmBackdropHelper.EnableWindows11FluentTheme(this);
        SoundService.PlaySpawn();
        UpdateUI();
    }

    private void Header_MouseDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            DragMove();
        }
    }

    private void PinButton_Click(object sender, RoutedEventArgs e)
    {
        Shelf.IsPinned = !Shelf.IsPinned;
        PinButton.Foreground = Shelf.IsPinned ? new SolidColorBrush(Color.FromRgb(59, 130, 246)) : new SolidColorBrush(Color.FromArgb(0xCC, 0xFF, 0xFF, 0xFF));
    }

    private void CloseButton_Click(object sender, RoutedEventArgs e)
    {
        CloseWithFade();
    }

    public void CloseWithFade()
    {
        var anim = new DoubleAnimation(0.0, TimeSpan.FromMilliseconds(180));
        anim.Completed += (s, e) => Close();
        BeginAnimation(OpacityProperty, anim);
    }

    #region Drag & Drop In (Add items to shelf)

    private void Border_DragEnter(object sender, DragEventArgs e)
    {
        if (e.Data.GetDataPresent(DataFormats.FileDrop) || e.Data.GetDataPresent(DataFormats.Text))
        {
            e.Effects = DragDropEffects.Copy;
        }
        else
        {
            e.Effects = DragDropEffects.None;
        }
        e.Handled = true;
    }

    private void Border_DragOver(object sender, DragEventArgs e)
    {
        Border_DragEnter(sender, e);
    }

    private void Border_Drop(object sender, DragEventArgs e)
    {
        if (e.Data.GetDataPresent(DataFormats.FileDrop))
        {
            if (e.Data.GetData(DataFormats.FileDrop) is string[] files)
            {
                foreach (var file in files)
                {
                    Shelf.AddItem(ShelfItem.FromFile(file));
                }
                SoundService.PlayDrop();
            }
        }
        else if (e.Data.GetDataPresent(DataFormats.Text))
        {
            if (e.Data.GetData(DataFormats.Text) is string text)
            {
                Shelf.AddItem(ShelfItem.FromText(text));
                SoundService.PlayDrop();
            }
        }
        e.Handled = true;
    }

    #endregion

    #region Drag Out (Drag items out of shelf)

    private void CardsCanvas_MouseDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            _dragStartPoint = e.GetPosition(this);
        }
    }

    private void CardsCanvas_MouseMove(object sender, MouseEventArgs e)
    {
        if (e.LeftButton != MouseButtonState.Pressed || !_dragStartPoint.HasValue) return;

        var currentPoint = e.GetPosition(this);
        var diff = _dragStartPoint.Value - currentPoint;

        if (Math.Abs(diff.X) > 4 || Math.Abs(diff.Y) > 4)
        {
            _dragStartPoint = null;
            InitiateMultiItemDrag();
        }
    }

    private void BottomPill_MouseDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            _dragStartPoint = e.GetPosition(this);
        }
    }

    private void BottomPill_MouseMove(object sender, MouseEventArgs e)
    {
        if (e.LeftButton != MouseButtonState.Pressed || !_dragStartPoint.HasValue) return;

        var currentPoint = e.GetPosition(this);
        var diff = _dragStartPoint.Value - currentPoint;

        if (Math.Abs(diff.X) > 4 || Math.Abs(diff.Y) > 4)
        {
            _dragStartPoint = null;
            InitiateMultiItemDrag();
        }
    }

    private void InitiateMultiItemDrag()
    {
        if (Shelf.Items.Count == 0) return;

        var currentItems = Shelf.Items.ToList();
        _stagedDragItems = currentItems;
        MouseShakeDetector.Instance.IsDraggingFromShelf = true;

        // Clear shelf immediately for responsive feedback
        Shelf.Clear();

        var effects = ShellDragHelper.StartDrag(this, currentItems);

        // After drag finishes:
        MouseShakeDetector.Instance.IsDraggingFromShelf = false;

        var cursorPoint = System.Windows.Forms.Cursor.Position;
        var windowRect = new Rect(Left, Top, Width, Height);

        if (windowRect.Contains(new Point(cursorPoint.X, cursorPoint.Y)) || effects == DragDropEffects.None)
        {
            // Drag was cancelled or returned to shelf -> Restore items!
            if (_stagedDragItems != null)
            {
                Shelf.AddItems(_stagedDragItems);
                SoundService.PlayDrop();
            }
        }
        else
        {
            // Dropped successfully outside -> Dismiss if empty and not pinned!
            if (Shelf.Items.Count == 0 && !Shelf.IsPinned)
            {
                CloseWithFade();
            }
        }

        _stagedDragItems = null;
    }

    #endregion

    #region UI Rendering

    private void UpdateUI()
    {
        bool hasItems = Shelf.Items.Count > 0;

        EmptyStatePanel.Visibility = hasItems ? Visibility.Collapsed : Visibility.Visible;
        CardsCanvas.Visibility = hasItems ? Visibility.Visible : Visibility.Collapsed;
        BottomPill.Visibility = hasItems ? Visibility.Visible : Visibility.Collapsed;
        ItemCountTextBlock.Text = Shelf.ItemCountText;

        if (!hasItems)
        {
            CardsCanvas.Children.Clear();
            return;
        }

        RenderStackedCards();
    }

    private void RenderStackedCards()
    {
        CardsCanvas.Children.Clear();

        var displayItems = Shelf.Items.Take(3).Reverse().ToList();
        int total = displayItems.Count;

        for (int i = 0; i < total; i++)
        {
            var item = displayItems[i];
            bool isTop = (i == total - 1);

            double rotation = isTop ? 0.0 : (i == 0 ? -6.0 : 6.0);
            double offsetX = isTop ? 0.0 : (i == 0 ? -4.0 : 4.0);
            double offsetY = isTop ? 0.0 : -4.0;

            var card = CreateCardElement(item, isTop);
            var transformGroup = new TransformGroup();
            transformGroup.Children.Add(new RotateTransform(rotation, 55, 55));
            transformGroup.Children.Add(new TranslateTransform(offsetX + 15, offsetY + 15));
            card.RenderTransform = transformGroup;

            CardsCanvas.Children.Add(card);
        }
    }

    private Border CreateCardElement(ShelfItem item, bool isTop)
    {
        var border = new Border
        {
            Width = 110,
            Height = 110,
            CornerRadius = new CornerRadius(16),
            Background = new SolidColorBrush(Color.FromArgb(0xEE, 0x27, 0x27, 0x2A)),
            BorderBrush = new SolidColorBrush(Color.FromArgb(0x40, 0xFF, 0xFF, 0xFF)),
            BorderThickness = new Thickness(1)
        };

        var grid = new Grid { Margin = new Thickness(8) };
        grid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        grid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(20) });

        // Thumbnail / Icon
        var iconTextBlock = new TextBlock
        {
            Text = item.IsImage ? "🖼️" : "📄",
            FontSize = 32,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center
        };
        Grid.SetRow(iconTextBlock, 0);
        grid.Children.Add(iconTextBlock);

        // Filename label
        var nameTextBlock = new TextBlock
        {
            Text = item.Name,
            FontSize = 10,
            FontWeight = FontWeights.Medium,
            Foreground = Brushes.White,
            TextTrimming = TextTrimming.CharacterEllipsis,
            HorizontalAlignment = HorizontalAlignment.Center
        };
        Grid.SetRow(nameTextBlock, 1);
        grid.Children.Add(nameTextBlock);

        border.Child = grid;
        return border;
    }

    #endregion

    #region Action Menu

    private void MenuButton_Click(object sender, RoutedEventArgs e)
    {
        var contextMenu = new ContextMenu();

        var copyAll = new MenuItem { Header = "Copy All to Clipboard" };
        copyAll.Click += (s, args) =>
        {
            var files = Shelf.Items.Where(i => !string.IsNullOrEmpty(i.FilePath)).Select(i => i.FilePath!).ToArray();
            if (files.Length > 0)
            {
                var sc = new System.Collections.Specialized.StringCollection();
                sc.AddRange(files);
                Clipboard.SetFileDropList(sc);
                SoundService.PlayDrop();
            }
        };
        contextMenu.Items.Add(copyAll);

        var zipItem = new MenuItem { Header = "Compress to Zip" };
        zipItem.Click += (s, args) =>
        {
            var temp = Path.GetTempPath();
            var zipPath = QuickActionService.CreateZipFromItems(Shelf.Items, temp);
            if (zipPath != null)
            {
                Shelf.Clear();
                Shelf.AddItem(ShelfItem.FromFile(zipPath));
                SoundService.PlayDrop();
            }
        };
        contextMenu.Items.Add(zipItem);

        // OCR if image present
        if (Shelf.Items.Any(i => i.IsImage))
        {
            var ocrItem = new MenuItem { Header = "Extract Text (OCR) to Clipboard" };
            ocrItem.Click += async (s, args) =>
            {
                var firstImg = Shelf.Items.FirstOrDefault(i => i.IsImage);
                if (firstImg?.FilePath != null)
                {
                    var text = await QuickActionService.ExtractTextFromImageAsync(firstImg.FilePath);
                    if (!string.IsNullOrEmpty(text))
                    {
                        Clipboard.SetText(text);
                        SoundService.PlayDrop();
                    }
                }
            };
            contextMenu.Items.Add(ocrItem);
        }

        contextMenu.Items.Add(new Separator());

        var settingsItem = new MenuItem { Header = "Settings..." };
        settingsItem.Click += (s, args) => App.ShowSettingsWindow();
        contextMenu.Items.Add(settingsItem);

        var clearItem = new MenuItem { Header = "Clear Shelf" };
        clearItem.Click += (s, args) => Shelf.Clear();
        contextMenu.Items.Add(clearItem);

        contextMenu.IsOpen = true;
    }

    #endregion
}
