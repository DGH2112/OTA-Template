Unit InitialiseOTAInterfaces;

Interface

Uses
  ToolsAPI;

{$INCLUDE 'CompilerDefinitions.inc'}

{$R '..\SplashScreenIcon.res' '..\SplashScreenIcon.RC'}
{$R '..\RepositoryWizardResources.res' '..\RepositoryWizardResources.RC'}
{$R '..\ProjectTemplateResources.RES' '..\ProjectTemplateResources.RC'}
{$R '..\ModuleTemplateResources.RES' '..\ModuleTemplateResources.RC'}

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
  TWizardType = (wtPackageWizard, wtDLLWizard);

Const
  iWizardFailState = -1;

Var
  {$IFDEF D2005}
  VersionInfo            : TVersionInfo;
  bmSplashScreen         : HBITMAP;
  {$ENDIF}
  iWizardIndex           : Integer = iWizardFailState;
  {$IFDEF D0006}
  iAboutPluginIndex      : Integer = iWizardFailState;
  {$ENDIF}
  iKeyBindingIndex       : Integer = iWizardFailState;
  iIDENotfierIndex       : Integer = iWizardFailState;
  {$IFDEF D2010}
  iCompilerIndex         : Integer = iWizardFailState;
  {$ENDIF}
  {$IFDEF D0006}
  iEditorIndex           : Integer = iWizardFailState;
  {$ENDIF}
  iRepositoryWizardIndex : Integer = iWizardFailState;

{$IFDEF D2005}
Const
  strRevision : String = ' abcdefghijklmnopqrstuvwxyz';

ResourceString
  strSplashScreenName = '$EXPERTTITLE$ %d.%d%s for Embarcadero RAD Studio';
  strSplashScreenBuild = 'Freeware by $AUTHOR$ (Build %d.%d.%d.%d)';
{$ENDIF}

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

procedure Register;

begin
  InitialiseWizard(wtPackageWizard);
end;

Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
  RegisterProc : TWizardRegisterProc;
  var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Begin
  Result := BorlandIDEServices <> Nil;
  If Result Then
    RegisterProc(InitialiseWizard(wtDLLWizard));
End;

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
