object frmOptions: TfrmOptions
  Left = 443
  Top = 427
  BorderStyle = bsDialog
  Caption = 'Auto Save Options'
  ClientHeight = 79
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 16
  object lblAutoSaveInterval: TLabel
    Left = 10
    Top = 15
    Width = 108
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Auto Save &Interval'
    FocusControl = edtAutosaveInterval
  end
  object edtAutosaveInterval: TEdit
    Left = 128
    Top = 10
    Width = 50
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 0
    Text = '60'
  end
  object udAutoSaveInterval: TUpDown
    Left = 178
    Top = 10
    Width = 19
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Associate = edtAutosaveInterval
    Min = 60
    Max = 3600
    Position = 60
    TabOrder = 1
  end
  object cbxPrompt: TCheckBox
    Left = 10
    Top = 44
    Width = 119
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&Prompt'
    TabOrder = 2
  end
  object btnOK: TBitBtn
    Left = 202
    Top = 10
    Width = 92
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object btnCancel: TBitBtn
    Left = 202
    Top = 44
    Width = 92
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 4
  end
end
