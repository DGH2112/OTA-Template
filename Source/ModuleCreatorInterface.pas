(**

  This module contains a class that handles the IOTAModuleCreate interface for
  creating modules within the IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    23 Mar 2012

**)
Unit ModuleCreatorInterface;

Interface

Uses
  ToolsAPI,
  RepositoryWizardForm;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class which implments the IOTAModuleCreator interface. **)
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

  (** A class that implements the IOTAFile interface for creating the source
     code for the modules. **)
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
  (** A record to describe the resource associated with a module. **)
  TModuleInfo = Record
    FResourceName : String;
    FModuleName   : String;
  End;

Const
  (** A constant array that defines the names of the modules and their
      windows resources so that they can be loaded from this addins resource. **)
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

(**

  This is the constructor for the TModuleCreator class.

  @precon  AProject must be a valid instance.
  @postcon Stores all the information for creating modules in internal variables.

  @param   AProject          as an IOTAProject
  @param   ProjectWizardInfo as a TProjectWizardInfo
  @param   AdditionalModule  as a TAdditionalModule

**)
constructor TModuleCreator.Create(AProject: IOTAProject; ProjectWizardInfo : TProjectWizardInfo;
  AdditionalModule : TAdditionalModule);
begin
  FProject := AProject;
  FProjectWizardInfo := ProjectWizardInfo;
  FAdditionalModule := AdditionalModule;
end;

(**

  Returns the creator type.

  GetCreatorType returns the type of the creator as a string.

  The creator type can be an empty string, which means the creator provides all
  necessary information, or it can be one of the following predefined strings.
  Using a predefined string tells C++ Builder to create a default module, based
  on the object repository and rules built into the IDE.

  Value	Meaning

  sApplication	Create a default application (IOTAProjectCreator).
  sLibrary	    Create a default library (IOTAProjectCreator).
  sConsole	    Create a default console application (IOTAProjectCreator).
  sPackage	    Create a default package (IOTAProjectCreator).
  sUnit	        Create a default unit source file (IOTAModuleCreator).
  sForm	        Create a default form (IOTAModuleCreator).
  sText	        Create an empty text file (IOTAModuleCreator).

  @precon  None.
  @postcon This returns sUnit as we are creating a unit module.

  @return  a String

**)
function TModuleCreator.GetCreatorType: String;
begin
  Result := sUnit;
end;

(**

  Indicates whether the file already exists.

  GetExisting should return true if the module represents a file that already
  exists. It should return false if the module is for a newly created file.

  @precon  None.
  @postcon We return false to indicate that the file does not exist.

  @return  a Boolean

**)
function TModuleCreator.GetExisting: Boolean;
begin
  Result := False;
end;

(**

  Returns the name of the virtual file system.

  GetFileSystem returns the ID string of the virtual file system for the module.
  It returns an empty string if the module does not use a virtual file system
  (which is the most common case).

  @precon  None.
  @postcon Returns an empty string to denote that the default file system should
           be used.

  @return  a String

**)
function TModuleCreator.GetFileSystem: String;
begin
  Result := '';
end;

(**

  Returns the module’s owner.

  GetOwner returns the module interface of the new module’s owner, that is, it
  returns the project interface for a new source file or the project group
  interface for a new project.

  You can create a module that does not have an owner by returning 0.

  @precon  None.
  @postcon Return the project passed in the constructor as the owner of the
           new modules.

  @return  an IOTAModule

**)
function TModuleCreator.GetOwner: IOTAModule;
begin
  Result := FProject;
end;

(**

  Indicates whether the new module is unnamed.

  GetUnnamed returns true if the new module has not been saved to a file and
  therefore does not have a file name yet.

  If the user saves the module, the user will be prompted for a file name.

  GetUnnamed returns false if the module has a file name.

  @precon  None.
  @postcon We return true to signify that this module is unnamed and needs to be
           saved.

  @return  a Boolean

**)
function TModuleCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

