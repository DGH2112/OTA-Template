(**

  This module contains a class that handles the loading and savingof application
  settings to an INI file.

  @Author  David Hoyle
  @Date    24 Mar 2012
  @Version 1.0

**)
Unit ApplicationOptions;

Interface

Type
  (** An enumerate the displays of messages from the notifiers. **)
  TModuleOption = (moShowCompilerMessages, moShowEditorMessages,
    moShowIDEMessages);
  (** A set of the above enumerates. **)
  TModuleOptions = Set of TModuleOption;

  (** A class to handle the loading and saving of application settings. **)
  TApplicationOptions = Class
  {$IFDEF D2005} Strict {$ENDIF} Private
    FAutoSaveInt : Integer;
    FPrompt      : Boolean;
    FINIFileName : String;
    FModuleOps   : TModuleOptions;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure LoadSettings;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure SaveSettings;
    (**
      This property gets and sets the Auto Save interval in seconds.
      @precon  None.
      @postcon Returns the auto save interval.
      @return  an Integer
    **)
    Property AutoSaveInt : Integer Read FAutoSaveInt Write FAutoSaveInt;
    (**
      This property determines whether the auto saving of editor files should be
      prompted for.
      @precon  None.
      @postcon Returns whether saving of files should be prompted for.
      @return  a Boolean
    **)
    Property AutoSavePrompt : Boolean Read FPrompt Write FPrompt;
    (**
      This property determines which notifier output messages in the IDE.
      @precon  None.
      @postcon Returns the module options for displaying notifier messages.
      @return  a TModuleOptions
    **)
    Property ModuleOps : TModuleOptions Read FModuleOps Write FModuleOps;
  End;

  Function ApplicationOps : TApplicationOptions;

Implementation

Uses
  SysUtils,
  Windows,
  IniFiles;

Type
  (** A variant record to allow the easy translation from TModuleOptions set to
        an integer. **)
  TModuleOpsRec = Record
    Case Boolean Of
      True:  (iOps : Integer);
      False: (ModuleOps : TModuleOptions);
  End;

Var
  (** A private variable to hold the single instance of the application options
      class for the life time of the expert. **)
  FAppOps : TApplicationOptions;

(**

  This function returns an instance of the application options class. If the
  class has not been created it is created and stored in the private variable
  above.

  @precon  None.
  @postcon Returns an instance of the application options class. If the
           class has not been created it is created and stored in the private
           variable above.

  @return  a TApplicationOptions

**)
Function ApplicationOps : TApplicationOptions;

Begin
  If FAppOps = Nil Then
    FAppOps := TApplicationOptions.Create;
  Result := FAppOps;
End;

{ TApplicationOptions }

(**

  This is the constructor for the TApplicationOptions class.

  @precon  None.
  @postcon Initialises the applications options and loads them from the INI
           file.

**)
Constructor TApplicationOptions.Create;

Var
  iSize : DWORD;

Begin
  FAutoSaveInt := 300; // Default 300 seconds (5 minutes)
  FPrompt := True;     // Default to True
  // Create INI file same as add module + '.INI'
  SetLength(FINIFileName, MAX_PATH);
  iSize := MAX_PATH;
  iSize := GetModuleFileName(hInstance, PChar(FINIFileName), iSize);
  SetLength(FINIFileName, iSize);
  FINIFileName := ChangeFileExt(FINIFileName, '.INI');
  LoadSettings;
  LoadSettings;
End;

(**

  This method is a destructor for the TApplicationOptions class.

  @precon  None.
  @postcon Saves the options to an INI file.

**)
Destructor TApplicationOptions.Destroy;

Begin
  SaveSettings;
  Inherited Destroy;
End;

(**

  This method loads the applications settings from the INI file.

  @precon  None.
  @postcon Loads the applications settings from the INI file.

**)
Procedure TApplicationOptions.LoadSettings;

Var
  Ops: TModuleOpsRec;

Begin
  With TIniFile.Create(FINIFileName) Do
    Try
      FAutoSaveInt := ReadInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      FPrompt := ReadBool('Setup', 'Prompt', FPrompt);
      Ops.iOps := 0;
      Ops.ModuleOps := [moShowCompilerMessages..moShowIDEMessages];
      Ops.iOps := ReadInteger('Setup', 'ModuleOptions', Ops.iOps);
      FModuleOps := Ops.ModuleOps;
    Finally
      Free;
    End;
End;

(**

  This method saves the applications settings to the INI file.

  @precon  None.
  @postcon Saves the applications settings to the INI file.

**)
Procedure TApplicationOptions.SaveSettings;

Var
  Ops: TModuleOpsRec;

Begin
  With TIniFile.Create(FINIFileName) Do
    Try
      WriteInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      WriteBool('Setup', 'Prompt', FPrompt);
      Ops.ModuleOps := FModuleOps;
      WriteInteger('Setup', 'ModuleOptions', Ops.iOps);
    Finally
      Free;
    End;
End;

(** Make sure the private variable is nil on startup. **)
Initialization
  FAppOps := Nil;
(** Free the applications options class from memory. **)
Finalization;
  FAppOps.Free;
End.
