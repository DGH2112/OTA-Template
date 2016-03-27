(**

  A class to represent a form to allow users to set the Auto Save options.

  @Author  David Hoyle
  @Version 1.0
  @Date    27 Mar 2016

**)
unit OptionsForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls;

type
  (** Class to represent the form interface. **)
  TfrmOptions = class(TForm)
    lblAutoSaveInterval: TLabel;
    edtAutosaveInterval: TEdit;
    udAutoSaveInterval: TUpDown;
    cbxPrompt: TCheckBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    chkEnabled: TCheckBox;
    gbxAutosaveOptions: TGroupBox;
    procedure chkEnabledClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Class Function Execute(var iInterval : Integer; var boolPrompt,
      boolEnabled : Boolean) : Boolean;
  end;

implementation

{$R *.DFM}

{ TfrmAutoSaveOptions }

(**

  This is an on click event handler for the Enabled Checkbox control.

  @precon  None.
  @postcon Enables of disables the AutoSave interface controls through enabling /
           disabling the controls.

  @param   Sender as a TObject

**)
Procedure TfrmOptions.chkEnabledClick(Sender: TObject);

Begin
  lblAutoSaveInterval.Enabled := chkEnabled.Checked;
  edtAutosaveInterval.Enabled := chkEnabled.Checked;
  cbxPrompt.Enabled := chkEnabled.Checked;
End;

(**

  This is the forms main interface method for invoking the form.

  @precon  None.
  @postcon If the form is confirmed the revised values of the Interval and Prompt are
           return using the var parameters and the function returns true. If the
           dialogue is cancelled the function returns false.

  @param   iInterval   as an Integer as a reference
  @param   boolPrompt  as a Boolean as a reference
  @param   boolEnabled as a Boolean as a reference
  @return  a Boolean

**)
class Function TfrmOptions.Execute(var iInterval: Integer;
  var boolPrompt, boolEnabled : Boolean) : Boolean;

begin
  Result := False;
  With TfrmOptions.Create(Nil) Do
    Try
      udAutoSaveInterval.Position := iInterval;
      cbxPrompt.Checked := boolPrompt;
      chkEnabled.Checked := boolEnabled;
      chkEnabledClick(Nil);
      If ShowModal = mrOK Then
        Begin
          Result := True;
          iInterval := udAutoSaveInterval.Position;
          boolPrompt := cbxPrompt.Checked;
          boolEnabled := chkEnabled.Checked;
        End;
    Finally
      Free;
    End;
end;

end.
