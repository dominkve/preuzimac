[Setup]
AppName=MyInstaller
AppVersion=1.0
DefaultDirName={pf}\MyApp
DefaultGroupName=MyApp
OutputDir=.\Output
OutputBaseFilename=Installer

[CustomMessages]
InstallPython=Install Python
InstallGCC=Install GCC
InstallNodeJS=Install Node.js

[Code]
var
ResultCode: Integer;
  PythonCheckbox, GCCCheckbox, NodeJSCheckbox: TCheckBox;
  InstallPython, InstallGCC, InstallNodeJS: Boolean;

procedure InstallChocolatey;
begin
  // Install Chocolatey and block until it's finished
  Exec('powershell.exe', '-NoExit -ExecutionPolicy Bypass -Command "if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iwr https://community.chocolatey.org/install.ps1 | iex }"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

end;
function CreateSoftwareSelectionPage: TInputQueryWizardPage;
begin
  Result := CreateInputQueryPage(wpSelectDir,
    'Software Selection',
    'Select the software you want to install.',
    'Choose what you would like to install:');

  // Create checkboxes for multiple software selections
  PythonCheckbox := TCheckBox.Create(Result);
  PythonCheckbox.Parent := Result.Surface;
  PythonCheckbox.Caption := 'Install Python';
  PythonCheckbox.Top := 40;
  PythonCheckbox.Left := 20;
  PythonCheckbox.Checked := False;  // Default unchecked
  
  GCCCheckbox := TCheckBox.Create(Result);
  GCCCheckbox.Parent := Result.Surface;
  GCCCheckbox.Caption := 'Install GCC';
  GCCCheckbox.Top := 70;
  GCCCheckbox.Left := 20;
  GCCCheckbox.Checked := False;  // Default unchecked

  NodeJSCheckbox := TCheckBox.Create(Result);
  NodeJSCheckbox.Parent := Result.Surface;
  NodeJSCheckbox.Caption := 'Install Node.js';
  NodeJSCheckbox.Top := 100;
  NodeJSCheckbox.Left := 20;
  NodeJSCheckbox.Checked := False;  // Default unchecked
end;

procedure InitializeWizard;
begin
  InstallChocolatey;
  // Create the custom software selection page
  CreateSoftwareSelectionPage;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    
    // Check which software the user selected
    InstallPython := PythonCheckbox.Checked;
    InstallGCC := GCCCheckbox.Checked;
    InstallNodeJS := NodeJSCheckbox.Checked;
    
    // Run installation commands based on the user's selections
    if InstallPython then
    begin
      // Install Python
      Exec('choco', 'install python -y --install-arguments="/quiet PrependPath=1"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then
        MsgBox('Python installation failed.', mbError, MB_OK);
    end;

    if InstallGCC then
    begin
      Exec('choco', 'install mingw -y --install-arguments="/quiet PrependPath=1"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then
        MsgBox('GCC installation failed.', mbError, MB_OK);
    end;

    if InstallNodeJS then
    begin
      Exec('choco', 'install nodejs -y --install-arguments="/quiet PrependPath=1"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then
        MsgBox('Node.js installation failed.', mbError, MB_OK);
    end;
  end;
end;
