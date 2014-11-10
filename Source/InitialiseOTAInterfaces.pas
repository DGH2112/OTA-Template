(**

  This module contains the code that intialises the various wizards and other
  interface element of this Open Tools API project. It is designed to work for
  both packages and DLL experts.

  @Author  David Hoyle
  @Version 1.0
  @Date    10 Nov 2014

**)
Unit InitialiseOTAInterfaces;

Interface

Uses
  ToolsAPI;

{$INCLUDE 'CompilerDefinitions.inc'}

{$R '..\SplashScreenIcon.res' '..\SplashScreenIcon.RC'}
{$R '..\RepositoryWizardResources.res' '..\RepositoryWizardResources.RC'}
{$R '..\ProjectTemplateResources.RES' '..\ProjectTemplateResources.RC'}
{$R '..\ModuleTemplateResources.RES' '..\ModuleTemplateResources.RC'}
{$R '..\MenuImagesResources.RES' '..\MenuImagesResources.RC'}

  Procedure Register;

  Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
    RegisterProc : TWizardRegisterProc;
    var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;

Implementation

Uses
  SysUtils,
  Forms,
  Windows,
  WizardInterface,
  KeyboardBindingInterface,
  IDENotifierInterface,
  CompilerNotifierInterface,
  EditorNotifierInterface,
  RepositoryWizardInterface,
  UtilityFunctions;

Type
  (** A type to distinguish between packages and DLL experts. **)
  TWizardType = (wtPackageWizard, wtDLLWizard);

Const
  (** A constant to define the failed state of a wizard / notifier interface. **)
  iWizardFailState = -1;

