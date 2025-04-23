<#
.SYNOPSIS
    Autostart-Configurator - Ein Tool zum Hinzufügen von Programmen zum Windows-Autostart.

.DESCRIPTION
    Dieses PowerShell-Skript erzeugt eine grafische Benutzeroberfläche, mit der der Benutzer
    Programme zum Windows-Autostart über die Registry hinzufügen kann.

.NOTES
    Autor: Praetoriani
    Datum: 23.04.2025
    Version: 2.0
#>

# Assemblies für Windows Forms und Drawing laden
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Hauptformular mit neuen Abmessungen erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Autostart-Configurator"
$form.Size = New-Object System.Drawing.Size(480, 240)  # Neue Fenstergröße
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
$form.Font = New-Object System.Drawing.Font("Tahoma", 10)  # Globale Schriftart

# Erklärungstext-Label mit Zeilenumbrüchen
$labelInfo = New-Object System.Windows.Forms.Label
$labelInfo.Location = New-Object System.Drawing.Point(0, 10)
$labelInfo.Size = New-Object System.Drawing.Size(480, 60)
#$labelInfo.Text = "Der Autostart-Configurator kann neue Programme zum Autostart hinzufügen.`nÜber den 'Suchen'-Button kannst Du eine Anwendung auswählen,`ndie Du zum Autostart hinzufügen möchtest."
$labelInfo.Text = "Der Autostart-Configurator kann neue Programme zum Autostart hinzufügen.`n`nWähle über den 'Suchen'-Button die Anwendung aus,`ndie Du zum Autostart hinzufügen möchtest."
$labelInfo.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelInfo)

# Eingabefeld mit erhöhter Höhe
$textBoxPath = New-Object System.Windows.Forms.TextBox
$textBoxPath.Location = New-Object System.Drawing.Point(20, 100)
$textBoxPath.Size = New-Object System.Drawing.Size(330, 24)  # Höhe angepasst
$textBoxPath.ReadOnly = $true
$form.Controls.Add($textBoxPath)

# Suchen-Button mit neuer Höhe
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Location = New-Object System.Drawing.Point(360, 100)
$buttonBrowse.Size = New-Object System.Drawing.Size(100, 24)  # Höhe synchronisiert
$buttonBrowse.Text = "Suchen"
$form.Controls.Add($buttonBrowse)

# Button-Positionierung neu berechnet
$buttonWidth = 120
$buttonHeight = 30
$buttonSpacing = 40
$totalWidth = ($buttonWidth * 2) + $buttonSpacing
$leftPosition = [int](($form.ClientSize.Width - $totalWidth) / 2)

# Abbrechen-Button
$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Location = New-Object System.Drawing.Point($leftPosition, 160)
$buttonCancel.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$buttonCancel.Text = "Abbrechen"
$form.Controls.Add($buttonCancel)

# Hinzufügen-Button
$buttonAdd = New-Object System.Windows.Forms.Button
$buttonAdd.Location = New-Object System.Drawing.Point(
    [int]($leftPosition + $buttonWidth + $buttonSpacing),
    160
)
$buttonAdd.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$buttonAdd.Text = "Hinzufügen"
$form.Controls.Add($buttonAdd)

# Event-Handler (unverändert)
$buttonBrowse.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Ausführbare Dateien (*.exe)|*.exe"
    if ($openFileDialog.ShowDialog() -eq "OK") {
        $textBoxPath.Text = $openFileDialog.FileName
    }
})

$buttonCancel.Add_Click({ $textBoxPath.Text = "" })

$buttonAdd.Add_Click({
    if ([string]::IsNullOrEmpty($textBoxPath.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Bitte wähle eine Anwendung aus.", "Fehler", "OK", "Error")
    } else {
        try {
            $appPath = $textBoxPath.Text
            $appName = [IO.Path]::GetFileNameWithoutExtension($appPath)
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
                -Name $appName -Value "`"$appPath`"" -PropertyType String -Force
#            [System.Windows.Forms.MessageBox]::Show("'$appName' wurde hinzugefügt.", "Erfolg", "OK", "Information")
            [System.Windows.Forms.MessageBox]::Show("'$appPath' wurde hinzugefügt.", "Erfolg", "OK", "Information")
            $textBoxPath.Text = ""
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Fehler: $_", "Fehler", "OK", "Error")
        }
    }
})

$form.ShowDialog()