(**

  Callback after the form is created. If the module creator creates a form, the
  IDE calls back to the creator’s FormCreated method.

  The creator can use this method to populate the form with components, or do
  anything else with the form interface.

  Often, FormCreated does nothing and returns immediately.

  The FormEditor parameter is a reference to the new module’s form editor.

  Use the form editor to add components to the form, modify the form’s
  properties. As with any interface, do not free the form editor.

  @precon  None.
  @postcon We do nothing here as we are not working with a form.

  @param   FormEditor as an IOTAFormEditor as a constant

**)
procedure TModuleCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin
end;

(**

  Returns the ancestor form name.

  Implement the GetAncestorName to return the name (not the type) of the
  ancestor form if you are using form inheritance.

  Return an empty string for an ordinary unit or form. Return “DataModule” to
  create a custom data module.

  @precon  None.
  @postcon We return an empty string as we are not working with a form.

  @return  a String

**)
function TModuleCreator.GetAncestorName: String;
begin
  Result := '';
end;

(**

  Returns the name of the form.

  GetFormName returns the name (not the type) of the form to create, e.g.,
  “Form1”.

  Return an empty string to create a unit that has no form.

  @precon  None.
  @postcon We return an empty string to signify that we are working with a unit.

  @return  a String

**)
function TModuleCreator.GetFormName: String;
begin
  Result := '';
end;

(**

  Returns the implementation file name. GetImplFileName returns the complete
  path to the implementation (.cpp) file name, e.g. “C:\dir\Unit1.cpp”.

  If GetUnnamed returns true, the file name is just a placeholder, and the user
  will be prompted for a file name when the file is saved.

  @precon  None.
  @postcon Returns a valid filename for the module.

  @return  a String

**)
function TModuleCreator.GetImplFileName: String;
begin
  Result := GetCurrentDir + '\' + strProjectTemplate[FAdditionalModule].FModuleName;
end;

(**

  Returns the interface file name.

  GetIntfFileName returns the complete path to the interface (.h) file name,
  e.g. “C:\dir\Unit1.h”.

  If GetUnnamed returns true, the file name is just a placeholder, and the user
  will be prompted for a file name when the file is saved.

  @precon  None.
  @postcon Returns an emplt string as there is no implementation file for
           pascal.

  @return  a String

**)
function TModuleCreator.GetIntfFileName: String;
begin
  Result := '';
end;

(**

  Indicates whether the form is the main form.

  GetMainForm returns true if the newly created form is to be the application’s
  main form.

  It returns false if the form is not necessarily the main form.

  (As usual, the first form in the application is automatically the main form,
  even if GetMainForm returns false.)

  @precon  None.
  @postcon Returns false as this is not a form.

  @return  a Boolean

**)
function TModuleCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

(**

  Indicates whether the IDE should show the form editor.

  The ShowForm property maps to the GetShowForm method, which returns true if
  the IDE should show the form editor.

  @precon  None.
  @postcon Returns false as this is not a form.

  @return  a Boolean

**)
function TModuleCreator.GetShowForm: Boolean;
begin
  REsult := False;
end;

(**

  Indicates whether the IDE should show the source code.

  The ShowSource property maps to the GetShowSource method, which returns true
  if the IDE should show the new source file in the source editor.

  @precon  None.
  @postcon Returns true to have the IDE display the source code.

  @return  a Boolean

**)
function TModuleCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

(**

  Returns the new form description.

  NewFormFile returns the new form description or 0 to use the default form
  description.

  The form description must be binary or text form resource.

  The FormIdent parameter is the name of the form.

  Use this to parameterize the form description.

  The AncestorIdent parameter is the name of the ancestor form.

  Use this to parameterize the form description.

  The return value is an instance of a file creator class that you must write,
  deriving from IOTAFile.

  If you return 0, C++ Builder creates a default form.

  @precon  None.
  @postcon Return Nil as this module is not creating a form.

  @param   FormIdent     as a String as a constant
  @param   AncestorIdent as a String as a constant
  @return  an IOTAFile

**)
function TModuleCreator.NewFormFile(const FormIdent, AncestorIdent: String): IOTAFile;
begin
  Result := Nil;
end;

