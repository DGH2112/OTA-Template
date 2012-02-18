Unit UtilityFunctions;

Interface

Uses
  ToolsAPI,
  Graphics,
  Windows;

{$INCLUDE CompilerDefinitions.inc}

Type
  TCustomMessage = Class(TInterfacedObject, IOTACustomMessage, INTACustomDrawMessage)
  Private
    FMsg: String;
    FFontName: String;
    FForeColour: TColor;
    FStyle: TFontStyles;
    FBackColour: TColor;
    FMessagePntr: Pointer;
  Protected
    Procedure SetForeColour(iColour: TColor);
  Public
    Constructor Create(strMsg: String; FontName: String;
      ForeColour: TColor = clBlack; Style: TFontStyles = [];
      BackColour: TColor = clWindow);
    Property ForeColour: TColor Write SetForeColour;
    Property MessagePntr: Pointer Read FMessagePntr Write FMessagePntr;
    // IOTACustomMessage
    Function GetColumnNumber: Integer;
    Function GetFileName: String;
    Function GetLineNumber: Integer;
    Function GetLineText: String;
    Procedure ShowHelp;
    // INTACustomDrawMessage
    Function CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect;
    Procedure Draw(Canvas: TCanvas; Const Rect: TRect; Wrap: Boolean);
  End;

  TClearMessage = (cmCompiler, cmSearch, cmTool);
  TClearMessages = Set of TClearMessage;

  Type
    TVersionInfo = Record
      iMajor  : Integer;
      iMinor  : Integer;
      iBugfix : Integer;
      iBuild  : Integer;
    End;

  Procedure BuildNumber(var VersionInfo : TVersionInfo);
  Procedure OutputMessage(strText : String); Overload;
  Procedure OutputMessage(strFileName, strText, strPrefix : String; iLine,
    iCol : Integer); Overload;
  {$IFDEF D0006}
  Procedure OutputMessage(strText : String; strGroupName : String); Overload;
  {$ENDIF}
  Procedure ClearMessages(Msg : TClearMessages);
  {$IFDEF D0006}
  Procedure ShowMessages(strGroupName : String = '');
  {$ENDIF}
  Function ProjectGroup: IOTAProjectGroup;
  Function ActiveProject : IOTAProject;
  Function ProjectModule(Project : IOTAProject) : IOTAModule;
  Function ActiveSourceEditor : IOTASourceEditor;
  Function SourceEditor(Module : IOTAMOdule) : IOTASourceEditor;
  Function EditorAsString(SourceEditor : IOTASourceEditor) : String;
  Function AddMsg(strText: String; boolGroup, boolAutoScroll: Boolean;
    strFontName: String; iForeColour: TColor; fsStyle: TFontStyles;
    iBackColour: TColor = clWindow; ptrParent: Pointer = Nil): Pointer;
  Procedure OutputText(Writer : IOTAEditWriter; iIndent : Integer; strText : String);

Implementation

Uses
  SysUtils;

Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;

