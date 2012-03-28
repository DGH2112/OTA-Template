(**

  This module contains a class which manages the creation and life time of the
  applications menus.

  @Author  David Hoyle
  @Version 1.0
  @Date    26 Mar 2012

**)
Unit MainMenuInterface;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

Implementation

Uses
  SysUtils,
  Windows,
  Classes,
  ToolsAPI,
  ExtCtrls,
  Menus,
  ActnList,
  Contnrs,
  Dialogs,
  Graphics,
  Controls,
  UtilityFunctions,
  WizardInterface,
  RepositoryWizardInterface,
  Forms,
  ApplicationOptions;

Type
  (** A class to manage the applications menus. **)
  TApplicationMainMenu = Class
  {$IFDEF D2005} Strict {$ENDIF} Private
    FOTAMainMenu  : TMenuItem;
    {$IFNDEF D2005}
    FPatchTimer   : TTimer;
    {$ENDIF}
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure InstallMainMenu;
    Procedure AutoSaveOptionsExecute(Sender : TObject);
    Procedure AboutExecute(Sender : TObject);
    Procedure ProjCreateWizardExecute(Sender : TObject);
    Procedure ShowCompilerMessagesClick(Sender : TObject);
    Procedure ShowCompilerMessagesUpdate(Sender : TObject);
    Procedure ShowEditorMessagesClick(Sender : TObject);
    Procedure ShowEditorMessagesUpdate(Sender : TObject);
    Procedure ShowIDEMessagesClick(Sender : TObject);
    Procedure ShowIDEMessagesUpdate(Sender : TObject);
    {$IFNDEF D2005}
    Procedure PatchShortcuts(Sender : TObject);
    {$ENDIF}
  Public
    Constructor Create;
    Destructor  Destroy; Override;
  End;

{ TApplicationMainMenu }

