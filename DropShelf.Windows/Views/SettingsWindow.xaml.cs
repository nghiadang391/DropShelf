using System.Windows;
using DropShelf.Services;
using DropShelf.Utils;

namespace DropShelf.Views;

public partial class SettingsWindow : Window
{
    public SettingsWindow()
    {
        InitializeComponent();
    }

    private void Window_Loaded(object sender, RoutedEventArgs e)
    {
        DwmBackdropHelper.EnableWindows11FluentTheme(this);
        StartupCheckBox.IsChecked = StartupHelper.IsEnabled;
        SoundCheckBox.IsChecked = SoundService.IsSoundEnabled;
    }

    private void StartupCheckBox_Click(object sender, RoutedEventArgs e)
    {
        StartupHelper.SetEnabled(StartupCheckBox.IsChecked == true);
    }

    private void TrayCheckBox_Click(object sender, RoutedEventArgs e)
    {
        TrayIconManager.Instance.SetVisible(TrayCheckBox.IsChecked == true);
    }

    private void SoundCheckBox_Click(object sender, RoutedEventArgs e)
    {
        SoundService.IsSoundEnabled = SoundCheckBox.IsChecked == true;
    }

    private void DoneButton_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
