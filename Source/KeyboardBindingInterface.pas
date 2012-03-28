(**

  This module contains a class which implements the IOTAKeyboardBinding interface so that
  it can be registered with the IDE and handle keyboard events.

  @Author  David Hoyle
  @Version 1.0
  @Date    08 Mar 2012

**)
Unit KeyboardBindingInterface;

Interface

Uses
  ToolsAPI,
  Classes;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class that implements the IOTAKeyboardBinding interface for handing keyboard
      events. **)
  TKeybindingTemplate = Class(TNotifierObject, IOTAKeyboardBinding)
  {$IFDEF D2005} Strict {$ENDIF} Private
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure AddBreakPoint(Const Context: IOTAKeyContext;
      KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
    Procedure SelectMethodExecute(Const Context: IOTAKeyContext;
      KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
  Public
    Procedure BindKeyboard(Const BindingServices: IOTAKeyBindingServices);
    Function GetBindingType: TBindingType;
    Function GetDisplayName: String;
    Function GetName: String;
  End;

Implementation

Uses
  SysUtils,
  Dialogs,
  Menus,
  UtilityFunctions,
  SelectMethodUnit;

{ TKeybindingTemplate }

(**

  This method is called by the IDE to bind keys to event handlers.

  @precon  None.
  @postcon Binds keys to event handlers.

  @param   BindingServices as an IOTAKeyBindingServices as a constant

**)
Procedure TKeybindingTemplate.BindKeyboard(Const BindingServices: IOTAKeyBindingServices);

Begin
  BindingServices.AddKeyBinding([TextToShortcut('Ctrl+Shift+F8')], AddBreakPoint, Nil);
  BindingServices.AddKeyBinding([TextToShortcut('Ctrl+Alt+F8')], AddBreakPoint, Nil);
  BindingServices.AddKeyBinding([TextToShortcut('Ctrl+Shift+Alt+F9')], SelectMethodExecute, Nil);
End;

(**

  This method adds a breakpoint to the IDE at the source code location and invokes the
  breakpoint editing dialogue.

  @precon  None.
  @postcon Adds a breakpoint to the IDE at the source code location and invokes the
           breakpoint editing dialogue.

  @param   Context       as an IOTAKeyContext as a constant
  @param   KeyCode       as a TShortcut
  @param   BindingResult as a TKeyBindingResult as a reference

**)
Procedure TKeybindingTemplate.AddBreakPoint(Const Context: IOTAKeyContext;
  KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);

Var
  i: Integer;
  DS: IOTADebuggerServices;
  MS: IOTAModuleServices;
  strFileName: String;
  Source: IOTASourceEditor;
  CP: TOTAEditPos;
  BP: IOTABreakpoint;

Begin
  MS := BorlandIDEServices As IOTAModuleServices;
  Source := SourceEditor(MS.CurrentModule);
  strFileName := Source.FileName;
  CP := Source.EditViews[0].CursorPos;
  DS := BorlandIDEServices As IOTADebuggerServices;
  BP := Nil;
  For i := 0 To DS.SourceBkptCount - 1 Do
    If (DS.SourceBkpts[i].LineNumber = CP.Line) And
      (AnsiCompareFileName(DS.SourceBkpts[i].FileName, strFileName) = 0) Then
      BP := DS.SourceBkpts[i]; ;
  If BP = Nil Then
    BP := DS.NewSourceBreakpoint(strFileName, CP.Line, DS.GetCurrentProcess);
  If KeyCode = TextToShortcut('Ctrl+Shift+F8') Then
    BP.Edit(True)
  Else If KeyCode = TextToShortcut('Ctrl+Alt+F8') Then
    BP.Enabled := Not BP.Enabled;
  BindingResult := krHandled;
End;

(**

  This is a getter method for the BindingType property.

  @precon  None.
  @postcon Returns btPartial to denote that this keyboatf binding is a supplimental
           binding not an entire keyboatf binding set.

  @return  a TBindingType

**)
Function TKeybindingTemplate.GetBindingType: TBindingType;

Begin
  Result := btPartial;
End;

(**

  This is a getter method for the DisplayName property.

  @precon  None.
  @postcon Returns the name of the keybinding that is displayed in the IDE`s options
           dialogue.

  @return  a String

**)
Function TKeybindingTemplate.GetDisplayName: String;

Begin
  Result := 'My Partial Keybindings';
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the keybinding.

  @return  a String

**)
Function TKeybindingTemplate.GetName: String;

Begin
  Result := 'My Partial Keyboard Bindings';
End;

(**

  This is an on execute event handler for the SelectMethod keybinding..

  @precon  None.
  @postcon Displays a dialogue from which a method can be selected.

  @param   Context       as an IOTAKeyContext as a constant
  @param   KeyCode       as a TShortcut
  @param   BindingResult as a TKeyBindingResult as a reference

**)
Procedure TKeybindingTemplate.SelectMethodExecute(Const Context: IOTAKeyContext;
  KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);

Begin
  SelectMethod;
  BindingResult := krHandled;
End;

End.
