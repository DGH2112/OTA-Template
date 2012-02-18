Unit ModuleCreatorInterface;

Interface

Uses
  ToolsAPI,
  RepositoryWizardForm;

{$INCLUDE CompilerDefinitions.inc}

Type
  TModuleCreator = Class(TInterfacedObject, IOTACreator, IOTAModuleCreator)
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProject           : IOTAProject;
    FProjectWizardInfo : TProjectWizardInfo;
    FAdditionalModule  : TAdditionalModule;
  {$IFDEF D2005} Strict {$ENDIF} Protected
  Public
    Constructor Create(AProject : IOTAProject; ProjectWizardInfo : TProjectWizardInfo;
      AdditionalModule : TAdditionalModule);
    // IOTACreator
    Function GetCreatorType: String;
    Function GetExisting: Boolean;
    Function GetFileSystem: String;
    Function GetOwner: IOTAModule;
    Function GetUnnamed: Boolean;
    // IOTAModuleCreator
    Procedure FormCreated(Const FormEditor: IOTAFormEditor);
    Function GetAncestorName: String;
    Function GetFormName: String;
    Function GetImplFileName: String;
    Function GetIntfFileName: String;
    Function GetMainForm: Boolean;
    Function GetShowForm: Boolean;
    Function GetShowSource: Boolean;
    Function NewFormFile(Const FormIdent: String; Const AncestorIdent: String) : IOTAFile;
    Function NewImplSource(Const ModuleIdent: String; Const FormIdent: String;
      Const AncestorIdent: String): IOTAFile;
    Function NewIntfSource(Const ModuleIdent: String; Const FormIdent: String;
      Const AncestorIdent: String): IOTAFile;
  End;

  TModuleCreatorFile = Class(TInterfacedObject, IOTAFile)
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProjectWizardInfo : TProjectWizardInfo;
    FAdditionalModule  : TAdditionalModule;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Function ExpandMacro(strText, strMacroName, strReplaceText : String) : String;
    Function GetFinaliseWizardCode : String;
    Function GetInitialiseWizardCode : String;
    Function GetVariableDeclCode : String;
    Function GetUsesClauseCode : String;
  Public
    Constructor Create(ProjectWizardInfo : TProjectWizardInfo;
      AdditionalModule : TAdditionalModule);
    function GetAge: TDateTime;
    function GetSource: string;
  End;

Implementation

uses
  SysUtils,
  Classes,
  Windows;

Type
  TModuleInfo = Record
    FResourceName : String;
    FModuleName   : String;
  End;

Const
  strProjectTemplate : Array[Low(TAdditionalModule)..High(TAdditionalModule)] Of TModuleInfo = (
    (FResourceName: 'OTAModuleCompilerDefinitions';       FModuleName: 'CompilerDefinitions.inc'),
    (FResourceName: 'OTAModuleInitialiseOTAInterfaces';   FModuleName: 'InitialiseOTAInterface.pas'),
    (FResourceName: 'OTAModuleUtilityFunctions';          FModuleName: 'UtilityFunctions.pas'),
    (FResourceName: 'OTAModuleWizardInterface';           FModuleName: 'WizardInterface.pas'),
    (FResourceName: 'OTAModuleCompilerNotifierInterface'; FModuleName: 'CompilerNotifierInterface.pas'),
    (FResourceName: 'OTAModuleEditorNotifierInterface';   FModuleName: 'EditorNotifierInterface.pas'),
    (FResourceName: 'OTAModuleIDENotifierInterface';      FModuleName: 'IDENotifierInterface.pas'),
    (FResourceName: 'OTAModuleKeyboardBindingInterface';  FModuleName: 'KeyboardBindingInterface.pas'),
    (FResourceName: 'OTAModuleRepositoryWizardInterface'; FModuleName: 'RepositoryWizardInterface.pas'),
    (FResourceName: 'OTAModuleProjectCreatorInterface';   FModuleName: 'ProjectCreatorInterface.pas'),
    (FResourceName: 'OTAModuleModuleCreatorInterface';    FModuleName: 'ModuleCreatorInterface.pas')
  );

{ TModuleCreator }

constructor TModuleCreator.Create(AProject: IOTAProject; ProjectWizardInfo : TProjectWizardInfo;
  AdditionalModule : TAdditionalModule);
begin
  FProject := AProject;
  FProjectWizardInfo := ProjectWizardInfo;
  FAdditionalModule := AdditionalModule;
end;

function TModuleCreator.GetCreatorType: String;
begin
  Result := sUnit;
