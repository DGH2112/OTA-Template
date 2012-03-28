(**
  
  This module contains code to handle the compiler notifications in the IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    24 Mar 2012

**)
Unit CompilerNotifierInterface;

Interface

Uses
  ToolsAPI;

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF D2010}
Type
  (** A class that implements the IOTACompilerNotifier interface to handle
      compiler notifications. **)
  TCompilerNotifier = Class(TNotifierObject, IOTACompileNotifier)
  Strict Private
  Strict Protected
    Procedure ProjectCompileStarted(const Project: IOTAProject; Mode: TOTACompileMode);
    Procedure ProjectCompileFinished(const Project: IOTAProject; Result: TOTACompileResult);
    Procedure ProjectGroupCompileStarted(Mode: TOTACompileMode);
    Procedure ProjectGroupCompileFinished(Result: TOTACompileResult);
  Public
  End;
{$ENDIF}

Implementation

Uses
  SysUtils,
  UtilityFunctions,
  ApplicationOptions;

{$IFDEF D2010}
Const
  (** A constant array to provide string representations for the Compile Mode
      enumerate. **)
  strCompileMode : Array[Low(TOTACompileMode)..High(TOTACompileMode)] Of String = (
    'Make', 'Build', 'Check', 'Make Unit');
  (** A constant array to provide string representations for the Compile Result
      enumerate. **)
  strCompileResult : Array[Low(TOTACompileResult)..High(TOTACompileResult)] of String = (
    'Failed', 'Succeeded', 'Background');

ResourceString
  (** A resource string defining the message page on which messages should be
      output from this module. **)
  strCompilerNotifierMessages = 'Compiler Notifier Messages';

(**

  This method of the interface is called by the IDE before compiling a project.

  @precon  Project is the IDE project being compiled and Mode defines the
           conditions under which the project is being compiled.
  @postcon Place handling in this event to be performed before a project is
           compiled.

  @param   Project as an IOTAProject as a constant
  @param   Mode    as a TOTACompileMode

**)
Procedure TCompilerNotifier.ProjectCompileStarted(const Project: IOTAProject;
  Mode: TOTACompileMode);

Begin
  If moShowCompilerMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('ProjectCompileStarted: Project = %s, Mode = %s', [
      ExtractFilename(Project.FileName), strCompileMode[Mode]]),
      strCompilerNotifierMessages);
End;

(**

  This method of the interface is called by the IDE after compiling a project.

  @precon  Project is the IDE project being compiled and Result defines the
           conditions under which the project being compiled was completed.
  @postcon Place handling in this event to be performed after a project is
           compiled.

  @param   Project as an IOTAProject as a constant
  @param   Result  as a TOTACompileResult

**)
Procedure TCompilerNotifier.ProjectCompileFinished(const Project: IOTAProject;
  Result: TOTACompileResult);

Begin
  If moShowCompilerMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('ProjectCompileFinished: Project = %s, Result = %s', [
      ExtractFileName(Project.FileName), strCompileResult[Result]]),
      strCompilerNotifierMessages);
End;

(**

  This method of the interface is called before all projects are compiled in the
  group.

  @precon  Mode defines the conditions under which the project is being
           compiled.
  @postcon Place handling in this event to be performed before all projects are
           compiled.

  @param   Mode as a TOTACompileMode

**)
Procedure TCompilerNotifier.ProjectGroupCompileStarted(Mode: TOTACompileMode);

Begin
  If moShowCompilerMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('ProjectGroupCompileStarted: Mode = %s', [strCompileMode[Mode]]),
      strCompilerNotifierMessages);
End;

(**

  This method of the interface is called by the IDE after all projects are
  compiled.

  @precon  Result defines the conditions under which the projects being compiled
           were completed.
  @postcon Place handling in this event to be performed after all the project
           are compiled.

  @param   Result  as a TOTACompileResult

**)
Procedure TCompilerNotifier.ProjectGroupCompileFinished(Result: TOTACompileResult);

Begin
  If moShowCompilerMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('ProjectGroupCompileFinished: Mode = %s', [
      strCompileResult[Result]]), strCompilerNotifierMessages);
End;
{$ENDIF}

End.
