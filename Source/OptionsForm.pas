(**
  
  A class to represent a form to allow users to set the Auto Save options.

  @Author  David Hoyle
  @Version 1.0
  @Date    11 Aug 2009

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
  private
    { Private declarations }
  public
    { Public declarations }
    Class Function Execute(var iInterval : Integer; var boolPrompt : Boolean) : Boolean;
  end;

implementation

{$R *.DFM}

{ TfrmAutoSaveOptions }

(**

  This is the forms main interface method for invoking the form.

  @precon  None.
  @postcon If the form is confirmed the revised values of the Interval and 
           Prompt are return using the var parameters and the function
           returns true. If the dialogue is cancelled the function returns 
           false.

  @param   iInterval  as an Integer as a reference
  @param   boolPrompt as a Boolean as a reference
  @return  a Boolean

**)
class Function TfrmOptions.Execute(var iInterval: Integer;
  var boolPrompt: Boolean) : Boolean;

begin
  Result := False;
  With TfrmOptions.Create(Nil) Do
    Try
      udAutoSaveInterval.Position := iInterval;
      cbxPrompt.Checked := boolPrompt;
      If ShowModal = mrOK Then
        Begin
          Result := True;
          iInterval := udAutoSaveInterval.Position;
          boolPrompt := cbxPrompt.Checked;
        End;
    Finally
      Free;
    End;
end;

end.
