Unit EditorNotifierInterface;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  ToolsAPI,
  {$IFDEF D0006}
  DockForm,
  {$ENDIF}
  Classes;

{$IFDEF D2005}
Type
  TEditorNotifier = Class(TNotifierObject, INTAEditServicesNotifier)
  Strict Private
  Strict Protected
  Public
    Procedure WindowShow(Const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
    Procedure WindowNotification(Const EditWindow: INTAEditWindow; Operation: TOperation);
    Procedure WindowActivated(Const EditWindow: INTAEditWindow);
    Procedure WindowCommand(Const EditWindow: INTAEditWindow; Command, Param: Integer; Var Handled: Boolean);
    Procedure EditorViewActivated(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
    Procedure EditorViewModified(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
    Procedure DockFormVisibleChanged(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    Procedure DockFormUpdated(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    Procedure DockFormRefresh(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
  End;
{$ENDIF}

Implementation

Uses
  SysUtils,
  UtilityFunctions;

{$IFDEF D2005}
{ TEditorNotifier }

Const
  strEditorNotifierMessages = 'Editor Notifier Messages';
  strBoolean : Array[False..True] of String = ('False', 'True');


Procedure TEditorNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  OutputMessage(Format('DockFormRefresh: EditWindow = %s, DockForm = %s', [
    EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  OutputMessage(Format('DockFormUpdated: EditWindow = %s, DockForm = %s', [
    EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.DockFormVisibleChanged(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  OutputMessage(Format('DockFormVisibleChanged: EditWindow = %s, DockForm = %s', [
    EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.EditorViewActivated(Const EditWindow: INTAEditWindow;
  Const EditView: IOTAEditView);

Begin
  OutputMessage(Format('EditorViewActivated: EditWindow = %s, EditView = %s', [
    EditWindow.Form.Caption, ExtractFileName(EditView.Buffer.FileName)]),
    strEditorNotifierMessages);
End;

Procedure TEditorNotifier.EditorViewModified(Const EditWindow: INTAEditWindow;
  Const EditView: IOTAEditView);

Begin
  OutputMessage(Format('EditorViewModified: EditWindow = %s, EditView = %s', [
    EditWindow.Form.Caption, ExtractFileName(EditView.Buffer.FileName)]),
    strEditorNotifierMessages);
End;

Procedure TEditorNotifier.WindowActivated(Const EditWindow: INTAEditWindow);

Begin
  OutputMessage(Format('WindowActivated: EditWindow = %s', [
    EditWindow.Form.Caption]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.WindowCommand(Const EditWindow: INTAEditWindow; Command,
  Param: Integer; Var Handled: Boolean);

Begin
  OutputMessage(Format('WindowCommand: EditWindow = %s, Command = %d, Param = %d', [
    EditWindow.Form.Caption, Command, Param, strBoolean[Handled]]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.WindowNotification(Const EditWindow: INTAEditWindow;
  Operation: TOperation);

Const
  strOperation : Array[Low(TOperation)..High(TOperation)] Of String = ('opInsert', 'opRemove');

Begin
  OutputMessage(Format('WindowNotification: EditWindow = %s, Operation = %s', [
    EditWindow.Form.Caption, strOperation[Operation]]), strEditorNotifierMessages);
End;

Procedure TEditorNotifier.WindowShow(Const EditWindow: INTAEditWindow; Show,
  LoadedFromDesktop: Boolean);

Begin
  OutputMessage(Format('WindowShow: EditWindow = %s, Show = %s, LoadedFromDesktop = %s', [
    EditWindow.Form.Caption, strBoolean[Show], strBoolean[LoadedFromDesktop]]),
    strEditorNotifierMessages);
End;
{$ENDIF}

End.
