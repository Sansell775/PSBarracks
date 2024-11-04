Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


$main_form = New-Object System.Windows.Forms.Form

$configFilePath = "C:\PSBarracks\config.json"

$configContent = Get-Content -path $configFilePath -Raw  | ConvertFrom-Json

$folderLocation = $configContent.folderLocation

Write-Output $folderLocation

$scripts = @(Get-ChildItem -path $folderLocation -Recurse -filter *.ps1 | select-object -expandproperty Name)

$main_form.Text ='PSBarracks'
$main_form.Width = 400
$main_form.Height = 525
$main_form.FormBorderStyle='FixedDialog'
$main_form.MaximizeBox=$false

$scriptView = New-Object System.Windows.Forms.ListBox
$scriptview.width = 350
$scriptView.height = 275
$scriptView.Location = "15,15"
$scriptView.Add_Click({listClick})

foreach ($script in $scripts){
    $scriptview.items.add($script)
}

$main_form.Controls.Add($scriptView)

$descPanel = New-Object System.Windows.Forms.GroupBox
$descPanel.width = 350
$descPanel.Height = 125
$descPanel.Location = "15,285"
$descPanel.text = "Description"
$main_form.Controls.Add($descPanel)

$runButton = New-Object System.Windows.Forms.Button
$RunButton.text = "Run"
$runButton.width = 80
$runButton.Height = 40
$runbutton.Add_Click({Run})
$runButton.Location = "15,425"
$main_form.Controls.add($runButton)

$scriptDescriptionLabel = New-Object System.Windows.Forms.Label
$scriptDescriptionLabel.width = 325
$scriptDescriptionLabel.Height = 90
$scriptDescriptionLabel.location = "10,30"

$settingsButton = New-Object System.Windows.Forms.Button
$settingsButton.text = "Settings"
$settingsButton.width = 80
$settingsButton.Height = 40
$settingsButton.Add_Click({settingsMenu})
$settingsButton.Location = "105,425"
$main_form.Controls.add($settingsButton)

$editDescriptionButton = New-Object System.Windows.Forms.Button
$editDescriptionButton.text = "Edit Description"
$editDescriptionButton.width = 80
$editDescriptionButton.height = 40
$editDescriptionButton.Add_Click({editDescription})
$editDescriptionButton.Location = "195, 425"

function run(){
}

function editDescription(){
    $selectedScriptPath = $scripts[$scriptview.SelectedIndex]

    $editDescriptionForm = New-Object System.Windows.Forms.Form
    $editDescriptionForm.Text = "Edit Description"
    $editDescriptionForm.Width = 400
    $editDescriptionForm.Height = 450
    $editDescriptionForm.FormBorderStyle='FixedDialog'
    $editDescriptionForm.MaximizeBox=$false


    $editDescriptionLabel = New-Object System.Windows.Forms.Label
    $editDescriptionLabel.Text =   $selectedScriptPath + " - Edit Description"
    $editDescriptionLabel.Width = 390
    $editDescriptionLabel.Height = 30
    $editDescriptionLabel.Location = "5,5"
    #$editDescriptionLabel.Font = [system.drawing.font]'$editDescriptionLabel.Font.Name$editDescriptionLabel.Font.Size, style=Bold'


    $editDescriptionTextBox = new-Object System.Windows.Forms.TextBox
    $editDescriptionTextBox.Multiline = $true;
    $editDescriptionTextBox.Size = New-Object System.Drawing.Size (375, 300)
    $editDescriptionTextBox.location = New-object System.Drawing.Size(5, 35)


    Try{$scriptName=$selectedScriptPath.substring(0,$selectedScriptPath.IndexOf('.'))}
    Catch{Return}
   
        If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
        {

        $editDescriptionTextBox.text= Get-Content -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt")
        Write-host $folderLocation
        }
        Else
        {
        $editDescriptionTextBox.text = 'No description file found for " ' + $scriptName + '"'
        Write-host $folderLocation
        }


    $editDescriptionForm.Controls.Add($editDescriptionTextBox)
    $editDescriptionForm.Controls.Add($editDescriptionLabel)
    $editDescriptionForm.ShowDialog()

}

