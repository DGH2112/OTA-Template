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
  TSubItem = (siData, siPosition);

  TItemPosition = Record
    Case TSubItem Of
      siData: (Data : TObject);
      siPosition: (
        Line   : SmallInt;
        Column : SmallInt
      );
  End;

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