end;

function TModuleCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TModuleCreator.GetFileSystem: String;
begin
  Result := '';
end;

function TModuleCreator.GetOwner: IOTAModule;
begin
  Result := FProject;
end;

function TModuleCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

procedure TModuleCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin
end;

function TModuleCreator.GetAncestorName: String;
begin
  Result := 'TForm';
end;

function TModuleCreator.GetFormName: String;
begin
  Result := 'MyForm1';
end;

function TModuleCreator.GetImplFileName: String;
begin
  Result := GetCurrentDir + '\' + strProjectTemplate[FAdditionalModule].FModuleName;
end;

function TModuleCreator.GetIntfFileName: String;
begin
  Result := '';
end;

function TModuleCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TModuleCreator.GetShowForm: Boolean;
begin
  REsult := False;
end;

function TModuleCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TModuleCreator.NewFormFile(const FormIdent, AncestorIdent: String): IOTAFile;
begin
  Result := Nil;
end;

function TModuleCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  Result := TModuleCreatorFile.Create(FProjectWizardInfo, FAdditionalModule);
end;

function TModuleCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  Result := Nil;
end;

{ TModuleCreatorFile }

constructor TModuleCreatorFile.Create(ProjectWizardInfo : TProjectWizardInfo;
  AdditionalModule : TAdditionalModule);
begin
  FProjectWizardInfo := ProjectWizardInfo;
  FAdditionalModule := AdditionalModule;
end;

function TModuleCreatorFile.ExpandMacro(strText, strMacroName, strReplaceText: String): String;

Var
  iPos : Integer;

begin
  iPos := Pos(LowerCase(strMacroName), LowerCase(strText));
  Result := strText;
  While iPos > 0 Do
    Begin
      Result :=
        Copy(strText, 1, iPos - 1) +
        strReplaceText +
        Copy(strText, iPos + Length(strMacroName), Length(strText) - iPos + 1 - Length(strMacroName));
      iPos := Pos(LowerCase(strMacroName), LowerCase(Result));
    End;
end;

function TModuleCreatorFile.GetAge: TDateTime;
begin
  Result := -1;
end;

function TModuleCreatorFile.GetFinaliseWizardCode: String;
begin
  If amKeyboardBindingInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Remove Keyboard Binding Interface'#13#10 +
      '  If iKeyBindingIndex > iWizardFailState Then'#13#10 +
      '    (BorlandIDEServices As IOTAKeyboardServices).RemoveKeyboardBinding(iKeyBindingIndex);'#13#10;
  If amIDENotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Remove IDE Notifier Interface'#13#10 +
      '  If iIDENotfierIndex > iWizardFailState Then'#13#10 +
      '    (BorlandIDEServices As IOTAServices).RemoveNotifier(iIDENotfierIndex);'#13#10;
  If amCompilerNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D2010}'#13#10 +
      '  // Remove Compiler Notifier Interface'#13#10 +
      '  If iCompilerIndex <> iWizardFailState Then'#13#10 +
      '    (BorlandIDEServices As IOTACompileServices).RemoveNotifier(iCompilerIndex);'#13#10 +
      '  {$ENDIF}'#13#10;
  If amEditorNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D2005}'#13#10 +
      '  // Remove Editor Notifier Interface'#13#10 +
      '  If iEditorIndex <> iWizardFailState Then'#13#10 +
      '    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(iEditorIndex);'#13#10 +
      '  {$ENDIF}'#13#10;
  If amRepositoryWizardInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Remove Repository Wizard Interface'#13#10 +
      '  If iRepositoryWizardIndex <> iWizardFailState Then'#13#10 +
      '    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iRepositoryWizardIndex);'#13#10;
end;

function TModuleCreatorFile.GetInitialiseWizardCode: String;
begin
  If amKeyboardBindingInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Create Keyboard Binding Interface'#13#10 +
      '  iKeyBindingIndex := (BorlandIDEServices As IOTAKeyboardServices).AddKeyboardBinding('#13#10 +
      '    TKeybindingTemplate.Create);'#13#10;
  If amIDENotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Create IDE Notifier Interface'#13#10 +
      '  iIDENotfierIndex := (BorlandIDEServices As IOTAServices).AddNotifier('#13#10 +
      '    TIDENotifierTemplate.Create);'#13#10;
  If amCompilerNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D2010}'#13#10 +
      '  // Create Compiler Notifier Interface'#13#10 +
      '  iCompilerIndex := (BorlandIDEServices As IOTACompileServices).AddNotifier('#13#10 +
      '    TCompilerNotifier.Create);'#13#10 +
      '  {$ENDIF}'#13#10;
  If amEditorNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D2005}'#13#10 +
      '  // Create Editor Notifier Interface'#13#10 +
      '  iEditorIndex := (BorlandIDEServices As IOTAEditorServices).AddNotifier('#13#10 +
      '    TEditorNotifier.Create);'#13#10 +
      '  {$ENDIF}'#13#10;
  If amRepositoryWizardInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  // Create Project Repository Interface'#13#10 +
      '  iRepositoryWizardIndex := (BorlandIDEServices As IOTAWizardServices).AddWizard('#13#10 +
      '    TRepositoryWizardInterface.Create);'#13#10;