(**

  Returns the new implementation source.

  NewImplSource returns the source code for the new module’s implementation or 0
  for a default unit.

  The ModuleIdent parameter is the name of the unit or module, e.g., “Unit1”.

  Use this to parameterize the file contents.

  The FormIdent parameter is the name of the form. Use this to parameterize the
  file contents.

  The AncestorIdent parameter is the name of the ancestor form.

  Use this to parameterize the file contents.

  The return value is an instance of a file creator class that you must write,
  deriving from IOTAFile.

  If you return 0, C++ Builder creates a default unit.

  @precon  None.
  @postcon We return an instance of an IOTAFile interface that provides the
           source code to our module.

  @param   ModuleIdent   as a String as a constant
  @param   FormIdent     as a String as a constant
  @param   AncestorIdent as a String as a constant
  @return  an IOTAFile

**)
function TModuleCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  Result := TModuleCreatorFile.Create(FProjectWizardInfo, FAdditionalModule);
end;

(**

  Returns the new interface source.

  NewIntfSource returns the source code for the new module’s interface or 0 for
  a default header.

  The ModuleIdent parameter is the name of the unit or module, e.g., “Unit1”.

  Use this to parameterize the file contents.

  The FormIdent parameter is the name of the form.

  Use this to parameterize the file contents.

  The AncestorIdent parameter is the name of the ancestor form.

  Use this to parameterize the file contents.

  The return value is an instance of a file creator class that you must write,
  deriving from IOTAFile.

  If you return 0, C++ Builder creates a default header.

  @precon  None.
  @postcon We return nil as there is no interface file.

  @param   ModuleIdent   as a String as a constant
  @param   FormIdent     as a String as a constant
  @param   AncestorIdent as a String as a constant
  @return  an IOTAFile

**)
function TModuleCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  Result := Nil;
end;

{ TModuleCreatorFile }

(**

  This is the constructor for the TModuleCreatorFile class.

  @precon  None.
  @postcon Stored the passed information for use by the methods that are invoked
           by the IDE.

  @param   ProjectWizardInfo as a TProjectWizardInfo
  @param   AdditionalModule  as a TAdditionalModule

**)
constructor TModuleCreatorFile.Create(ProjectWizardInfo : TProjectWizardInfo;
  AdditionalModule : TAdditionalModule);
begin
  FProjectWizardInfo := ProjectWizardInfo;
  FAdditionalModule := AdditionalModule;
end;

(**

  This method searches the givcen test for the macro name and replaces all
  instances with the replacement text and returns this modified string.

  @precon  None.
  @postcon Searches the givcen test for the macro name and replaces all
           instances with the replacement text and returns this modified string.

  @param   strText        as a String
  @param   strMacroName   as a String
  @param   strReplaceText as a String
  @return  a String

**)
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

(**

  Returns the file’s age.

  GetAge returns the file’s modification date and time.

  If the file does not exist, GetAge returns –1.

  @precon  None.
  @postcon we retuen -1 to indicate that the file is not saved.

  @return  a TDateTime

**)
function TModuleCreatorFile.GetAge: TDateTime;
begin
  Result := -1;
end;

(**

  This method builds a string which represents the finalisation code for the
  main interface module based on the option selected.

  @precon  None.
  @postcon Returns a string which represents the finalisation code for the
           main interface module based on the option selected.

  @return  a String

**)
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

(**

  This method builds an initialisation code section based on the selected
  options.

  @precon  None.
  @postcon Returns an initialisation code section based on the selected
           options.

  @return  a String

**)
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

(**

  Returns the file’s contents.

  GetSource returns the file’s contents as a string.

  @precon  None.
  @postcon We return the source string for the module which is retrieved from
           the addins resources and then patched with information using the
           macro expansions.

  @return  a string

**)
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

(**

  This method builds a string for the main interfaces uses clause based on the
  selected options.

  @precon  None.
  @postcon Returns a string for the main interfaces uses clause based on the
           selected options.

  @return  a String

**)
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

(**

  This method builds a string for the main interface modules var clause based on
  the selected options.

  @precon  None.
  @postcon Returns a string for the main interface modules var clause based on
           the selected options.

  @return  a String

**)
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