Begin
  GetModuleFileName(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        With VerValue^ Do
          Begin
            VersionInfo.iMajor := dwFileVersionMS Shr 16;
            VersionInfo.iMinor := dwFileVersionMS And $FFFF;
            VersionInfo.iBugfix := dwFileVersionLS Shr 16;
            VersionInfo.iBuild := dwFileVersionLS And $FFFF;
          End;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;

Procedure OutputMessage(strText : String);

Begin
  (BorlandIDEServices As IOTAMessageServices).AddTitleMessage(strText);
End;

Procedure OutputMessage(strFileName, strText, strPrefix : String; iLine, iCol : Integer);

Begin
  (BorlandIDEServices As IOTAMessageServices).AddToolMessage(strFileName,
    strText, strPrefix, iLine, iCol);
End;

{$IFDEF D0006}
Procedure OutputMessage(strText : String; strGroupName : String);

Var
  Group : IOTAMessageGroup;

Begin
  With (BorlandIDEServices As IOTAMessageServices) Do
    Begin
      Group := GetGroup(strGroupName);
      If Group = Nil Then
        Group := AddMessageGroup(strGroupName);
      AddTitleMessage(strText, Group);
    End;
End;
{$ENDIF}

Procedure ClearMessages(Msg : TClearMessages);

Begin
  If cmCompiler In Msg Then
    (BorlandIDEServices As IOTAMessageServices).ClearCompilerMessages;
  If cmSearch In Msg Then
    (BorlandIDEServices As IOTAMessageServices).ClearSearchMessages;
  If cmTool In Msg Then
    (BorlandIDEServices As IOTAMessageServices).ClearToolMessages;
End;

{$IFDEF D0006}
Procedure ShowMessages(strGroupName : String = '');

Var
  G : IOTAMessageGroup;

Begin
  With (BorlandIDEServices As IOTAMessageServices) Do
    Begin
      G := GetGroup(strGroupName);
      ShowMessageView(G);
    End;
End;
{$ENDIF}

Function ProjectGroup: IOTAProjectGroup;

Var
  AModuleServices: IOTAModuleServices;
  AModule: IOTAModule;
  i: integer;
  AProjectGroup: IOTAProjectGroup;

Begin
  Result := Nil;
  AModuleServices := (BorlandIDEServices as IOTAModuleServices);
  For i := 0 To AModuleServices.ModuleCount - 1 Do
    Begin
      AModule := AModuleServices.Modules[i];
      If (AModule.QueryInterface(IOTAProjectGroup, AProjectGroup) = S_OK) Then
       Break;
    End;
  Result := AProjectGroup;
end;

Function ActiveProject : IOTAProject;

var
  G : IOTAProjectGroup;

Begin
  Result := Nil;
  G := ProjectGroup;
  If G <> Nil Then
    Result := G.ActiveProject;
End;

Function ProjectModule(Project : IOTAProject) : IOTAModule;

Var
  AModuleServices: IOTAModuleServices;
  AModule: IOTAModule;
  i: integer;
  AProject: IOTAProject;

Begin
  Result := Nil;
  AModuleServices := (BorlandIDEServices as IOTAModuleServices);
  For i := 0 To AModuleServices.ModuleCount - 1 Do
    Begin
      AModule := AModuleServices.Modules[i];
      If (AModule.QueryInterface(IOTAProject, AProject) = S_OK) And
        (Project = AProject) Then
        Break;
    End;
  Result := AProject;
End;

Function ActiveSourceEditor : IOTASourceEditor;

Var
  CM : IOTAModule;

Begin
  Result := Nil;
  If BorlandIDEServices = Nil Then
    Exit;
  CM := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
  Result := SourceEditor(CM);
End;

Function SourceEditor(Module : IOTAMOdule) : IOTASourceEditor;

Var
  iFileCount : Integer;
  i : Integer;

Begin
  Result := Nil;
  If Module = Nil Then Exit;
  With Module Do
    Begin
      iFileCount := GetModuleFileCount;
      For i := 0 To iFileCount - 1 Do
        If GetModuleFileEditor(i).QueryInterface(IOTASourceEditor,
          Result) = S_OK Then
          Break;
    End;
End;

Function EditorAsString(SourceEditor : IOTASourceEditor) : String;

Const
  iBufferSize : Integer = 1024;

Var
  Reader : IOTAEditReader;
  iRead : Integer;
  iPosition : Integer;
  strBuffer : AnsiString;

Begin
  Result := '';
  Reader := SourceEditor.CreateReader;
  Try
    iPosition := 0;
    Repeat
      SetLength(strBuffer, iBufferSize);
      iRead := Reader.GetText(iPosition, PAnsiChar(strBuffer), iBufferSize);
      SetLength(strBuffer, iRead);
      Result := Result + String(strBuffer);
      Inc(iPosition, iRead);
    Until iRead < iBufferSize;
  Finally
    Reader := Nil;
  End;
End;

Function AddMsg(strText: String; boolGroup, boolAutoScroll: Boolean;
  strFontName: String; iForeColour: TColor; fsStyle: TFontStyles;
  iBackColour: TColor = clWindow; ptrParent: Pointer = Nil): Pointer;

Const
  strMessageGroupName = 'My Custom Messages';

Var
  M: TCustomMessage;
  {$IFDEF D0006}
  G: IOTAMessageGroup;
  {$ENDIF}

Begin
  With (BorlandIDEServices As IOTAMessageServices) Do
    Begin
      M := TCustomMessage.Create(strText, strFontName, iForeColour, fsStyle, iBackColour);
      Result := M;
      If ptrParent = Nil Then
        Begin
          {$IFDEF D0006}
          G := Nil;
          If boolGroup Then
            G := AddMessageGroup(strMessageGroupName)
          Else
            G := GetMessageGroup(0);
          {$IFDEF D2005}
          If boolAutoScroll <> G.AutoScroll Then
            G.AutoScroll := boolAutoScroll;
          {$ENDIF}
          {$IFDEF D2005}
          M.MessagePntr := AddCustomMessagePtr(M As IOTACustomMessage, G);
          {$ELSE}
          AddCustomMessage(M As IOTACustomMessage, G);
          {$ENDIF}
          {$ELSE}
          AddCustomMessage(M As IOTACustomMessage);
          {$ENDIF}
        End
      Else
        {$IFDEF D2005}
        AddCustomMessage(M As IOTACustomMessage, ptrParent);
        {$ELSE}
        AddCustomMessage(M As IOTACustomMessage);
        {$ENDIF}
    End;
End;

Procedure OutputText(Writer : IOTAEditWriter; iIndent : Integer; strText : String);

Begin
  {$IFNDEF D2009}
  Writer.Insert(PAnsiChar(StringOfChar(#32, iIndent) + strText));
  {$ELSE}
  Writer.Insert(PAnsiChar(AnsiString(StringOfChar(#32, iIndent) + strText)));
  {$ENDIF}
End;

{ TCustomMessage Methods }

Function TCustomMessage.GetColumnNumber: Integer;

Begin
  Result := 0;
End;

Function TCustomMessage.GetFileName: String;

Begin
  Result := '';
End;

Function TCustomMessage.GetLineNumber: Integer;

Begin
  Result := 0;
End;

Function TCustomMessage.GetLineText: String;

Begin
  Result := FMsg;
End;

Procedure TCustomMessage.SetForeColour(iColour: TColor);

Begin
  If FForeColour <> iColour Then
    FForeColour := iColour;
End;

Procedure TCustomMessage.ShowHelp;

Begin
  //
End;

Constructor TCustomMessage.Create(strMsg: String; FontName: String;
  ForeColour: TColor = clBlack; Style: TFontStyles = [];
  BackColour: TColor = clWindow);

Const
  strValidChars: Set Of AnsiChar = [#10, #13, #32 .. #128];

Var
  i: Integer;
  iLength: Integer;

Begin
  SetLength(FMsg, Length(strMsg));
  iLength := 0;
  For i := 1 To Length(strMsg) Do
    {$IFDEF D2009}
    If CharInSet(strMsg[i], strValidChars) Then
    {$ELSE}
    If strMsg[i] In strValidChars Then
    {$ENDIF}
      Begin
        FMsg[iLength + 1] := strMsg[i];
        Inc(iLength);
      End;
  SetLength(FMsg, iLength);
  FFontName := FontName;
  FForeColour := ForeColour;
  FStyle := Style;
  FBackColour := BackColour;
  FMessagePntr := Nil;
End;

Function TCustomMessage.CalcRect(Canvas: TCanvas; MaxWidth: Integer;
  Wrap: Boolean): TRect;

Begin
  Canvas.Font.Name := FFontName;
  Canvas.Font.Style := FStyle;
  Result := Canvas.ClipRect;
  Result.Bottom := Result.Top + Canvas.TextHeight('Wp');
  Result.Right := Result.Left + Canvas.TextWidth(FMsg);
End;

Procedure TCustomMessage.Draw(Canvas: TCanvas; Const Rect: TRect;
  Wrap: Boolean);

Begin
  If Canvas.Brush.Color = clWindow Then
    Begin
      Canvas.Font.Color := FForeColour;
      Canvas.Brush.Color := FBackColour;
      Canvas.FillRect(Rect);
    End;
  Canvas.Font.Name := FFontName;
  Canvas.Font.Style := FStyle;
  Canvas.TextOut(Rect.Left, Rect.Top, FMsg);
End;

End.
