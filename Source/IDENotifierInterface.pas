(**

  This module contains a class that handles the IDENotifier interface.

  @Version 1.0
  @Author  David Hoyle
  @Date    10 Nov 2014

**)
Unit IDENotifierInterface;

Interface

Uses
  ToolsAPI;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class to handle the IDENotifier interface. **)
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
  UtilityFunctions,
  ApplicationOptions;

Const
  (** A constant array represent true and false as strings. **)
  strBoolean : Array[False..True] Of String = ('False', 'True');

{$IFDEF D0006}
ResourceString
  (** A resource string for the message group under which messages should be
      output. **)
  strIDENotifierMessages = 'IDE Notifier Messages';
{$ENDIF}

{ TIDENotifierTemplate }

{$IFDEF D0005}
(**

  This method is called by the Delphi IDEs up to 4, before a project is
  compiled.

  @precon  Project is a reference to the project about to be compiled and Cancel
           should be changed to true IF you which to stop the IDE from
           continuing to compile.
  @postcon Place handling in the method for things you want to do before the
           project is compiled.

  @param   Project as an IOTAProject as a constant
  @param   Cancel  as a Boolean as a reference

**)
Procedure TIDENotifierTemplate.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('BeforeCompile: Project: %s, Cancel = %s', [
      ExtractFileName(Project.FileName), strBoolean[Cancel]])
      {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is called by the Delphi IDEs 5 and above before a project is
  compiled.

  @precon  Project is a reference to the project about to be compiled,
           IsCodeInsight is true for compilation instigated by the code insight
           IDE functionality and Cancel should be changed to true IF you
           which to stop the IDE from continuing to compile.
  @postcon Place handling in the method for things you want to do before the
           project is compiled.

  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
Procedure TIDENotifierTemplate.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('BeforeCompile: Project: %s, IsCodeInsight = %s, Cancel = %s', [
      ExtractFileName(Project.FileName), strBoolean[IsCodeInsight], strBoolean[Cancel]])
      {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is called by the Delphi IDEs up to 4, after a project is
  compiled.

  @precon  Succeeded is true of the project was successfully compiled.
  @postcon Place handling in the method for things you want to do after the
           project is compiled.

  @param   Succeeded as a Boolean

**)
Procedure TIDENotifierTemplate.AfterCompile(Succeeded: Boolean);

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('AfterCompile: Succeeded=  %s', [strBoolean[Succeeded]])
      {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is called by the Delphi IDEs 5, 6, 7 and 8, after a project is
  compiled.

  @precon  Succeeded is true of the project was successfully compiled and
           IsCodeInsight is true if the compilation is invoked by the IDEs
           CodeInsight functionality.
  @postcon Place handling in the method for things you want to do after the
           project is compiled.

  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TIDENotifierTemplate.AfterCompile(Succeeded, IsCodeInsight: Boolean);

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('AfterCompile: Succeeded=  %s, IsCodeInsight = %s', [
      strBoolean[Succeeded], strBoolean[IsCodeInsight]])
      {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is fired when files are opened, closed along with projects,
  desktops and packages.

  @precon  NotifyCode is the type of File Notification, Filename is the name of
           the file and Cancel can be set to true to cancel the operation.
  @postcon Place code here to perform additional tasks when files are opened
           and closed.

  @param   NotifyCode as a TOTAFileNotification
  @param   FileName   as a String as a constant
  @param   Cancel     as a Boolean as a reference

**)
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
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('FileNotification: NotifyCode = %s, FileName = %s, Cancel = %s', [
      strNotifyCode[NotifyCode], ExtractFileName(FileName), strBoolean[Cancel]])
      {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

{$ENDIF}

{$IFDEF D2005}
(**

  This method is called by the Delphi IDEs 2005 and above, after a project is
  compiled.

  @precon  Succeeded is true of the project was successfully compiled, Project
           is a reference to the project being compiled and IsCodeInsight is
           true if the compilation is invoked by the IDEs CodeInsight
           functionality.
  @postcon Place handling in the method for things you want to do after the
           project is compiled.

  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TIDENotifierTemplate.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('AfterCompile: Project: %s, Succeeded=  %s, IsCodeInsight = %s', [
      ExtractFileName(Project.FileName), strBoolean[Succeeded], strBoolean[IsCodeInsight]]),
      strIDENotifierMessages);
End;
{$ENDIF}

(**

  This method is not fired for a IDE notifier.

  @precon  None.
  @postcon None.

**)
Procedure TIDENotifierTemplate.AfterSave;

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage('AfterSave' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;


(**

  This method is not fired for a IDE notifier.

  @precon  None.
  @postcon None.

**)
Procedure TIDENotifierTemplate.BeforeSave;

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage('BeforeSave' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is not fired for a IDE notifier.

  @precon  None.
  @postcon None.

**)
Procedure TIDENotifierTemplate.Destroyed;

Begin
  ClearMessages([cmCompiler..cmTool]);
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage('Destroyed' {$IFDEF D0006}, strIDENotifierMessages {$ENDIF});
End;

(**

  This method is not fired for a IDE notifier.

  @precon  None.
  @postcon None.

**)
Procedure TIDENotifierTemplate.Modified;

Begin
  If moShowIDEMessages In ApplicationOps.ModuleOps Then
    OutputMessage('Modified' {$IFDEF D0006} , strIDENotifierMessages {$ENDIF});
End;

End.

