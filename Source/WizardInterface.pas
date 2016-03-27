(**

  This moduloe contains the main OTA wizard for this addin.

  @Author  David Hoyle
  @Version 1.0
  @Date    27 Mar 2016

**)
Unit WizardInterface;

Interface

Uses
  ToolsAPI,
  Menus,
  ExtCtrls;

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

Type
  (** This class implements the IOTAWizard and IOTAMenuWizard interfaces for the
      main expert / wizard interface. **)
  TWizardTemplate = Class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  {$IFDEF D2005} Strict {$ENDIF} Private
    FTimer       : TTimer;
    FCounter     : Integer;
    FMenuItem    : TMenuItem;
    FSucceeded   : Boolean;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure TimerEvent(Sender : TObject);
    Procedure SaveModifiedFiles;
    Procedure InstallMenu;
    Procedure MenuClick(Sender : TObject);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    // IOTAWizard
    Function GetIDString: String;
    Function GetName: String;
    Function GetState: TWizardState;
    Procedure Execute;
    // IOTAMenuWizard
    Function GetMenuText: String;
    // Custom Methods
    Class Procedure ShowAutoSaveOptions(Sender : TObject);
  End;

Implementation

Uses
  Dialogs,
  Windows,
  SysUtils,
  IniFiles,
  OptionsForm,
  ApplicationOptions;

{ TWizardTemplate }

Var
  (** A private variable to hold the main wizard interface for the life time
      if the IDE. **)
  FWizardRef : TWizardTemplate;

(**

  This is the constructor for the TWizardTemplate class.

  @precon  None.
  @postcon Initialises the wizard and sets up the timer for the auto save
           functionality.

**)
Constructor TWizardTemplate.Create;

Begin
  FWizardRef := Self;
  FMenuItem := Nil;
  FCounter := 0;
  FSucceeded := False;
  FTimer := TTimer.Create(Nil);
  FTimer.Interval := 1000; // 1 second
  FTimer.OnTimer := TimerEvent;
  FTimer.Enabled := True;
End;

(**

  This method is a destructor for the TWizardTemplate class.

  @precon  None.
  @postcon Frees the memory used by the wizard.

**)
Destructor TWizardTemplate.Destroy;

Begin
  FMenuItem.Free;
  FTimer.Free;
  Inherited Destroy;
End;

(**

  Invokes a menu or repository wizard.

  Every wizard must implement the Execute method, but Execute is never called
  for plain IOTAWizard wizards. It is called only for menu wizards (when the
  user chooses the menu item) or repository wizards (when the user invokes the
  item from the New Items dialog box).

  Menu, Form, and Project wizards implement the Execute method to perform the
  work of the wizard. You are free to implement this method any way you want.
  Convention dictates that a form wizard would create a new unit or form, and a
  project wizard would create a new project.

  @precon  None.
  @postcon This is invoked by the Menu Wizard interface to either display a
           message in low version of Delphi or toggle code folding in higher
           versions.

**)
Procedure TWizardTemplate.Execute;

{$IFDEF D2010}
Var
  TopView: IOTAEditView;
  I : IOTAElideActions;
{$ENDIF}
Begin
  {$IFNDEF D2010}
  ShowMessage('Hello World!');
  {$ELSE}
  TopView := (BorlandIDEServices As IOTAEditorServices).TopView;
  If TopView.QueryInterface(IOTAElideActions, I) = S_OK Then
    Begin
      I.ToggleElisions;
      TopView.Paint;
    End;
  {$ENDIF}
End;

(**

  Returns a unique identification string.

  Every wizard must have a unique identification string, which the IDE obtains
  by calling GetIDString. The IDE does not permit two wizards to have the same
  ID string. To help ensure unique strings, the convention is to use your
  organization name and a unique wizard name, separated by a dot,
  e.g., “Borland.ActionServices.Demo”.

  @precon  None.
  @postcon We return a unique identifier for our wizard.

  @return  a String

**)
Function TWizardTemplate.GetIDString: String;

Begin
  Result := 'OTA.Wizard.Template';
End;

(**

  Returns the menu item caption

  Implement GetMenuText to return the caption of the menu item to add to the
  Help menu. You can specify an accelerator key by preceding the character with
  an ampersand, but that might interfere with other wizards or other menu items
  in a localized menu. If you omit the accelerator key, the IDE automatically
  assigns one.

  When the user picks the menu item, the IDE calls the wizard’s Execute method.
  The state of the menu item is determined by the wizard’s GetState method.

  @precon  None.
  @postcon This is the text that is displayed by the Menu Wziard under the Help
           menu.

  @return  a String

**)
Function TWizardTemplate.GetMenuText: String;

Begin
  Result := 'Toggle Folded Code';
End;

(**

  Returns a user-friendly name.

  The IDE uses the value returned by GetName to present the wizard’s name in
  error messages and (for repository wizards) in the New Items dialog box and
  Object Repository. Choose a name that is descriptive and user-friendly.

  @precon  None.
  @postcon Here we return a friendly name for our wizard.

  @return  a String

**)
Function TWizardTemplate.GetName: String;

