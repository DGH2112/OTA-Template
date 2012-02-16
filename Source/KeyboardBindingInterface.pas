Unit KeyboardBindingInterface;

Interface

Uses
  ToolsAPI,
  Classes;

{$INCLUDE CompilerDefinitions.inc}

Type
  TKeybindingTemplate = Class(TNotifierObject, IOTAKeyboardBinding)
  {$IFDEF D2005} Strict {$ENDIF} Private
  {$IFDEF D2005} Strict {$ENDIF} Protected
    Procedure AddBreakPoint(Const Context: IOTAKeyContext;
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
  UtilityFunctions;

{ TKeybindingTemplate }

Procedure TKeybindingTemplate.BindKeyboard(Const BindingServices: IOTAKeyBindingServices);

Begin
  BindingServices.AddKeyBinding([TextToShortcut('Ctrl+Shift+F8')], AddBreakPoint, Nil);
  BindingServices.AddKeyBinding([TextToShortcut('Ctrl+Alt+F8')], AddBreakPoint, Nil);
End;

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
    BP := DS.NewSourceBreakpoint(strFileName, CP.Line, Nil);
  If KeyCode = TextToShortcut('Ctrl+Shift+F8') Then
    BP.Edit(True)
  Else If KeyCode = TextToShortcut('Ctrl+Alt+F8') Then
    BP.Enabled := Not BP.Enabled;
  BindingResult := krHandled;
End;

Function TKeybindingTemplate.GetBindingType: TBindingType;

Begin
  Result := btPartial;
End;

Function TKeybindingTemplate.GetDisplayName: String;

Begin
  Result := 'My Partial Keybindings';
End;

Function TKeybindingTemplate.GetName: String;

Begin
  Result := 'My Partial Keyboard Bindings';
End;

End.
