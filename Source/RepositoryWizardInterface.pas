(**

  This module contains a class which handles the IOTARepositoryWizard interfaces
  to provide a mechanism for creating OTA projects and modules.

  @Version 1.0
  @Author  David Hoyle
  @Date    10 Nov 2014

**)
Unit RepositoryWizardInterface;

Interface

Uses
  ToolsAPI,
  Windows,
  RepositoryWizardForm;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class to handle the IOTARepositoryWizard interfaces. **)
  TRepositoryWizardInterface = Class(TNotifierObject, IOTAWizard, IOTARepositoryWizard
    {$IFDEF D0006}, IOTARepositoryWizard60 {$ENDIF}
    {$IFDEF D2005}, IOTARepositoryWizard80 {$ENDIF},
    IOTAProjectWizard
    {$IFDEF D2005}, IOTAProjectWizard100 {$ENDIF})
  {$IFDEF D2005} Strict {$ENDIF} Private
    FProject : IOTAProject;
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure CreateProject(ProjectWizardInfo : TProjectWizardInfo);
  Public
    Constructor Create;
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
    // Custom Methods
    Class Procedure InvokeProjectCreatorWizard;
  End;

Implementation

Uses
  Dialogs,
  UtilityFunctions,
  SysUtils,
  ProjectCreatorInterface;

{$IFDEF D0006}
ResourceString
  (** A resource string for repository messages. **)
  strRepositoryWizardGroup = 'Repository Wizard Messages';
{$ENDIF}
{$IFDEF D2005}
ResourceString
  (** A resource string for a custom gallery item. **)
  strMyCustomCategory = 'OTA Custom Gallery Category';
{$ENDIF}

Var
  (** An internal private variable to hold the class instance. **)
  FProjWizardRef : TRepositoryWizardInterface;

{ TRepositoryWizardInterface }

(**

  Callback after the IDE saves something.

  The IDE calls back to your notifier after it saves something.

  @precon  None.
  @postcon I dont think this is called for this type of wizard.

**)
Procedure TRepositoryWizardInterface.AfterSave;

