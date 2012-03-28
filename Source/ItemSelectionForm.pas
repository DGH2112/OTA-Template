(**

  This module contained a form for selecting from a list of items provided by a string
  list.

  @Author  David Hoyle
  @Version 1.0
  @Date    08 Mar 2012

**)
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
  (** A class to represent the form interface. **)
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

(**

  This is an on click event handler for the OK button.

  @precon  None.
  @postcon Checks that an item is selected and confirms the dialogue.

  @param   Sender as a TObject

**)
Procedure TfrmItemSelectionForm.btnOKClick(Sender: TObject);

Begin
  If lbxItems.ItemIndex = -1 Then
    Begin
      ShowMessage('Please select an item.');
      ModalResult := mrNone;
    End;
End;

(**

  This is the forms main interface method for invoking the dialogue..

  @precon  slItems must be a valid string list.
  @postcon Displays the dialogue with the items from the string list.

  @param   slItems  as a TStringList
  @param   strTitle as a String
  @return  an Integer

**)
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
