(**

  This module contains a simple set of methods to allow the user to select a method from a
  list so that they can navigate to it.

  @Version 1.0
  @Date    08 Mar 2012
  @Author  David Hoyle

**)
Unit SelectMethodUnit;

Interface

  Procedure SelectMethod;

Implementation

Uses
  Classes,
  SysUtils,
  ToolsAPI,
  ItemSelectionForm,
  UtilityFunctions;

Type
  (** An enumerate to define the variant portion of the item position record. **)
  TSubItem = (siData, siPosition);

  (** A variant record to help translate line and column information from a data object
      referencec against each string list item. **)
  TItemPosition = Record
    Case TSubItem Of
      siData: (Data : TObject);
      siPosition: (
        Line   : SmallInt;
        Column : SmallInt
      );
  End;

(**

  This is a find method to find the presense of a method in the given line.

  @precon  None.
  @postcon Returns true if the given line contains a method declaration.

  @param   strLine as a String
  @return  a Boolean

**)
Function IsMethod(strLine : String) : Boolean;

Const
  strMethods : Array[1..4] Of String = ('procedure ', 'function ', 'constuctor ',
    'destructor ');

Var
  i : Integer;

Begin
  Result := False;
  For i := Low(strMethods) To High(strMethods) Do
    If Pos(strMethods[i], LowerCase(strLine)) > 0 Then
      Begin
        Result := True;
        Break;
      End;
End;

(**

  This method searches the text of the active editor and finds all the methods and places
  them in the given string list with the data object reference containing the line and
  column reference.

  @precon  None.
  @postcon searches the text of the active editor and finds all the methods and places
           them in the given string list with the data object reference containing the
           line and column reference.

  @param   slItems as a TStringList

**)
Procedure GetMethods(slItems : TStringList);

Var
  SE: IOTASourceEditor;
  slSource: TStringList;
  i: Integer;
  recPos : TItemPosition;
  boolImplementation : Boolean;
  iLine: Integer;

Begin
  SE := ActiveSourceEditor;
  If SE <> Nil Then
    Begin
      slSource := TStringList.Create;
      Try
        slSource.Text := EditorAsString(SE);
        boolImplementation := False;
        iLine := 1;
        For i := 0 To slSource.Count - 1 Do
          Begin
            If Not boolImplementation Then
              Begin
                If Pos('implementation', LowerCase(slSource[i])) > 0 Then
                  boolImplementation := True;
              End Else
            If IsMethod(slSource[i]) Then
              Begin
                recPos.Line := iLine;
                recPos.Column := 1;
                slItems.AddObject(slSource[i], recPos.Data);
              End;
            Inc(iLine);
          End;
        slItems.Sort;
      Finally
        slSource.Free;
      End;
    End;
End;

(**

  This method inserts a comment into the active editors text at the indexed string list`s
  method`s position and returns the new cursor position.

  @precon  slItems must be a valid string list and iIndex must be a valid index into that
           string list..
  @postcon inserts a comment into the active editors text at the indexed string list`s
           method`s position and returns the new cursor position.

  @param   slItems as a TStringList
  @param   iIndex  as an Integer
  @return  a TOTAEditPos

**)
Function InsertComment(slItems : TStringList; iIndex : Integer) : TOTAEditPos;

Var
  recItemPos : TItemPosition;
  SE: IOTASourceEditor;
  Writer: IOTAEditWriter;
  i: Integer;
  iIndent: Integer;
  iPosition: Integer;
  CharPos : TOTACharPos;

Begin
  recItemPos.Data := slItems.Objects[iIndex];
  Result.Line := recItemPos.Line;
  Result.Col := 1;
  SE := ActiveSourceEditor;
  If SE <> Nil Then
    Begin
      Writer := SE.CreateUndoableWriter;
      Try
        iIndent := 0;
        For i := 1 To Length(slItems[iIndex]) Do
          If slItems[iIndex][i] = #32 Then
            Inc(iIndent)
          Else
            Break;
        CharPos.Line := Result.Line;
        CharPos.CharIndex := Result.Col - 1;
        iPosition := SE.EditViews[0].CharPosToPos(CharPos);
        Writer.CopyTo(iPosition);
        OutputText(Writer, iIndent, '(**'#13#10);
        OutputText(Writer, iIndent, #13#10);
        OutputText(Writer, iIndent, '  Description.'#13#10);
        OutputText(Writer, iIndent, #13#10);
        OutputText(Writer, iIndent, '  @precon  '#13#10);
        OutputText(Writer, iIndent, '  @postcon '#13#10);
        OutputText(Writer, iIndent, #13#10);
        OutputText(Writer, iIndent, '**)'#13#10);
        Inc(Result.Line, 2);
        Inc(Result.Col, iIndent + 2);
      Finally
        Writer := Nil;
      End;
    End;
End;

(**

  This method displays a dialogue to the user from which they select a method. Once
  selected a comment is inserted about the selected method.

  @precon  None.
  @postcon Displays a dialogue to the user from which they select a method. Once
           selected a comment is inserted about the selected method.

**)
Procedure SelectMethod;

Var
  slItems: TStringList;
  SE: IOTASourceEditor;
  CP: TOTAEditPos;
  iIndex: Integer;

Begin
  slItems := TStringList.Create;
  Try
    GetMethods(slItems);
    iIndex := TfrmItemSelectionForm.Execute(slItems, 'Select Method');
    If iIndex > -1 Then
      Begin
        CP := InsertComment(slItems, iIndex);
        SE := ActiveSourceEditor;
        If SE <> Nil Then
          Begin
            SE.EditViews[0].CursorPos := CP;
            SE.EditViews[0].Center(CP.Line, CP.Col);
          End;
      End;
  Finally
    slItems.Free;
  End;
End;

End.