function settingsMenu(){
    $settings_form = New-Object System.Windows.Forms.Form
    $settings_form.Text ='Settings'
    $settings_form.Width = 400
    $settings_form.Height = 450
    $settings_form.FormBorderStyle='FixedDialog'
    $settings_form.MaximizeBox=$false

    $folderSettingsGroupBox = New-Object System.Windows.Forms.GroupBox
    $folderSettingsGroupBox.Text = "Location Settings"
    $folderSettingsGroupBox.Width = 375
    $folderSettingsGroupBox.Height = 105
    $folderSettingsGroupBox.Location = "5,5"

    $scriptsFolderLabel = New-Object System.Windows.Forms.Label
    $scriptsFolderLabel.Text = "Script Folder:   " + $folderLocation
    $scriptsFolderLabel.Location = "15,30"
    $scriptsFolderLabel.width =325
    $scriptsFolderLabel.Height = 50

    $changeScriptFolderButton = New-Object System.Windows.Forms.Button
    $changeScriptFolderButton.text = "Browse"
    $changeScriptFolderButton.width = 80
    $changeScriptFolderButton.height = 20
    $changeScriptFolderButton.Location = "10,75"
    $changeScriptFolderButton.Add_Click({browseScriptFolder})

    $folderSettingsGroupBox.Controls.Add($changeScriptFolderButton)
    $folderSettingsGroupBox.Controls.Add($scriptsFolderLabel)

    $settings_form.Controls.Add($folderSettingsGroupBox)
    $Settings_form.ShowDialog()
}

function listClick(){
    $scriptDescriptionLabel.Text = $null
    $selectedScriptPath = $scripts[$scriptview.SelectedIndex]
    $descPanel.text = "Description - " + $selectedScriptPath

    #gets just the script name; removes the .ps1 extension
    #if user clicks empty spot or box when no scripts are populated, a null valued expression error occurs. This try/Catch prevents that
    
    Try{$scriptName=$selectedScriptPath.substring(0,$selectedScriptPath.IndexOf('.'))}
    Catch{Return}
   
        If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
        {

        $scriptDescriptionLabel.text= Get-Content -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt")
        Write-host ($folderLocation + "\Descriptions\" + $scriptName + ".txt")

        }
        Else
        {
        $scriptDescriptionLabel.text = 'No description file found for " ' + $scriptName + '"'
        Write-host ($folderLocation + "\Descriptions\" + $scriptName + ".txt")

        }

    $descPanel.Controls.Add($scriptDescriptionLabel)

    if($scriptview.SelectedIndex -ne $null){
###button for description editing
    $main_form.Controls.add($editDescriptionButton)
    }
}

function browseScriptFolder(){

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    if ($folderBrowser.ShowDialog() -eq "OK" -and $folderBrowser.SelectedPath -ne "" -and $folderBrowser.SelectedPath -ne $null)
    {
        $newConfigContent = $folderBrowser.SelectedPath
        $configContent.FolderLocation = $newConfigContent
        $newconfigContent = $configContent | ConvertTo-Json -Depth 1
        Set-Content -Path $configFilePath -Value $newconfigContent
        $scriptsFolderLabel.Text = "Script Folder:   " + $configContent.FolderLocation
        $folderLocation = $configContent.FolderLocation
        $scriptview.Items.Clear()
        $scripts = @(Get-ChildItem -path $folderLocation -Recurse -filter *.ps1 | select-object -expandproperty Name)
        foreach ($script in $scripts){
            $scriptview.items.add($script)
        }
        $main_form.Controls.Add($scriptView)
    }
    else 
    {
    Write-Host "Null/invalid path selected, or user cancelled."    
    }

    
}



$main_form.ShowDialog()