Unit ProjectCreatorInterface;

Interface

Uses
  ToolsApi,
  RepositoryWizardForm;

{$INCLUDE CompilerDefinitions.inc}

Type
  TProjectCreator = Class(TInterfacedObject, IOTACreator, IOTAProjectCreator
    {$IFDEF D0005}, IOTAProjectCreator50 {$ENDIF}
    {$IFDEF D0008}, IOTAProjectCreator80 {$ENDIF}
  )
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProjectWizardInfo : TProjectWizardInfo;
  {$IFDEF D2005} Strict {$ENDIF} Protected
  Public
    Constructor Create(ProjectWizardInfo : TProjectWizardInfo);
    // IOTACreator
    Function  GetCreatorType: String;
    Function  GetExisting: Boolean;
    Function  GetFileSystem: String;
    Function  GetOwner: IOTAModule;
    Function  GetUnnamed: Boolean;
    // IOTAProjectCreator
    Function  GetFileName: String;
    Function  GetOptionFileName: String; {$IFNDEF D0005} Deprecated; {$ENDIF}
    Function  GetShowSource: Boolean;
    Procedure NewDefaultModule; {$IFNDEF D0005} Deprecated; {$ENDIF}
    Function  NewOptionSource(Const ProjectName: String): IOTAFile; {$IFNDEF D0005} Deprecated; {$ENDIF}
    Procedure NewProjectResource(Const Project: IOTAProject);
    Function  NewProjectSource(Const ProjectName: String): IOTAFile;
    {$IFDEF D0005}
    // IOTAProjectCreator50
    Procedure NewDefaultProjectModule(Const Project: IOTAProject);
    {$ENDIF}
    {$IFDEF D2005}
    // IOTAProjectCreator80
    Function  GetProjectPersonality: String;
    {$ENDIF}
  End;

  TProjectCreatorFile = Class(TInterfacedObject, IOTAFile)
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProjectWizardInfo : TProjectWizardInfo;
  Public
    Constructor Create(ProjectWizardInfo: TProjectWizardInfo);
    function GetAge: TDateTime;
    function GetSource: string;
  End;

Implementation

Uses
  SysUtils,
  Classes,
  Windows,
  UtilityFunctions, ModuleCreatorInterface;

{ TProjectCreator }

constructor TProjectCreator.Create(ProjectWizardInfo : TProjectWizardInfo);

begin
  FProjectWizardInfo := ProjectWizardInfo;
end;

function TProjectCreator.GetCreatorType: String;
begin
  Result := '';
end;

function TProjectCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TProjectCreator.GetFileName: String;
begin
  Case FProjectWizardInfo.FProjectType Of
    //ptApplication: Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpr';
    ptPackage:     Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpk';
    ptDLL:         Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpr';
  Else
    Raise Exception.Create('Unhandled project type in TProjectCreator.GetFileName.');
  End;
end;

function TProjectCreator.GetFileSystem: String;
begin
  Result := '';
end;

function TProjectCreator.GetOptionFileName: String;
begin
  Result := '';
end;

function TProjectCreator.GetOwner: IOTAModule;
begin
  Result := ProjectGroup;
end;

{$IFDEF D2005}
function TProjectCreator.GetProjectPersonality: String;
begin
  Result := sDelphiPersonality;
end;
{$ENDIF}

function TProjectCreator.GetShowSource: Boolean;
begin
  Result := False;
end;

function TProjectCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

procedure TProjectCreator.NewDefaultModule;
begin
  //
end;

{$IFDEF D0005}
procedure TProjectCreator.NewDefaultProjectModule(const Project: IOTAProject);

Var
  M: TModuleCreator;
  iModule: TAdditionalModule;

begin
  For iModule := Low(TAdditionalModule) To High(TAdditionalModule) Do
    If iModule In FProjectWizardInfo.FAdditionalModules Then
      Begin
        M := TModuleCreator.Create(Project, FProjectWizardInfo, iModule);
        (BorlandIDEServices As IOTAModuleServices).CreateModule(M);
      End;
end;
{$ENDIF}

function TProjectCreator.NewOptionSource(const ProjectName: String): IOTAFile;
begin
  Result := Nil;
end;

procedure TProjectCreator.NewProjectResource(const Project: IOTAProject);
begin
  //
end;

function TProjectCreator.NewProjectSource(const ProjectName: String): IOTAFile;
begin
  Result := TProjectCreatorFile.Create(FProjectWizardInfo);
end;

{ TProjectCreatorFile }

constructor TProjectCreatorFile.Create(ProjectWizardInfo: TProjectWizardInfo);
begin
  FProjectWizardInfo := ProjectWizardInfo;
end;

function TProjectCreatorFile.GetAge: TDateTime;
begin
  Result := -1;
end;

function TProjectCreatorFile.GetSource: string;

Const
  strProjectTemplate : Array[Low(TProjectType)..High(TProjectType)] Of String = (
    //'OTAProjectProgramSource',
    'OTAProjectPackageSource',
    'OTAProjectDLLSource'
  );

ResourceString
  strResourceMsg = 'The OTA Project Template ''%s'' was not found.';

Var
  Res: TResourceStream;
  {$IFDEF D2009}
  strTemp: AnsiString;
  {$ENDIF}

begin
  Res := TResourceStream.Create(HInstance,
    strProjectTemplate[FProjectWizardInfo.FProjectType], RT_RCDATA);
  Try
    If Res.Size = 0 Then
      Raise Exception.CreateFmt(strResourceMsg, [strProjectTemplate[FProjectWizardInfo.FProjectType]]);
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
  Result := Format(Result, [FProjectWizardInfo.FProjectName]);
end;

End.
