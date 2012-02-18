Unit IDENotifierInterface;

Interface

Uses
  ToolsAPI;

{$INCLUDE CompilerDefinitions.inc}

Type
  TIDENotifierTemplate = Class(TNotifierObject,
    IOTANotifier,
    {$IFDEF D0005} IOTAIDENotifier50, {$ENDIF}
    {$IFDEF D2005} IOTAIDENotifier80, {$ENDIF}
    IOTAIDENotifier)
  {$IFDEF D2005} Strict {$ENDIF} Private
  {$IFDEF D2005} Strict {$ENDIF} Protected
  Public
    // IOTANotifier
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    {$IFDEF D0005}
    // IOTAIDENotifier
    Procedure FileNotification(NotifyCode: TOTAFileNotification; Const FileName: String; Var Cancel: Boolean);
    Procedure BeforeCompile(Const Project: IOTAProject; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean); Overload;
    // IOTAIDENotifier50
    Procedure BeforeCompile(Const Project: IOTAProject; IsCodeInsight: Boolean; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);  Overload;
    {$ENDIF}
    {$IFDEF D2005}
    Procedure AfterCompile(Const Project: IOTAProject; Succeeded: Boolean;
      IsCodeInsight: Boolean); Overload;
    {$ENDIF}
  End;

Implementation

Uses
  SysUtils,
  UtilityFunctions;

Const
  strBoolean : Array[False..True] Of String = ('False', 'True');

{$IFDEF D0006}
ResourceString
  strIDENotifierMessages = 'IDE Notifier Messages';
{$ENDIF}

{ TIDENotifierTemplate }

{$IFDEF D0005}
Procedure TIDENotifierTemplate.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  OutputMessage(Format('BeforeCompile: Project: %s, Cancel = %s', [
    ExtractFileName(Project.FileName), strBoolean[Cancel]])
    {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  OutputMessage(Format('BeforeCompile: Project: %s, IsCodeInsight = %s, Cancel = %s', [
    ExtractFileName(Project.FileName), strBoolean[IsCodeInsight], strBoolean[Cancel]])
    {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.AfterCompile(Succeeded: Boolean);

Begin
  OutputMessage(Format('AfterCompile: Succeeded=  %s', [strBoolean[Succeeded]])
    {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.AfterCompile(Succeeded, IsCodeInsight: Boolean);

Begin
  OutputMessage(Format('AfterCompile: Succeeded=  %s, IsCodeInsight = %s', [
    strBoolean[Succeeded], strBoolean[IsCodeInsight]])
    {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.FileNotification(NotifyCode: TOTAFileNotification;
  Const FileName: String; Var Cancel: Boolean);

Const
  strNotifyCode : Array[Low(TOTAFileNotification)..High(TOTAFileNotification)] of String = (
    'ofnFileOpening',
    'ofnFileOpened',
    'ofnFileClosing',
    'ofnDefaultDesktopLoad',
    'ofnDefaultDesktopSave',
    'ofnProjectDesktopLoad',
    'ofnProjectDesktopSave',
    'ofnPackageInstalled',
    'ofnPackageUninstalled' {$IFDEF D0007},
    'ofnActiveProjectChanged' {$ENDIF}
  );

Begin
  OutputMessage(Format('FileNotification: NotifyCode = %s, FileName = %s, Cancel = %s', [
    strNotifyCode[NotifyCode], ExtractFileName(FileName), strBoolean[Cancel]])
    {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

{$ENDIF}

{$IFDEF D2005}
Procedure TIDENotifierTemplate.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  OutputMessage(Format('AfterCompile: Project: %s, Succeeded=  %s, IsCodeInsight = %s', [
    ExtractFileName(Project.FileName), strBoolean[Succeeded], strBoolean[IsCodeInsight]]),
    strIDENotifierMessages);
End;
{$ENDIF}

Procedure TIDENotifierTemplate.AfterSave;

Begin
  OutputMessage('AfterSave' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;


Procedure TIDENotifierTemplate.BeforeSave;

Begin
  OutputMessage('BeforeSave' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.Destroyed;

Begin
  OutputMessage('Destroyed' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

Procedure TIDENotifierTemplate.Modified;

Begin
  OutputMessage('Modified' {$IFDEF D0006} , strIDENotifierMessages {$ENDIF});
End;

Initialization
Finalization
  ClearMessages([cmCompiler..cmTool]);
End.