Var
  {$IFDEF D2005}
  (** A variable to hold the module`s version information. **)
  VersionInfo            : TVersionInfo;
  (** A varaible to hold a reference to the splash screen bitmap. **)
  bmSplashScreen         : HBITMAP;
  {$ENDIF}
  (** A varaible for referencing the main wizard interface. **)
  iWizardIndex           : Integer = iWizardFailState;
  {$IFDEF D0006}
  (** A varaible for referencing the About Plugin interface. **)
  iAboutPluginIndex      : Integer = iWizardFailState;
  {$ENDIF}
  (** A varaiable for referencing the Keybindings Interface. **)
  iKeyBindingIndex       : Integer = iWizardFailState;
  (** A varaiable for referencing the IDE Notifier interface. **)
  iIDENotfierIndex       : Integer = iWizardFailState;
  {$IFDEF D2010}
  (** A variable for referencing the Compiler Notifier interface. **)
  iCompilerIndex         : Integer = iWizardFailState;
  {$ENDIF}
  {$IFDEF D0006}
  (** A variable for referencing the Editor notifier interface. **)
  iEditorIndex           : Integer = iWizardFailState;
  {$ENDIF}
  (** A variable for referencing the Repository wizard interface. **)
  iRepositoryWizardIndex : Integer = iWizardFailState;

{$IFDEF D2005}
Const
  (** A constant string to represent bug fix letters. **)
  strRevision : String = ' abcdefghijklmnopqrstuvwxyz';

ResourceString
  (** A resource string for the splash screen name. **)
  strSplashScreenName = 'OTA Template Wizard/Expert %d.%d%s for Embarcadero RAD Studio';
  (** A resource string for the splash screen build number. **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';
{$ENDIF}

(**

  This function initialises the wizard / notifier interfaces for both packages
  and DLLs and returns the created instance of the main wizard / expert
  interface.

  @precon  None.
  @postcon Returns the main wizard template instance.

  @param   WizardType as a TWizardType
  @return  a TWizardTemplate

**)
Function InitialiseWizard(WizardType : TWizardType) : TWizardTemplate;

Var
  Svcs : IOTAServices;

Begin
  Svcs := BorlandIDEServices As IOTAServices;
  ToolsAPI.BorlandIDEServices := BorlandIDEServices;
  Application.Handle := Svcs.GetParentHandle;
  {$IFDEF D2005}
  // Aboutbox plugin
  bmSplashScreen := LoadBitmap(hInstance, 'SplashScreenBitMap');
  With VersionInfo Do
    iAboutPluginIndex := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1)]),
      '$WIZARDDESCRIPTION$.',
      bmSplashScreen,
      False,
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
      Format('SKU Build %d.%d.%d.%d', [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
  // Create Wizard / Menu Wizard
  Result := TWizardTemplate.Create;
  If WizardType = wtPackageWizard Then // Only register main wizard this way if PACKAGE
    iWizardIndex := (BorlandIDEServices As IOTAWizardServices).AddWizard(Result);
  // Create Keyboard Binding Interface
  iKeyBindingIndex := (BorlandIDEServices As IOTAKeyboardServices).AddKeyboardBinding(
    TKeybindingTemplate.Create);
  // Create IDE Notifier Interface
  iIDENotfierIndex := (BorlandIDEServices As IOTAServices).AddNotifier(
    TIDENotifierTemplate.Create);
  {$IFDEF D2010}
  // Create Compiler Notifier Interface
  iCompilerIndex := (BorlandIDEServices As IOTACompileServices).AddNotifier(
    TCompilerNotifier.Create);
  {$ENDIF}
  {$IFDEF D2005}
  // Create Editor Notifier Interface
  iEditorIndex := (BorlandIDEServices As IOTAEditorServices).AddNotifier(
    TEditorNotifier.Create);
  {$ENDIF}
  // Create Project Repository Interface
  iRepositoryWizardIndex := (BorlandIDEServices As IOTAWizardServices).AddWizard(
    TRepositoryWizardInterface.Create);
End;

(**

  This method is called by the IDE for packages in order to initialise the
  wizard / expert.

  @precon  None.
  @postcon Initialises the wizard / expert.

**)
procedure Register;

begin
  InitialiseWizard(wtPackageWizard);
end;

(**

  This method is called by the IDE for DLLs in order to initialise the wizard /
  expert.

  @precon  None.
  @postcon Initialises the wizard / expert.

  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
  RegisterProc : TWizardRegisterProc;
  var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Begin
  Result := BorlandIDEServices <> Nil;
  If Result Then
    RegisterProc(InitialiseWizard(wtDLLWizard));
End;

(** Get the modules building information from its resource and display an item
    in the D2005+ splash screen. **)
Initialization
  {$IFDEF D2005}
  BuildNumber(VersionInfo);
  // Add Splash Screen
  bmSplashScreen := LoadBitmap(hInstance, 'SplashScreenBitMap');
  With VersionInfo Do
    (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1)]),
      bmSplashScreen,
      False,
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
(** Remove all wizards the have been created. **)
Finalization
  // Remove Wizard Interface
  If iWizardIndex > iWizardFailState Then
    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iWizardIndex);
  {$IFDEF D2005}
  // Remove Aboutbox Plugin Interface
  If iAboutPluginIndex > iWizardFailState Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPluginIndex);
  {$ENDIF}
  // Remove Keyboard Binding Interface
  If iKeyBindingIndex > iWizardFailState Then
    (BorlandIDEServices As IOTAKeyboardServices).RemoveKeyboardBinding(iKeyBindingIndex);
  // Remove IDE Notifier Interface
  If iIDENotfierIndex > iWizardFailState Then
    (BorlandIDEServices As IOTAServices).RemoveNotifier(iIDENotfierIndex);
  {$IFDEF D2010}
  // Remove Compiler Notifier Interface
  If iCompilerIndex <> iWizardFailState Then
    (BorlandIDEServices As IOTACompileServices).RemoveNotifier(iCompilerIndex);
  {$ENDIF}
  {$IFDEF D2005}
  // Remove Editor Notifier Interface
  If iEditorIndex <> iWizardFailState Then
    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(iEditorIndex);
  {$ENDIF}
  // Remove Repository Wizard Interface
  If iRepositoryWizardIndex <> iWizardFailState Then
    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iRepositoryWizardIndex);
End.
