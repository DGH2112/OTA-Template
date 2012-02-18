unit RepositoryWizardForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CheckLst, ExtCtrls;

{$INCLUDE CompilerDefinitions.inc}

type
  TProjectType = (ptPackage, ptDLL);
  TAdditionalModule = (
    amInitialiseOTAInterface,
    amUtilityFunctions,
    amCompilerNotifierInterface,
    amEditorNotifierInterface,
    amIDENotfierInterface,
    amKeybaordBindingsInterface,
    amReportioryWizardInterface,
    amProjectCreatorInterface
  );
  TAdditionalModules = Set Of TAdditionalModule;

  TfrmRepositoryWizard = class(TForm)
    Image1: TImage;
    lblProjectName: TLabel;
    edtProjectName: TEdit;
    rgpProjectType: TRadioGroup;
    lblAdditionalInterfaces: TLabel;
    lbxAdditionalModules: TCheckListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    procedure btnOKClick(Sender: TObject);
    procedure edtProjectNameKeyPress(Sender: TObject; var Key: Char);
    procedure lbxAdditionalModulesClickCheck(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Class Function Execute(var strProjectName : String; var enumProjectType : TProjectType;
      var enumAdditionalModules : TAdditionalModules) : Boolean;
  end;

implementation

Uses
  UtilityFunctions,
  ToolsAPI;

{$R *.dfm}

procedure TfrmRepositoryWizard.btnOKClick(Sender: TObject);

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

Class Function TfrmRepositoryWizard.Execute(var strProjectName : String;
  var enumProjectType : TProjectType;
  var enumAdditionalModules : TAdditionalModules): Boolean;

Const
  AdditionalModules : Array[Low(TAdditionalModule)..High(TAdditionalModule)] Of String = (
    'Initialise OTA Interface (Default)',
    'OTA Utility Functions (Default)',
    'Compiler Notifier Interface Template',
    'Editor Notifier Interface Template',
    'IDE Notifier Interface Template',
    'Keyboard Bindings Interface Template',
    'Repository Wizard Interface Template',
    'Project Creator Interface Template'
  );

Var
  i : TAdditionalModule;
  iIndex: Integer;

Begin
  Result := False;
  With TfrmRepositoryWizard.Create(Nil) Do
    Try
      edtProjectName.Text := 'MyOTAProject';
      rgpProjectType.ItemIndex := 0;
      // Default Modules
      enumAdditionalModules := [amInitialiseOTAInterface..amUtilityFunctions];
      For i := Low(TAdditionalModule) To High(TAdditionalModule) Do
        Begin
          iIndex := lbxAdditionalModules.Items.Add(AdditionalModules[i]);
          lbxAdditionalModules.Checked[iIndex] := i In enumAdditionalModules;
        End;
      If ShowModal = mrOK Then
        Begin
          strProjectName := edtProjectName.Text;
          Case rgpProjectType.ItemIndex Of
            0: enumProjectType := ptPackage;
            1: enumProjectType := ptDLL;
          End;
          For i := Low(TAdditionalModule) To High(TAdditionalModule) Do
            If lbxAdditionalModules.Checked[Integer(i)] Then
              Include(enumAdditionalModules, i)
            Else
              Exclude(enumAdditionalModules, i);
          Result := True;
        End;
    Finally
      Free;
    End;
End;

procedure TfrmRepositoryWizard.lbxAdditionalModulesClickCheck(Sender: TObject);
begin
  // Always ensure the default modules are Checked!
  lbxAdditionalModules.Checked[0] := True;
  lbxAdditionalModules.Checked[1] := True;
end;

end.