Begin
  Result := 'OTA Template';
End;

(**

  Returns the menu item state.

  All wizards must implement GetState, but the IDE calls it only for menu
  wizards. Return the state of the menu item. If you need finer control over the
  menu item than GetState allows, you should use a plain IOTAWizard and add an
  item to the IDE’s menu bar or a tool bar using INTAServices.

  Value	Meaning

    wsEnabled	 The menu item is enabled.
    wsChecked	 The menu item displays a checkmark.

  @precon  None.
  @postcon Used to set the state of the menu.

  @return  a TWizardState

**)
Function TWizardTemplate.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

(**

  This metho creates the auto save menu which is placed under the View menu.
  This is an old way of creating a menu. Please refer to the MainMenuInterface
  module for a better more consist way of creating menus in the main IDE menu
  system.

  @precon  None.
  @postcon Creates an auto save menu under the view main menu.

**)
Procedure TWizardTemplate.InstallMenu;

Var
  NTAS: INTAServices;
  mmiViewMenu: TMenuItem;
  mmiWindowList: TMenuItem;

Begin
  NTAS := (BorlandIDEServices As INTAServices);
  If (NTAS <> Nil) And (NTAS.MainMenu <> Nil) Then
    Begin
      mmiViewMenu := NTAS.MainMenu.Items.Find('View');
      If mmiViewMenu <> Nil Then
        Begin
          mmiWindowList := mmiViewMenu.Find('Window List...');
          If mmiWindowList <> Nil Then
            Begin
              FMenuItem := TMenuItem.Create(mmiViewMenu);
              FMenuItem.Caption := '&Auto Save Options...';
              FMenuItem.OnClick := MenuClick;
              FMenuItem.ShortCut := TextToShortCut('Ctrl+Shift+Alt+A');
              mmiViewMenu.Insert(mmiWindowList.MenuIndex + 1, FMenuItem);
              FSucceeded := True;
            End;
        End;
    End;
End;

(**

  This is an on click event handler for the auto save menu.

  @precon  None.
  @postcon Displays the auto save dialogue and if confirmed saves the settings
           to an INI file.

  @param   Sender as a TObject

**)
Procedure TWizardTemplate.MenuClick(Sender: TObject);

Var
  ASO : TApplicationOptions;
  iInt : Integer;
  bPrompt: Boolean;

Begin
  ASO := ApplicationOps;
  iInt := ASO.AutoSaveInt;
  bPrompt := ASO.AutoSavePrompt;
  If TfrmOptions.Execute(iInt, bPrompt) Then
    Begin
      ASO.AutoSaveInt := iInt;
      ASO.AutoSavePrompt := bPrompt;
      ASO.SaveSettings;
    End;
End;

(**

  This method iterates the open files in the IDE and saves them IF they have
  been modified.

  @precon  None.
  @postcon Iterates the open files in the IDE and saves them IF they have
           been modified.

**)
Procedure TWizardTemplate.SaveModifiedFiles;

Var
  Iterator: IOTAEditBufferIterator;
  i: Integer;
  boolPrompt : Boolean;

Begin
  boolPrompt := ApplicationOps.AutoSavePrompt;
  If (BorlandIDEServices As IOTAEditorServices).GetEditBufferIterator(Iterator) Then
    Begin
      For i := 0 To Iterator.Count - 1 Do
        If Iterator.EditBuffers[i].IsModified Then
          Iterator.EditBuffers[i].Module.Save(False, Not boolPrompt);
    End;
End;

(**

  This is an on timer event handler for th auto save timer.

  @precon  None.
  @postcon If the allotted time as passed the IDE files are saved if they have
           been modified.

  @param   Sender as a TObject

**)
Procedure TWizardTemplate.TimerEvent(Sender: TObject);

Begin
  FTimer.Enabled := False;
  Try
    Inc(FCounter);
    If FCounter >= ApplicationOps.AutoSaveInt Then
      Begin
        FCounter := 0;
        SaveModifiedFiles;
      End;
    If Not FSucceeded Then
      InstallMenu;
  Finally
    FTimer.Enabled := True;
  End;
End;

(**

  This is a class method for the wizard class to allow external modules to
  invokes the auto save dialogue.

  @precon  None.
  @postcon Displays the auto save dialogue.

  @param   Sender as a TObject

**)
Class Procedure TWizardTemplate.ShowAutoSaveOptions(Sender : TObject);

Begin
  If Assigned(FWizardRef) Then
    FWizardRef.MenuClick(Sender);
End;

(** Ensures that the wizard reference is NIL @note gets created by the main
    interface initialization of the project. **)
Initialization
  FWizardRef := Nil;
(** Ensure the wizard reference is freed. **)
Finalization
  FWizardRef := Nil;
End.
