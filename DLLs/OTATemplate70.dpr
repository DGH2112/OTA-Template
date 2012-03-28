library OTATemplate70;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }



uses
  SysUtils,
  Classes,
  WizardInterface in '..\Source\WizardInterface.pas',
  UtilityFunctions in '..\Source\UtilityFunctions.pas',
  KeyboardBindingInterface in '..\Source\KeyboardBindingInterface.pas',
  InitialiseOTAInterfaces in '..\Source\InitialiseOTAInterfaces.pas',
  IDENotifierInterface in '..\Source\IDENotifierInterface.pas',
  CompilerNotifierInterface in '..\Source\CompilerNotifierInterface.pas',
  EditorNotifierInterface in '..\Source\EditorNotifierInterface.pas',
  OptionsForm in '..\Source\OptionsForm.pas' {frmOptions},
  SelectMethodUnit in '..\Source\SelectMethodUnit.pas',
  ItemSelectionForm in '..\Source\ItemSelectionForm.pas' {frmItemSelectionForm},
  RepositoryWizardInterface in '..\Source\RepositoryWizardInterface.pas',
  RepositoryWizardForm in '..\Source\RepositoryWizardForm.pas' {frmRepositoryWizard},
  ProjectCreatorInterface in '..\Source\ProjectCreatorInterface.pas',
  ModuleCreatorInterface in '..\Source\ModuleCreatorInterface.pas',
  MainMenuInterface in '..\Source\MainMenuInterface.pas',
  ApplicationOptions in '..\Source\ApplicationOptions.pas';

{$R *.res}

begin
end.





