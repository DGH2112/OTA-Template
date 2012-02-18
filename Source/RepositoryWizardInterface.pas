Unit RepositoryWizardInterface;

Interface

Uses
  ToolsAPI,
  Windows,
  RepositoryWizardForm;

{$INCLUDE CompilerDefinitions.inc}

Type
  TRepositoryWizardInterface = Class(TNotifierObject, IOTAWizard, IOTARepositoryWizard
    {$IFDEF D0006}, IOTARepositoryWizard60 {$ENDIF}
    {$IFDEF D2005}, IOTARepositoryWizard80 {$ENDIF},
    IOTAProjectWizard
    {$IFDEF D2005}, IOTAProjectWizard100 {$ENDIF})
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProject : IOTAProject;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure CreateProject(strProjectName : String; enumProjectType : TProjectType;
      enumAdditionalModules : TAdditionalModules);
  Public
    {$IFDEF D2005}
    Constructor Create;
    {$ENDIF}
    // IOTAWizard
    Procedure Execute;
    Function GetIDString: String;
    Function GetName: String;
    Function GetState: TWizardState;
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    // IOTARepositoryWizard
    Function GetAuthor: String;
    Function GetComment: String;
    {$IFDEF D0006}
    Function GetGlyph: Cardinal;
    {$ELSE}
    Function GetGlyph: HICON;
    {$ENDIF}
    Function GetPage: String;
    {$IFDEF D0006}
    // IOTARepositoryWizard60
    Function GetDesigner: String;
    {$ENDIF}
    {$IFDEF D2005}
    // IOTARepositoryWizard80
    Function GetGalleryCategory: IOTAGalleryCategory;
    Function GetPersonality: String;
    {$ENDIF}
    // IOTAProjectWizard
    {$IFDEF D2005}
    // IOTAProjectWizard100
    Function IsVisible(Project: IOTAProject): Boolean;
    {$ENDIF}
  End;

Implementation

Uses
  Dialogs,
  UtilityFunctions,
  SysUtils,
  ProjectCreatorInterface;

{$IFDEF D0006}
ResourceString
  strRepositoryWizardGroup = 'Repository Wizard Messages';
{$ENDIF}
{$IFDEF D2005}
ResourceString
  strMyCustomCategory = 'OTA Custom Gallery Category';
{$ENDIF}

{ TRepositoryWizardInterface }

Procedure TRepositoryWizardInterface.AfterSave;

Begin
  OutputMessage('AfterSave' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

Procedure TRepositoryWizardInterface.BeforeSave;

Begin
  OutputMessage('BeforeSave' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

procedure TRepositoryWizardInterface.CreateProject(strProjectName : String;
  enumProjectType : TProjectType; enumAdditionalModules : TAdditionalModules);

Var
  P: TProjectCreator;

begin
  P := TProjectCreator.Create(strProjectName, enumProjectType);
  FProject := (BorlandIDEServices As IOTAModuleServices).CreateModule(P) As IOTAProject;
end;

{$IFDEF D2005}
Constructor TRepositoryWizardInterface.Create;

Begin
  With (BorlandIDEServices As IOTAGalleryCategoryManager) Do
    Begin
      AddCategory(FindCategory(sCategoryDelphiNew), strMyCustomCategory,
        'OTA Custom Gallery Category');
    End;
End;
{$ENDIF}

Procedure TRepositoryWizardInterface.Destroyed;

Begin
  OutputMessage('Destroyed' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

Procedure TRepositoryWizardInterface.Execute;

Var
  strProjectName : String;
  enumProjectType : TProjectType;
  enumAdditionalModules : TAdditionalModules;

Begin
  If TfrmRepositoryWizard.Execute(strProjectName, enumProjectType,
    enumAdditionalModules) Then
    CreateProject(strProjectname, enumProjectType, enumAdditionalModules);
End;

Function TRepositoryWizardInterface.GetAuthor: String;

Begin
  Result := 'David Hoyle';
End;

Function TRepositoryWizardInterface.GetComment: String;

Begin
  Result := 'This is an example of an OTA Repository Wizard';
End;

{$IFDEF D0006}
Function TRepositoryWizardInterface.GetDesigner: String;

Begin
  Result := dVCL;
End;
{$ENDIF}

{$IFDEF D2005}
Function TRepositoryWizardInterface.GetGalleryCategory: IOTAGalleryCategory;

Begin
  Result := (BorlandIDEServices As IOTAGalleryCategoryManager).FindCategory(strMyCustomCategory);
End;
{$ENDIF}

{$IFDEF D0006}
Function TRepositoryWizardInterface.GetGlyph: Cardinal;
{$ELSE}
Function TRepositoryWizardInterface.GetGlyph: HICON;
{$ENDIF}

Begin
  Result := LoadIcon(hInstance, 'RepositoryWizardProjectIcon')
End;

Function TRepositoryWizardInterface.GetIDString: String;

Begin
  Result := 'OTA.Repository.Wizard.Example';
End;

Function TRepositoryWizardInterface.GetName: String;

Begin
  Result := 'OTA Repository Wizard Example';
End;

Function TRepositoryWizardInterface.GetPage: String;

Begin
  Result := 'OTA Examples';
End;

{$IFDEF D2005}
Function TRepositoryWizardInterface.GetPersonality: String;

Begin
  Result := sDelphiPersonality;
End;
{$ENDIF}

Function TRepositoryWizardInterface.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

{$IFDEF D2005}
Function TRepositoryWizardInterface.IsVisible(Project: IOTAProject): Boolean;

Begin
  Result := True;
End;
{$ENDIF}

Procedure TRepositoryWizardInterface.Modified;

Begin
  OutputMessage('Modified' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

Initialization
Finalization
  ClearMessages([cmCompiler..cmTool]);
End.
