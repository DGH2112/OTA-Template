(**
  
  This module contains a class to handle the creation of projects through the
  Open Tools API inside Delphi.

  @Version 1.0
  @Author  David Hoyle
  @Date    27 Mar 2016

**)
Unit ProjectCreatorInterface;

Interface

Uses
  ToolsApi,
  RepositoryWizardForm;

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

Type
  (** A class to handle the project creation within the IDE. **)
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

  (** A class to handle the creation of the source code required for the
      project. **)
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

(**

  This is a constructor for the TProjectCreator class.

  @precon  None.
  @postcon Holds a copy of the ProjectWizardInfo information.

  @param   ProjectWizardInfo as a TProjectWizardInfo

**)
Constructor TProjectCreator.Create(ProjectWizardInfo : TProjectWizardInfo);

Begin
  FProjectWizardInfo := ProjectWizardInfo;
End;

(**

  GetCreatorType returns the type of the creator as a string. The creator type
  can be an empty string, which means the creator provides all necessary
  information, or it can be one of the following predefined strings. Using a
  predefined string tells C++ Builder to create a default module, based on the
  object repository and rules built into the IDE.

    sApplication  Create a default application (IOTAProjectCreator).
    sLibrary      Create a default library (IOTAProjectCreator).
    sConsole      Create a default console application (IOTAProjectCreator).
    sPackage      Create a default package (IOTAProjectCreator).
    sUnit         Create a default unit source file (IOTAModuleCreator).
    sForm         Create a default form (IOTAModuleCreator).
    sText         Create an empty text file (IOTAModuleCreator).

  @precon  None.
  @postcon Returns an empty string to signify that all information will be
           provided by the class.

  @return  a String

**)
Function TProjectCreator.GetCreatorType: String;

Begin
  Result := '';
End;

(**

  Indicates whether the file already exists.

  GetExisting should return true if the module represents a file that already
  exists. It should return false if the module is for a newly created file.

  @precon  None.
  @postcon Returns false to signify that the file does not exist.

  @return  a Boolean

**)
Function TProjectCreator.GetExisting: Boolean;

Begin
  Result := False;
End;

(**

  Returns the file name.

  GetFileName returns the complete path to the project source file.

  @precon  None.
  @postcon Returns the name of the new project WITH EXTENSION.

  @return  a String

**)
Function TProjectCreator.GetFileName: String;

Begin
  Case FProjectWizardInfo.FProjectType Of
    //ptApplication: Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpr';
    ptPackage:     Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpk';
    ptDLL:         Result := GetCurrentDir + '\' + FProjectWizardInfo.FProjectName + '.dpr';
  Else
    Raise Exception.Create('Unhandled project type in TProjectCreator.GetFileName.');
  End;
End;

(**

  Returns the name of the virtual file system.

  GetFileSystem returns the ID string of the virtual file system for the module.
  It returns an empty string if the module does not use a virtual file system
  (which is the most common case).

  @precon  None.
  @postcon Returns an empty string to signify that it does not use a virtual
           file system.

  @return  a String

**)
Function TProjectCreator.GetFileSystem: String;

Begin
  Result := '';
End;

(**

  Returns the options file name.

  GetOptionFileName returns the complete path to the project options source
  file, which typically is the same as the project source file, but with the
  “.bof” extension.

  @precon  None.
  @postcon Returns an empty string.

  @return  a String

**)
Function TProjectCreator.GetOptionFileName: String;

Begin
  Result := '';
End;

(**

  Returns the module’s owner.

  GetOwner returns the module interface of the new module’s owner, that is, it
  returns the project interface for a new source file or the project group
  interface for a new project. You can create a module that does not have an
  owner by returning 0.

  @precon  None.
  @postcon Returns the projects parent project group using a utility function.

  @return  an IOTAModule

**)
Function TProjectCreator.GetOwner: IOTAModule;

Begin
  Result := ProjectGroup;
End;

{$IFDEF D2005}
(**

  Implement this interface and return the correct personality of the project
  to create.  The CreatorType function should return any sub-types that this
  personality can create.  For instance, in the Delphi.Personality, returning
  'Package' from CreatorType will create a proper package project.

  This is the default personality that is used to register default file
    personality traits.

    sDefaultPersonality = 'Default.Personality';

  The following are Borland created personalities

    sDelphiPersonality       = 'Delphi.Personality';
    sDelphiDotNetPersonality = 'DelphiDotNet.Personality';
    sCBuilderPersonality     = 'CPlusPlusBuilder.Personality';
    sCSharpPersonality       = 'CSharp.Personality';
    sVBPersonality           = 'VB.Personality';
    sDesignPersonality       = 'Design.Personality';
    sGenericPersonality      = 'Generic.Personality';

  @precon  None.
  @postcon Returns the Delphi personality string.

  @return  a String

**)
Function TProjectCreator.GetProjectPersonality: String;

Begin
  Result := sDelphiPersonality;
End;
{$ENDIF}

(**

  Indicates whether the IDE should show the source file.

  GetShowSource returns true to tell the IDE to show the project source file in
  the source editor. It returns false to hide the project file.

  @precon  None.
  @postcon Returns false to signify that the source should not be shown once the
           project is created.

  @return  a Boolean

**)
Function TProjectCreator.GetShowSource: Boolean;