Begin
  OutputMessage('AfterSave' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

(**

  Callback before the IDE saves something.

  The IDE calls back to your notifier before it saves something so the wizard
  can intervene.

  @precon  None.
  @postcon Dont think this is called for this type of wizard.

**)
Procedure TRepositoryWizardInterface.BeforeSave;

Begin
  OutputMessage('BeforeSave' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

(**

  This method creates a project in the IDE and stores it for later use.

  @precon  None.
  @postcon Creates a project in the IDE and stores it for later use.

  @param   ProjectWizardInfo as a TProjectWizardInfo

**)
procedure TRepositoryWizardInterface.CreateProject(ProjectWizardInfo : TProjectWizardInfo);

Var
  P: TProjectCreator;

begin
  P := TProjectCreator.Create(ProjectWizardInfo);
  FProject := (BorlandIDEServices As IOTAModuleServices).CreateModule(P) As IOTAProject;
end;

(**

  This is the constructor for the TRepositoryWizardInterface class.

  @precon  None.
  @postcon Saves a reference to itself and creates a category in Delphi 2005 and
           above.

**)
Constructor TRepositoryWizardInterface.Create;

Begin
  FProjWizardRef := Self;
  {$IFDEF D2005}
  With (BorlandIDEServices As IOTAGalleryCategoryManager) Do
    Begin
      AddCategory(FindCategory(sCategoryDelphiNew), strMyCustomCategory,
        'OTA Custom Gallery Category');
    End;
  {$ENDIF}
End;

(**

  Callback before destroying something.

  The IDE calls back to your notifier when it is about destroy the object for
  which the notifier has been registered. The wizard should unregister the
  notifier and release any references to the associated object.

  For example, a module notifier receives the Destroyed callback when the user
  closes the file associated with the module interface.

  @precon  None.
  @postcon Called when the wizard is destroyed.

**)
Procedure TRepositoryWizardInterface.Destroyed;

Begin
  ClearMessages([cmCompiler..cmTool]);
  OutputMessage('Destroyed' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
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
  @postcon This method is called when the repository icon is clicked in the
           IDE allow us to create the OTA project.

**)
Procedure TRepositoryWizardInterface.Execute;

Var
  ProjectWizardInfo:  TProjectWizardInfo;

Begin
  If TfrmRepositoryWizard.Execute(ProjectWizardInfo) Then
    CreateProject(ProjectWizardInfo);
End;

(**

  Returns the author of the wizard.

  Return whatever string you want to use to identify yourself or your
  organization.

  When the user chooses the Details view in the New Items dialog box, the author
  is displayed.

  @precon  None.
  @postcon We returna string for the author`s name here.

  @return  a String

**)
Function TRepositoryWizardInterface.GetAuthor: String;

Begin
  Result := 'David Hoyle';
End;

(**

  Returns a one-sentence description of the wizard.

  Return a longer description of the wizard.

  The user can see the comment string in the Details view of the New Items
  dialog box.

  @precon  None.
  @postcon We return a comment to describe this wizard.

  @return  a String

**)
Function TRepositoryWizardInterface.GetComment: String;

Begin
  Result := 'This is an example of an OTA Repository Wizard';
End;

{$IFDEF D0006}
(**

  Returns the wizard’s designer kind.

  Implement the GetDesigner method to return the kind of designer the IDE must
  use for this form or project.

  The designer determines which components will be visible in the component
  palette.

  The choices are limited to the following predefined literals:

  Value	Meaning

    dAny  The form or project works with CLX and VCL.
    dCLX  The form or project requires the CLX designer.
    dVCL  The form or project requires the VCL designer.

  @precon  None.
  @postcon We return the VCL for this wizard.

  @return  a String

**)
Function TRepositoryWizardInterface.GetDesigner: String;

Begin
  Result := dVCL;
End;
{$ENDIF}

{$IFDEF D2005}
(**

  Get GalleryCategory is used by the property GalleryCategory in Delphi 2005 and
  above.

  GalleryCategory takes precedence over the result from GetPage.

  If a wizard doesn't implement IOTARepositoryWizard80, it is put under the
  Delphi personality's default section, and creates a sub area named by the
  result of "GetPage".

  @precon  None.
  @postcon We return our custom gallery category here.

  @return  an IOTAGalleryCategory

**)
Function TRepositoryWizardInterface.GetGalleryCategory: IOTAGalleryCategory;

Begin
  Result := (BorlandIDEServices As IOTAGalleryCategoryManager).FindCategory(strMyCustomCategory);
End;
{$ENDIF}

{$IFDEF D0006}
(**

  Returns an icon handle.

  Return the handle of an icon (HICON) to display in the Object Repository and
  the New Items dialog box.

  The icon should include a small (16x16) image and a large (32x32) image
  because the user can choose the Large Icons view or Small Icons view in the
  New Items dialog box.

  Return zero to tell the IDE to use a default icon.

  @precon  None.
  @postcon We return an icon from our projects resources.

  @return  a Cardinal

**)
Function TRepositoryWizardInterface.GetGlyph: Cardinal;
{$ELSE}
(**

  Returns an icon handle.

  Return the handle of an icon (HICON) to display in the Object Repository and
  the New Items dialog box.

  The icon should include a small (16x16) image and a large (32x32) image
  because the user can choose the Large Icons view or Small Icons view in the
  New Items dialog box.

  Return zero to tell the IDE to use a default icon.

  @precon  None.
  @postcon We return an icon from our projects resources.

  @return  a HICON

**)
Function TRepositoryWizardInterface.GetGlyph: HICON;
{$ENDIF}

Begin
  Result := LoadIcon(hInstance, 'RepositoryWizardProjectIcon')
End;

(**

  Returns a unique identification string.

  Every wizard must have a unique identification string, which the IDE obtains
  by calling GetIDString.

  The IDE does not permit two wizards to have the same ID string.

  To help ensure unique strings, the convention is to use your organization name
  and a unique wizard name, separated by a dot,
  e.g., “Borland.ActionServices.Demo”.

  @precon  None.
  @postcon We returna  unique identifier for our wizard.

  @return  a String

**)
Function TRepositoryWizardInterface.GetIDString: String;

Begin
  Result := 'OTA.Repository.Wizard.Example';
End;

(**

  Returns a user-friendly name.

  The IDE uses the value returned by GetName to present the wizard’s name in
  error messages and (for repository wizards) in the New Items dialog box and
  Object Repository.

  Choose a name that is descriptive and user-friendly.

  @precon  None.
  @postcon Return a friendly name for our project.

  @return  a String

**)
Function TRepositoryWizardInterface.GetName: String;

Begin
  Result := 'OTA Repository Wizard Example';
End;

(**

  Returns the page name for the wizard.

  GetPage returns a string that names the page of the Object Repository and New
  Items dialog box where the wizard is found.
  Return an empty string to let the IDE choose a default page (“Wizards” in
  English).

  Note that localized versions of the IDE will have localized page names, so use
  the default name, or use resource strings so your name can also be localized.

  @precon  None.
  @postcon We return a page in which our wizard will display in the IDEs new
           item gallary.

  @return  a String

**)
Function TRepositoryWizardInterface.GetPage: String;

Begin
  Result := 'OTA Examples';
End;

{$IFDEF D2005}
(**

  This method should returns the IDE personality to which the wizard belongs
  (D2005 and above)

  @precon  None.
  @postcon We return Delphi as a personality.

  @return  a String

**)
Function TRepositoryWizardInterface.GetPersonality: String;

Begin
  Result := sDelphiPersonality;
End;
{$ENDIF}

(**

  Returns the menu item state.

  All wizards must implement GetState, but the IDE calls it only for menu
  wizards.

  Return the state of the menu item. If you need finer control over the menu
  item than GetState allows, you should use a plain IOTAWizard and add an item
  to the IDE’s menu bar or a tool bar using INTAServices.

  Value	Meaning

    wsEnabled	 The menu item is enabled.
    wsChecked  The menu item displays a checkmark.

  @precon  None.
  @postcon Not used in this type of wizard.

  @return  a TWizardState

**)
Function TRepositoryWizardInterface.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

{$IFDEF D2005}
(**

  IsVisible allows the wizard to determine if it should show up in the gallery
  for a given project (if there is no project, nil is passed).

  The wizard must already be the same personality as the project.

  The only reason to add this interface is if you may want to return false.

  @precon  None.
  @postcon We return true.

  @param   Project as an IOTAProject
  @return  a Boolean

**)
Function TRepositoryWizardInterface.IsVisible(Project: IOTAProject): Boolean;

Begin
  Result := True;
End;
{$ENDIF}

(**

  Callback when something is modified.

  The IDE calls back to the notifier when the object being monitored has
  changed.

  In particular, editor notifiers are called when the user modifies the file.

  Note that Modified can be called many times (say, after every keystroke), so
  the Modified method must return quickly to avoid interfering with the user
  interface.

  @precon  None.
  @postcon Not used by this wizard.

**)
Procedure TRepositoryWizardInterface.Modified;

Begin
  OutputMessage('Modified' {$IFDEF D0006}, strRepositoryWizardGroup {$ENDIF});
End;

(**

  This is a class method of the class to allow external code to invoke the
  project creation wizard, i.e. a menu item.

  @precon  None.
  @postcon Invokes the project creation wizard.

**)
Class Procedure TRepositoryWizardInterface.InvokeProjectCreatorWizard;

Begin
  If Assigned(FProjWizardRef) Then
    FProjWizardRef.Execute;
End;

(** Makes sure the wizard reference is nil. @Note Created by the IDE on
    initialization of the main wiard**)
Initialization
  FProjWizardRef := Nil;
(** Ensure the wizard is freed from memory. **)
Finalization
  FProjWizardRef := Nil;
End.