end;

function TModuleCreatorFile.GetSource: string;

Const
  WizardMenu : Array[False..True] Of String = ('', ', IOTAMenuWizard');

ResourceString
  strResourceMsg = 'The OTA Module Template ''%s'' was not found.';

Var
  Res: TResourceStream;
  {$IFDEF D2009}
  strTemp: AnsiString;
  {$ENDIF}

begin
  Res := TResourceStream.Create(HInstance, strProjectTemplate[FAdditionalModule].FResourceName,
    RT_RCDATA);
  Try
    If Res.Size = 0 Then
      Raise Exception.CreateFmt(strResourceMsg,
        [strProjectTemplate[FAdditionalModule].FResourceName]);
    {$IFNDEF D2009}
    SetLength(Result, Res.Size);
    Res.ReadBuffer(Result[1], Res.Size);
    {$ELSE}
    SetLength(strTemp, Res.Size);
    Res.ReadBuffer(strTemp[1], Res.Size);
    Result := String(strTemp);
    {$ENDIF}
  Finally
    Res.Free;
  End;
  Result := ExpandMacro(Result, '$MODULENAME$', ChangeFileExt(strProjectTemplate[FAdditionalModule].FModuleName, ''));
  Result := ExpandMacro(Result, '$USESCLAUSE$', GetUsesClauseCode);
  Result := ExpandMacro(Result, '$VARIABLEDECL$', GetVariableDeclCode);
  Result := ExpandMacro(Result, '$INITIALISEWIZARD$', GetInitialiseWizardCode);
  Result := ExpandMacro(Result, '$FINALISEWIZARD$', GetFinaliseWizardCode);
  Result := ExpandMacro(Result, '$WIZARDNAME$', FProjectWizardInfo.FWizardName);
  Result := ExpandMacro(Result, '$WIZARDIDSTRING$', FProjectWizardInfo.FWizardIDString);
  Result := ExpandMacro(Result, '$WIZARDMENUTEXT$', FProjectWizardInfo.FWizardMenuText);
  Result := ExpandMacro(Result, '$AUTHOR$', FProjectWizardInfo.FWizardAuthor);
  Result := ExpandMacro(Result, '$WIZARDDESCRIPTION$', FProjectWizardInfo.FWizardDescription);
  Result := ExpandMacro(Result, '$WIZARDMENUREQUIRED$', WizardMenu[FProjectWizardInfo.FWizardMenu]);
end;

function TModuleCreatorFile.GetUsesClauseCode: String;
begin
  If amKeyboardBindingInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result + '  KeyboardBindingInterface,'#13#10;
  If amIDENotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result + '  IDENotifierInterface,'#13#10;
  If amCompilerNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result + '  CompilerNotifierInterface,'#13#10;
  If amEditorNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result + '  EditorNotifierInterface,'#13#10;
  If amRepositoryWizardInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result + '  RepositoryWizardInterface,'#13#10;
end;

function TModuleCreatorFile.GetVariableDeclCode: String;
begin
  If amKeyboardBindingInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  iKeyBindingIndex       : Integer = iWizardFailState;'#13#10;
  If amIDENotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  iIDENotfierIndex       : Integer = iWizardFailState;'#13#10;
  If amCompilerNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D2010}'#13#10 +
      '  iCompilerIndex         : Integer = iWizardFailState;'#13#10 +
      '  {$ENDIF}'#13#10;
  If amEditorNotifierInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  {$IFDEF D0006}'#13#10 +
      '  iEditorIndex           : Integer = iWizardFailState;'#13#10 +
      '  {$ENDIF}'#13#10;
  If amRepositoryWizardInterface In FProjectWizardInfo.FAdditionalModules Then
    Result := Result +
      '  iRepositoryWizardIndex : Integer = iWizardFailState;'#13#10;
end;

End.
