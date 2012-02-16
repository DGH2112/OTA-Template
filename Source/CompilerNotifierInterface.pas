Unit CompilerNotifierInterface;

Interface

Uses
  ToolsAPI;

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF D2010}
Type
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
  UtilityFunctions;

{$IFDEF D2010}
Const
  strCompileMode : Array[Low(TOTACompileMode)..High(TOTACompileMode)] Of String = (
    'Make', 'Build', 'Check', 'Make Unit');
  strCompileResult : Array[Low(TOTACompileResult)..High(TOTACompileResult)] of String = (
    'Failed', 'Succeeded', 'Background');

ResourceString
  strCompilerNotifierMessages = 'Compiler Notifier Messages';

Procedure TCompilerNotifier.ProjectCompileStarted(const Project: IOTAProject;
  Mode: TOTACompileMode);

Begin
  OutputMessage(Format('ProjectCompileStarted: Project = %s, Mode = %s', [
    ExtractFilename(Project.FileName), strCompileMode[Mode]]),
    strCompilerNotifierMessages);
End;

Procedure TCompilerNotifier.ProjectCompileFinished(const Project: IOTAProject;
  Result: TOTACompileResult);

Begin
  OutputMessage(Format('ProjectCompileFinished: Project = %s, Result = %s', [
    ExtractFileName(Project.FileName), strCompileResult[Result]]),
    strCompilerNotifierMessages);
End;

Procedure TCompilerNotifier.ProjectGroupCompileStarted(Mode: TOTACompileMode);

Begin
  OutputMessage(Format('ProjectGroupCompileStarted: Mode = %s', [strCompileMode[Mode]]),
    strCompilerNotifierMessages);
End;

Procedure TCompilerNotifier.ProjectGroupCompileFinished(Result: TOTACompileResult);

Begin
  OutputMessage(Format('ProjectGroupCompileFinished: Mode = %s', [
    strCompileResult[Result]]), strCompilerNotifierMessages);
End;
{$ENDIF}

End.
