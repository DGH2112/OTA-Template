unit RepositoryWizardForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CheckLst, ExtCtrls;

{$INCLUDE CompilerDefinitions.inc}

type
  TProjectType = (
    //ptApplication,
    ptPackage,
    ptDLL
  );
  TAdditionalModule = (
    amCompilerDefintions,
    amInitialiseOTAInterface,
    amUtilityFunctions,
    amWizardInterface,
    amCompilerNotifierInterface,
    amEditorNotifierInterface,
    amIDENotifierInterface,
    amKeyboardBindingInterface,
    amRepositoryWizardInterface,
    amProjectCreatorInterface,
    amModuleCreatorInterface
  );
  TAdditionalModules = Set Of TAdditionalModule;

  TProjectWizardInfo = Record
    FProjectName       : String;
    FProjectType       : TProjectType;
    FAdditionalModules : TAdditionalModules;
    FWizardName        : String;
    FWizardIDString    : String;
    FWizardMenu        : Boolean;
    FWizardMenuText    : String;
    FWizardAuthor      : String;
    FWizardDescription : String;
  End;

  TfrmRepositoryWizard = class(TForm)
    Image1: TImage;
    lblProjectName: TLabel;
    edtProjectName: TEdit;
    rgpProjectType: TRadioGroup;
    lblAdditionalInterfaces: TLabel;
    lbxAdditionalModules: TCheckListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbxMenuWizard: TCheckBox;
    lblWizardName: TLabel;
    edtWizardName: TEdit;
    edtWizardIDString: TEdit;
    lblWizardIDString: TLabel;
    edtWizardMenuText: TEdit;
    lblMenuText: TLabel;
    edtWizardAuthor: TEdit;
    lblWizardAuthor: TLabel;
    lblWizardDescription: TLabel;
    memWizardDescription: TMemo;
    procedure btnOKClick(Sender: TObject);
    procedure edtProjectNameKeyPress(Sender: TObject; var Key: Char);
    procedure lbxAdditionalModulesClickCheck(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Class Function Execute(var ProjectWizardInfo : TProjectWizardInfo) : Boolean;
  end;

implementation

Uses
  UtilityFunctions,
  ToolsAPI;

{$R *.dfm}

procedure TfrmRepositoryWizard.btnOKClick(Sender: TObject);

  Procedure CheckTextField(strText, strMsg : String);

  Begin
    If strText = '' Then
      Begin
        MessageDlg(strMsg, mtError, [mbOK], 0);
        ModalResult := mrNone;
        Abort;
      End;
  End;

Var
  boolProjectNameOK: Boolean;
  PG : IOTAProjectGroup;
  i: Integer;

begin
  If Length(edtProjectName.Text) = 0 Then
    Begin
      MessageDlg('You must specify a name for the project.', mtError, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    End;
  {$IFNDEF D2009}
  If edtProjectName.Text[1] In ['0'..'9'] Then
  {$ELSE}
  If CharInSet(edtProjectName.Text[1], ['0'..'9']) Then
  {$ENDIF}
    Begin
      MessageDlg('The project name must start with a letter or underscore.', mtError, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    End;
  boolProjectNameOK := True;
  PG := ProjectGroup;
  For i := 0 To PG.ProjectCount - 1 Do
    If CompareText(ChangeFileExt(ExtractFileName(PG.Projects[i].FileName), ''),
      edtProjectName.Text) = 0 Then
      Begin
        boolProjectNameOK := False;
        Break;
      End;
  If Not boolProjectNameOK Then
    Begin
      MessageDlg(Format('There is already a project named "%s" in the project group!',
        [edtProjectName.Text]), mtError, [mbOK], 0);
      ModalResult := mrNone;
    End;
  CheckTextField(edtWizardName.Text, 'You must specify a Wizard Name.');
  CheckTextField(edtWizardIDString.Text, 'You must specify a Wizard ID String.');
  CheckTextField(edtWizardMenuText.Text, 'You must specify a Wizard Menu Text.');
end;

procedure TfrmRepositoryWizard.edtProjectNameKeyPress(Sender: TObject; var Key: Char);
begin
  {$IFNDEF D2009}
  If Not (Key In ['a'..'z', 'A'..'Z', '0'..'9', '_']) Then
  {$ELSE}
  If Not CharInSet(Key, ['a'..'z', 'A'..'Z', '0'..'9', '_']) Then
  {$ENDIF}
    Key := #0;
end;

Class Function TfrmRepositoryWizard.Execute(var ProjectWizardInfo : TProjectWizardInfo): Boolean;

Const
  ProjectTypes : Array[Low(TProjectType)..High(TProjectType)] Of String = (
    //'Application',
    'Package',
    'DLL'
  );
  AdditionalModules : Array[Low(TAdditionalModule)..High(TAdditionalModule)] Of String = (
    'Compiler Definitions (Default)',
    'Initialise OTA Interface (Default)',
    'OTA Utility Functions (Default)',
    'Wizard Interface Template',
    'Compiler Notifier Interface Template',
    'Editor Notifier Interface Template',
    'IDE Notifier Interface Template',
    'Keyboard Bindings Interface Template',
    'Repository Wizard Interface Template',
    'Project Creator Interface Template',
    'Module Creator Interface Template'
  );

Var
  i : TAdditionalModule;
  iIndex: Integer;
  j: TProjectType;

Begin
  Result := False;
  With TfrmRepositoryWizard.Create(Nil) Do
    Try
      rgpProjectType.Items.Clear;
      For j := Low(TProjectType) To High(TProjectType) Do
        rgpProjectType.Items.Add(ProjectTypes[j]);
      edtProjectName.Text := 'MyOTAProject';
      rgpProjectType.ItemIndex := 0;
      edtWizardName.Text := 'My OTA Wizard';
      edtWizardIDString.Text := 'My.OTA.Wizard';
      edtWizardMenuText.Text := 'My OTA Wizard';
      edtWizardAuthor.Text := 'Wizard Author';
      memWizardDescription.Text := 'Wizard Description';
      // Default Modules
      ProjectWizardInfo.FAdditionalModules := [amCompilerDefintions..amWizardInterface];
      For i := Low(TAdditionalModule) To High(TAdditionalModule) Do
        Begin
          iIndex := lbxAdditionalModules.Items.Add(AdditionalModules[i]);
          lbxAdditionalModules.Checked[iIndex] := i In ProjectWizardInfo.FAdditionalModules;
        End;
      If ShowModal = mrOK Then
        Begin
          ProjectWizardInfo.FProjectName := edtProjectName.Text;
          ProjectWizardInfo.FProjectType := TProjectType(rgpProjectType.ItemIndex);
          ProjectWizardInfo.FWizardName := edtWizardName.Text;
          ProjectWizardInfo.FWizardIDString := edtWizardIDString.Text;
          ProjectWizardInfo.FWizardMenu := cbxMenuWizard.Checked;
          ProjectWizardInfo.FWizardMenuText := edtWizardMenuText.Text;
          ProjectWizardInfo.FWizardAuthor := edtWizardAuthor.Text;
          ProjectWizardInfo.FWizardDescription := memWizardDescription.Text;
          For i := Low(TAdditionalModule) To High(TAdditionalModule) Do
            If lbxAdditionalModules.Checked[Integer(i)] Then
              Include(ProjectWizardInfo.FAdditionalModules, i)
            Else
              Exclude(ProjectWizardInfo.FAdditionalModules, i);
          Result := True;
        End;
    Finally
      Free;
    End;
End;

procedure TfrmRepositoryWizard.lbxAdditionalModulesClickCheck(Sender: TObject);

Var
  iModule: TAdditionalModule;

begin
  For iModule := amCompilerDefintions To amWizardInterface Do
    lbxAdditionalModules.Checked[Integer(iModule)] := True;
end;

end.