Begin
  Result := False;
End;

(**

  Indicates whether the new module is unnamed.

  GetUnnamed returns true if the new module has not been saved to a file and
  therefore does not have a file name yet. If the user saves the module, the
  user will be prompted for a file name. GetUnnamed returns false if the module
  has a file name.

  @precon  None.
  @postcon Returns true to signify that the project has not been saved and will
           require saving.

  @return  a Boolean

**)
Function TProjectCreator.GetUnnamed: Boolean;

Begin
  Result := True;
End;

(**

  Callback after creating the project.

  After the IDE creates the project, it calls back to the creator`s
  NewDefaultModule method, which you can use to populate the project with a new
  module. This method is obsolete and has been replaced by
  IOTAProjectCreator50::NewDefaultProjectModule.

  @precon  None.
  @postcon Do nothing. Modules created in NewDefaultProjectModule.

**)
Procedure TProjectCreator.NewDefaultModule;

Begin
  //
End;

{$IFDEF D0005}
(**

  Callback after the IDE creates the project.

  After the IDE creates the project module, it calls back to the creator`s
  NewDefaultProjectModule member function. You can write this function to do
  whatever you want, such as create new modules to add to the project or set the
  project options. You can also choose to return without doing anything.

  The Project parameter is the module interface for the newly created project.

  @precon  None.
  @postcon Create the variable modules selected by the user.

  @param   Project as a IOTAProject

**)
Procedure TProjectCreator.NewDefaultProjectModule(Const Project: IOTAProject);

Var
  M: TModuleCreator;
  iModule: TAdditionalModule;

Begin
  For iModule := Low(TAdditionalModule) To High(TAdditionalModule) Do
    If iModule In FProjectWizardInfo.FAdditionalModules Then
      Begin
        M := TModuleCreator.Create(Project, FProjectWizardInfo, iModule);
        (BorlandIDEServices As IOTAModuleServices).CreateModule(M);
      End;
End;
{$ENDIF}

(**

  Returns the new project options.

  NewOptionSource returns the contents of the project options file or 0 for
  default options.

  The ProjectName parameter is the name of the project, which you can use to
  parameterize the options file contents.

  The return value is an instance of a class that provides the options file
  contents, or NewOptionSource returns 0 for default options. You must write the
  class that implements IOTAFile.

  It is your responsibility to use the correct format for the project options.
  To avoid formatting problems, you might prefer to use the IOTAProjectOptions
  interface to set the project options.

  @precon  None.
  @postcon Returns nil to signify a default option file created by Delphi.

  @param   ProjectName as a String as a constant
  @return  an IOTAFile

**)
Function TProjectCreator.NewOptionSource(Const ProjectName: String): IOTAFile;

Begin
  Result := Nil;
End;

(**

  Callback for creating the project resource file.

  After the IDE creates the new project module, it calls back to
  NewProjectResource, which can create the project resource file.

  The ProjectName parameter is the name of the project, which you can use to
  parameterize the project resources.

  @precon  None.
  @postcon Does nothing.

  @param   Project as an IOTAProject as a constant

**)
Procedure TProjectCreator.NewProjectResource(Const Project: IOTAProject);

Begin
  //
End;

(**

  Returns the project source file contents.

  NewProjectSource returns the contents of the project file or 0 to create a
  default project.

  The ProjectName parameter is the name of the project, which you can use to
  parameterize the project file contents.

  The return value is an instance of a class that provides the project file
  contents, or NewProjectSource returns 0 for a default project. You must write
  the class that implements IOTAFile.

  @precon  None.
  @postcon Returns an IOTAFile interface that specifies the source code for the
           project.

  @param   ProjectName as a String as a constant
  @return  an IOTAFile

**)
Function TProjectCreator.NewProjectSource(Const ProjectName: String): IOTAFile;

Begin
  Result := TProjectCreatorFile.Create(FProjectWizardInfo);
End;

{ TProjectCreatorFile }

(**

  This is a constructor for the TProjectCreatorFile class.

  @precon  None.
  @postcon Stores a copy of the project wizard information for creation of the
           project.

  @param   ProjectWizardInfo as a TProjectWizardInfo

**)
Constructor TProjectCreatorFile.Create(ProjectWizardInfo: TProjectWizardInfo);

Begin
  FProjectWizardInfo := ProjectWizardInfo;
End;

(**

  Returns the file’s age.

  GetAge returns the file’s modification date and time. If the file does not
  exist, GetAge returns –1.

  @precon  None.
  @postcon Returns -1 to signify that the file does not exist yet.

  @return  a TDateTime

**)
Function TProjectCreatorFile.GetAge: TDateTime;

Begin
  Result := -1;
End;

(**

  Returns the file’s contents.

  GetSource returns the file’s contents as a string.

  @precon  None.
  @postcon Returns the source of the project from a text file stored within the
           Open Tools API projects resources.

  @return  a string

**)
Function TProjectCreatorFile.GetSource: string;

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

Begin
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
End;

End.
