Unit ItemSelectionForm;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons;

Type
  TfrmItemSelectionForm = Class(TForm)
    lbxItems: TListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    procedure btnOKClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
    Class Function Execute(slItems : TStringList; strTitle : String) : Integer;
  End;

Implementation

{$R *.dfm}

{ TItemSelectionForm }

Procedure TfrmItemSelectionForm.btnOKClick(Sender: TObject);

Begin
  If lbxItems.ItemIndex = -1 Then
    Begin
      ShowMessage('Please select an item.');
      ModalResult := mrNone;
    End;
End;

Class Function TfrmItemSelectionForm.Execute(slItems: TStringList; strTitle: String): Integer;

Var
  i : Integer;

Begin
  Result := -1;
  With TfrmItemSelectionForm.Create(Nil) Do
    Try
      Caption := strTitle;
      For i := 0 To slItems.Count - 1 Do
        lbxItems.Items.Add(slItems[i]);
      If ShowModal = mrOk Then
        Result := lbxItems.ItemIndex;
    Finally
      Free;
    End;
End;

End.
