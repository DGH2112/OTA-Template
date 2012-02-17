object frmItemSelectionForm: TfrmItemSelectionForm
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Form1'
  ClientHeight = 262
  ClientWidth = 384
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    384
    262)
  PixelsPerInch = 96
  TextHeight = 13
  object lbxItems: TListBox
    Left = 8
    Top = 8
    Width = 368
    Height = 215
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object btnOK: TBitBtn
    Left = 220
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TBitBtn
    Left = 301
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 2
  end
end