(**

  This is an on execute event handler for the About Menu action.

  @precon  None.
  @postcon Displays a dialogue wit simple about information.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.AboutExecute(Sender: TObject);

begin
  ShowMessage('OTA Template IDE Addin'#13#10'by David Hoyle.');
end;

(**

  A constructor for the TApplicationMainMenu class.

  @precon  None.
  @postcon Creates the main menu.

  @Note    For Delphi 7 and below a timer is used to re-patch the shortcuts which are lost
           by the IDE.

**)
constructor TApplicationMainMenu.Create;
begin
  FOTAMainMenu := Nil;
  InstallMainMenu;
  {$IFNDEF D2005} // Fixes a bug in D7 and below where shortcuts are lost
  FPatchTimer := TTimer.Create(Nil);
  FPatchTimer.Interval := 1000;
  FPatchTimer.OnTimer := PatchShortcuts;
  {$ENDIF}
end;

(**

  A destructor for the TApplicationMainMenu class.

  @precon  None.
  @postcon Removes and frees the main menu from the IDE.

**)
destructor TApplicationMainMenu.Destroy;

begin
  {$IFNDEF D2005}
  FPatchTimer.Free;
  {$ENDIF}
  FOTAMainMenu.Free; // Frees all child menus
  Inherited Destroy;
end;

(**

  This method installs the individual main menu items in to the IDEs main menu.

  @precon  None.
  @postcon Installs the individual main menu items in to the IDEs main menu.

**)
procedure TApplicationMainMenu.InstallMainMenu;

Var
  NTAS : INTAServices;

begin
  NTAS := (BorlandIDEServices As INTAServices);
  If (NTAS <> Nil) And (NTAS.MainMenu <> Nil) Then
    Begin
      FOTAMainMenu := CreateMenuItem('OTATemplate', '&OTA Template', 'Tools',
        Nil, Nil, True, False, '');
      CreateMenuItem('OTAAutoSaveOptions', 'Auto Save &Option...', 'OTATemplate',
        AutoSaveOptionsExecute, Nil, False, True, 'Ctrl+Shift+O');
      CreateMenuItem('OTAProjectCreatorWizard', '&Project Creator Wizard...',
        'OTATemplate', ProjCreateWizardExecute, Nil, False, True, 'Ctrl+Shift+P');
      CreateMenuItem('OTANotifiers', 'Notifer Messages', 'OTATemplate', Nil, Nil,
        False, True, '');
      CreateMenuItem('OTAShowCompilerMsgs', 'Show &Compiler Messages',
        'OTANotifiers', ShowCompilerMessagesClick, ShowCompilerMessagesUpdate,
        False, True, '');
      CreateMenuItem('OTAShowEditorrMsgs', 'Show &Editor Messages',
        'OTANotifiers', ShowEditorMessagesClick, ShowEditorMessagesUpdate,
        False, True, '');
      CreateMenuItem('OTAShowIDEMsgs', 'Show &IDE Messages',
        'OTANotifiers', ShowIDEMessagesClick, ShowIDEMessagesUpdate,
        False, True, '');
      CreateMenuItem('OTASeparator0001', '', 'OTATemplate', Nil, Nil, False, True, '');
      CreateMenuitem('OTAAbout', '&About...', 'OTATemplate', AboutExecute, Nil,
        False, True, 'Ctrl+Shift+Q');
    End;
end;

(**

  This is an on execute event handler for the AutoSaveOptions action.

  @precon  None.
  @postcon Displays the Auto Save Optioins dialogue.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.AutoSaveOptionsExecute(Sender: TObject);
begin
  TWizardTemplate.ShowAutoSaveOptions(Sender);
end;

(**

  This is an on execute event handler for the ProjCreateWizard action.

  @precon  None.
  @postcon Invokes the display of the Project Creation Wizard.

  @param   Sender as a TObject

**)
Procedure TApplicationMainMenu.ProjCreateWizardExecute(Sender : TObject);

Begin
  TRepositoryWizardInterface.InvokeProjectCreatorWizard;
End;

(**

  This procedure adds or removes the passed option from the applications options
  set depending upon whether its already in the set of not.

  @precon  None.
  @postcon Adds or removes the passed option from the applications options
           set depending upon whether its already in the set of not.

  @param   Op as a TModuleOption

**)
Procedure UpdateModuleOps(Op : TModuleOption);

Var
  AppOps : TApplicationOptions;

Begin
  AppOps := ApplicationOps;
  If Op In AppOps.ModuleOps Then
    AppOps.ModuleOps := AppOps.ModuleOps - [Op]
  Else
    AppOps.ModuleOps := AppOps.ModuleOps + [Op];
End;

(**

  This is an on click event handler for the ShowCompilerMessages action.

  @precon  None.
  @postcon Toggles the inclusion or exclusion of this option in the applications
           settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowCompilerMessagesClick(Sender: TObject);
begin
  UpdateModuleOps(moShowCompilerMessages);
end;

(**

  This is an on update event handler for the ShowCompilerMessage action.

  @precon  None.
  @postcon Updates the checkde property of the action based on whether this
           option is in the applications settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowCompilerMessagesUpdate(Sender: TObject);
begin
  If Sender Is TAction Then
    With Sender As TAction Do
      Checked := moShowCompilerMessages In ApplicationOps.ModuleOps;
end;

(**

  This is an on click event handler for the ShowEditorMessages action.

  @precon  None.
  @postcon Toggles the inclusion or exclusion of this option in the applications
           settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowEditorMessagesClick(Sender: TObject);
begin
  UpdateModuleOps(moShowEditorMessages);
end;

(**

  This is an on update event handler for the ShowEditorMessage action.

  @precon  None.
  @postcon Updates the checkde property of the action based on whether this
           option is in the applications settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowEditorMessagesUpdate(Sender: TObject);
begin
  If Sender Is TAction Then
    With Sender As TAction Do
      Checked := moShowEditorMessages In ApplicationOps.ModuleOps;
end;

(**

  This is an on click event handler for the ShowIDEMessages action.

  @precon  None.
  @postcon Toggles the inclusion or exclusion of this option in the applications
           settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowIDEMessagesClick(Sender: TObject);
begin
  UpdateModuleOps(moShowIDEMessages);
end;

(**

  This is an on update event handler for the ShowIDEMessage action.

  @precon  None.
  @postcon Updates the checkde property of the action based on whether this
           option is in the applications settings.

  @param   Sender as a TObject

**)
procedure TApplicationMainMenu.ShowIDEMessagesUpdate(Sender: TObject);
begin
  If Sender Is TAction Then
    With Sender As TAction Do
      Checked := moShowIDEMessages In ApplicationOps.ModuleOps;
end;

{$IFNDEF D2005}
(**

  This is an on timer event handler for the timer.

  @precon  None.
  @postcon If the main IDE form is visible, patches the OTA`s menu shortcuts that get lost
           by the IDE.

  @param   Sender as a TObject

  @Note    Only applicable to Delphi 7 and below.

**)
Procedure TApplicationMainMenu.PatchShortcuts(Sender : TObject);

Begin
  If Application.MainForm.Visible Then
    Begin
      PatchActionShortcuts(Sender);
      FPatchTimer.Enabled := False;
    End;
End;
{$ENDIF}

Var
  (** A private / local variable for the application main menu class. **)
  ApplicationMainMenu : TApplicationMainMenu;

(** Creates an instance of the application main menu class to create the main menu. **)
Initialization
  ApplicationMainMenu := TApplicationMainMenu.Create;
(** Ensures that the application main menu class to freed. **)
Finalization
  ApplicationMainMenu.Free;
End.
