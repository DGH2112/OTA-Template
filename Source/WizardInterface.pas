Unit WizardInterface;

Interface

Uses
  ToolsAPI,
  Menus,
  ExtCtrls;

{$INCLUDE CompilerDefinitions.inc}

Type
  TWizardTemplate = Class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  {$IFDEF D2005} Strict {$ENDIF} Private
    FTimer       : TTimer;
    FCounter     : Integer;
    FAutoSaveInt : Integer;
    FPrompt      : Boolean;
    FMenuItem    : TMenuItem;
    FINIFileName : String;
    FSucceeded: Boolean;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure TimerEvent(Sender : TObject);
    Procedure MenuClick(Sender : TObject);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure SaveModifiedFiles;
    Procedure InstallMenu;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    // IOTAWizard
    Function GetIDString: String;
    Function GetName: String;
    Function GetState: TWizardState;
    Procedure Execute;
    // IOTAMenuWizard
    Function GetMenuText: String;
  End;

Implementation

Uses
  Dialogs,
  Windows,
  SysUtils,
  IniFiles,
  OptionsForm;

{ TWizardTemplate }

Constructor TWizardTemplate.Create;

Var
  iSize: DWORD;

Begin
  FMenuItem := Nil;
  FCounter := 0;
  FAutoSaveInt := 300; // Default 300 seconds (5 minutes)
  FPrompt := True; // Default to True
  // Create INI file same as add module + '.INI'
  SetLength(FINIFileName, MAX_PATH);
  iSize := MAX_PATH;
  iSize := GetModuleFileName(hInstance, PChar(FINIFileName), iSize);
  SetLength(FINIFileName, iSize);
  FINIFileName := ChangeFileExt(FINIFileName, '.INI');
  LoadSettings;
  FSucceeded := False;
  FTimer := TTimer.Create(Nil);
  FTimer.Interval := 1000; // 1 second
  FTimer.OnTimer := TimerEvent;
  FTimer.Enabled := True;
End;

Destructor TWizardTemplate.Destroy;

Begin
  SaveSettings;
  FMenuItem.Free;
  FTimer.Free;
  Inherited Destroy;
End;

Procedure TWizardTemplate.Execute;

{$IFDEF D2010}
Var
  TopView: IOTAEditView;
  I : IOTAElideActions;
{$ENDIF}
Begin
  {$IFNDEF D2010}
  ShowMessage('Hello World!');
  {$ELSE}
  TopView := (BorlandIDEServices As IOTAEditorServices).TopView;
  If TopView.QueryInterface(IOTAElideActions, I) = S_OK Then
    Begin
      I.ToggleElisions;
      TopView.Paint;
    End;
  {$ENDIF}
End;

Function TWizardTemplate.GetIDString: String;

Begin
  Result := 'OTA.Wizard.Template';
End;

Function TWizardTemplate.GetMenuText: String;

Begin
  Result := 'Toggle Folded Code';
End;

Function TWizardTemplate.GetName: String;

Begin
  Result := 'OTA Template';
End;

Function TWizardTemplate.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

Procedure TWizardTemplate.InstallMenu;

Var
  NTAS: INTAServices;
  mmiViewMenu: TMenuItem;
  mmiWindowList: TMenuItem;

Begin
  NTAS := (BorlandIDEServices As INTAServices);
  If (NTAS <> Nil) And (NTAS.MainMenu <> Nil) Then
    Begin
      mmiViewMenu := NTAS.MainMenu.Items.Find('View');
      If mmiViewMenu <> Nil Then
        Begin
          mmiWindowList := mmiViewMenu.Find('Window List...');
          If mmiWindowList <> Nil Then
            Begin
              FMenuItem := TMenuItem.Create(mmiViewMenu);
              FMenuItem.Caption := '&Auto Save Options...';
              FMenuItem.OnClick := MenuClick;
              FMenuItem.ShortCut := TextToShortCut('Ctrl+Shift+Alt+A');
              mmiViewMenu.Insert(mmiWindowList.MenuIndex + 1, FMenuItem);
              FSucceeded := True;
            End;
        End;
    End;
End;

Procedure TWizardTemplate.LoadSettings;

Begin
  With TIniFile.Create(FINIFileName) Do
    Try
      FAutoSaveInt := ReadInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      FPrompt := ReadBool('Setup', 'Prompt', FPrompt);
    Finally
      Free;
    End;
End;

Procedure TWizardTemplate.MenuClick(Sender: TObject);

Begin
  If TfrmOptions.Execute(FAutoSaveInt, FPrompt) Then
    SaveSettings; // Not really required as is called in destructor.
End;

Procedure TWizardTemplate.SaveModifiedFiles;

Var
  Iterator: IOTAEditBufferIterator;
  i: Integer;

Begin
  If (BorlandIDEServices As IOTAEditorServices).GetEditBufferIterator(Iterator) Then
    Begin
      For i := 0 To Iterator.Count - 1 Do
        If Iterator.EditBuffers[i].IsModified Then
          Iterator.EditBuffers[i].Module.Save(False, Not FPrompt);
    End;
End;

Procedure TWizardTemplate.SaveSettings;

Begin
  With TIniFile.Create(FINIFileName) Do
    Try
      WriteInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      WriteBool('Setup', 'Prompt', FPrompt);
    Finally
      Free;
    End;
End;

Procedure TWizardTemplate.TimerEvent(Sender: TObject);

Begin
  Inc(FCounter);
  If FCounter >= FAutoSaveInt Then
    Begin
      FCounter := 0;
      SaveModifiedFiles;
    End;
  If Not FSucceeded Then
    InstallMenu;
End;

End.
