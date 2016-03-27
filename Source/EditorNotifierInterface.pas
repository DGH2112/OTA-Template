(**

  This module defines a class the implements the INTAEditServicesNotifier
  interface to allow the handling of editor events.

  @Author  David Hoyle
  @Version 1.0
  @Date    27 Mar 2016

**)
Unit EditorNotifierInterface;

Interface

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

Uses
  ToolsAPI,
  {$IFDEF D0006}
  DockForm,
  {$ENDIF}
  Classes;

{$IFDEF D2005}
Type
  (** A class to handle the INTAEditServicesNotifier interface. **)
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
  UtilityFunctions,
  ApplicationOptions;

{$IFDEF D2005}
{ TEditorNotifier }

Const
  (** A resource string to define the message group under which all output from
      this module will be sent. **)
  strEditorNotifierMessages = 'Editor Notifier Messages';
  (** A constant array to define string representations of the boolean values. **)
  strBoolean : Array[False..True] of String = ('False', 'True');


(**

  This method seems to be fired when the IDE is closing down and the desktop of
  being save. I’ve not been able to get the event to fire for any other
  situations.

  @precon  The EditWindow is the edit window that the docking operation is be
           docked to (its a dock site) and DockForm is the form that is being
           docked.
  @postcon Place handling in the event to perform as the desktop is being saved.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TEditorNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('DockFormRefresh: EditWindow = %s, DockForm = %s', [
      EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

(**

  This event seems to be fired when a dockable form is docked with an Edit
  Window dock site.

  @precon  The EditWindow is the edit window that the docking operation is be
           docked to (its a dock site) and DockForm is the form that is being
           docked.
  @postcon Place handling code in this event to be triggered when forms are
           docked with the edit windows.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TEditorNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('DockFormUpdated: EditWindow = %s, DockForm = %s', [
      EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

(**

  This method seems to be fired when desktops are loaded and not as I thought
  when dockable forms change their visibility.

  @precon  The EditWindow is the edit window that the docking operation is be
           docked to (its a dock site) and DockForm is the form that is being
           docked.
  @postcon Place handling code here to be invoked when desktop forms are loaded
           .

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TEditorNotifier.DockFormVisibleChanged(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('DockFormVisibleChanged: EditWindow = %s, DockForm = %s', [
      EditWindow.Form.Caption, DockForm.Caption]), strEditorNotifierMessages);
End;

(**

  This method is fired each time a tab is changed in the editor whether that’s
  through opening and closing files or simply changing tabs to view a different
  file. The EditWindow parameter provides access to the editor window. This is
  usually the first docked editor window unless you’ve opened a new editor
  window to have a second one visible. The EditView parameter provides you with
  access to the view of the file where you can get information about the cursor
  positions, the selected block, etc. By drilling down through the Buffer
  property you can get the text associated with the file.

  @precon  The EditWindow is the edit window that hosts the view that is
           activated and EditView is the view being activiated.
  @postcon Place handling code here to be invoked when desktop forms are loaded
           .

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
Procedure TEditorNotifier.EditorViewActivated(Const EditWindow: INTAEditWindow;
  Const EditView: IOTAEditView);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('EditorViewActivated: EditWindow = %s, EditView = %s', [
      EditWindow.Form.Caption, ExtractFileName(EditView.Buffer.FileName)]),
      strEditorNotifierMessages);
End;

(**

  This method is fired each time the text of the file is changed whether that is
  an insertion or a deletion of text. The values returned by the parameters as
  the same as those for the above EditorViewActivated method.

  @precon  The EditWindow is the edit window that is being modified and EditView
           is the view in which the edit is taking place.
  @postcon Place handling code here to be invoked when desktop forms are loaded
           .

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
Procedure TEditorNotifier.EditorViewModified(Const EditWindow: INTAEditWindow;
  Const EditView: IOTAEditView);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('EditorViewModified: EditWindow = %s, EditView = %s', [
      EditWindow.Form.Caption, ExtractFileName(EditView.Buffer.FileName)]),
      strEditorNotifierMessages);
End;

(**

  Well I’ve been unable to get this to fire in both a docked layout and a
  classic undocked layout, so if someone else knows what fires this, please let
  me know.

  @precon  The EditWindow is the edit window that is being activated.
  @postcon Unknown.

  @param   EditWindow as an INTAEditWindow as a constant

**)
Procedure TEditorNotifier.WindowActivated(Const EditWindow: INTAEditWindow);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('WindowActivated: EditWindow = %s', [
      EditWindow.Form.Caption]), strEditorNotifierMessages);
End;

(**

  This method is fired for some keyboard commands but there doesn’t seem to be
  any logic to when it is fired or for what. The Command parameter is the
  command number and in all my tests the Param parameter was 0. I’ve check
  against keyboard binding and have found that this event is not fired for OTA
  keyboard binding.

  @precon  EditWindow is the edit window in which the command occurs, Command is
           a number corresponding to the command, Param is a number
           corresponding to the command and Handled should be changed to true if
           you`ve handled the command.
  @postcon Please code here to handle commands in the Edit Windows.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Command    as an Integer
  @param   Param      as an Integer
  @param   Handled    as a Boolean as a reference

**)
Procedure TEditorNotifier.WindowCommand(Const EditWindow: INTAEditWindow; Command,
  Param: Integer; Var Handled: Boolean);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('WindowCommand: EditWindow = %s, Command = %d, Param = %d', [
      EditWindow.Form.Caption, Command, Param, strBoolean[Handled]]), strEditorNotifierMessages);
End;

(**

  This event is fired for each editor window that is opened or closed. The
  EditWindow parameter is a reference to the specific editor window opening or
  closing and the Operation parameter depicts whether the editor is opening
  (insert) or closing (remove).

  @precon  EditWindow is the edit windfow where the notification has been raised
           and Operation is the type of operation for which the notification
           represents.
  @postcon Place code here to handle insertion and removl of windows.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Operation  as a TOperation

**)
Procedure TEditorNotifier.WindowNotification(Const EditWindow: INTAEditWindow;
  Operation: TOperation);

Const
  strOperation : Array[Low(TOperation)..High(TOperation)] Of String = ('opInsert', 'opRemove');

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('WindowNotification: EditWindow = %s, Operation = %s', [
      EditWindow.Form.Caption, strOperation[Operation]]), strEditorNotifierMessages);
End;

(**

  This event is fired each time an editor window appears or disappear. The
  EditWindow parameter references the editor changing appearance with the Show
  parameter defining whether it is appearing (show = true) or disppearing
  (show = false). The LoadFromDesktop parameter defines whether the operation is
  being caused by a desktop layout being loaded or not.

  @precon  EditWindow is the edit window in which the window is shown, Show is
           true if the window is showna nd LoadedFromDesktop is true if this
           event is fired as a result of loading the desktop.
  @postcon Place code here to handle the showing of edit windows.

  @param   EditWindow        as an INTAEditWindow as a constant
  @param   Show              as a Boolean
  @param   LoadedFromDesktop as a Boolean

**)
Procedure TEditorNotifier.WindowShow(Const EditWindow: INTAEditWindow; Show,
  LoadedFromDesktop: Boolean);

Begin
  If moShowEditorMessages In ApplicationOps.ModuleOps Then
    OutputMessage(Format('WindowShow: EditWindow = %s, Show = %s, LoadedFromDesktop = %s', [
      EditWindow.Form.Caption, strBoolean[Show], strBoolean[LoadedFromDesktop]]),
      strEditorNotifierMessages);
End;
{$ENDIF}

End.
